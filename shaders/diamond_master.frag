#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uRefractionIndex;
uniform float uSparkleIntensity;
uniform float uFacetDepth;
uniform float uBrightness;
uniform float uContrast;
uniform float uSaturation;
uniform float uBlur;
uniform vec3 uLightPosition;
uniform float uRotation;
uniform float uEnvReflection;
uniform sampler2D uUserImage;

out vec4 fragColor;

const float PI = 3.14159265359;
const float DIAMOND_IOR = 2.42;

// ── Helpers ──────────────────────────────────────────────────────────────────

vec2 rotate2D(vec2 v, float a) {
    float c = cos(a);
    float s = sin(a);
    return vec2(c * v.x - s * v.y, s * v.x + c * v.y);
}

float hash21(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 5-tap cross Gaussian blur (radius in pixels).
vec4 blurSample(vec2 uv, float radius) {
    vec2 px = radius / uSize;
    vec4 c  = texture(uUserImage, uv)                       * 0.36;
    c      += texture(uUserImage, uv + vec2( px.x, 0.0))   * 0.16;
    c      += texture(uUserImage, uv + vec2(-px.x, 0.0))   * 0.16;
    c      += texture(uUserImage, uv + vec2(0.0,  px.y))   * 0.16;
    c      += texture(uUserImage, uv + vec2(0.0, -px.y))   * 0.16;
    return c;
}

// ── Round Brilliant Facet Geometry ───────────────────────────────────────────

// Returns a flat surface normal for the named zone of a round brilliant cut.
// p is centred at the origin; r ≈ 0..0.5 spans table through upper girdle.
vec3 brilliantNormal(vec2 p) {
    float radius     = length(p);
    float angle      = atan(p.y, p.x);

    // 8-fold crown symmetry
    const float N    = 8.0;
    float sectorSize = (2.0 * PI) / N;
    float sectorIdx  = floor((angle + PI) / sectorSize);
    float sectorCtr  = (sectorIdx + 0.5) * sectorSize - PI;
    vec2  outDir     = vec2(cos(sectorCtr), sin(sectorCtr));

    if (radius < 0.14) {
        // Table — flat horizontal face
        return vec3(0.0, 0.0, 1.0);
    } else if (radius < 0.32) {
        // 8 star facets — slight outward tilt (~14°)
        return normalize(vec3(outDir * 0.25, 1.0));
    } else if (radius < 0.62) {
        // 8 main kite (bezel) facets — steeper tilt (~35°)
        return normalize(vec3(outDir * 0.70, 1.0));
    } else {
        // 16 upper-girdle facets — double the sectors, steep tilt
        float halfSize = sectorSize * 0.5;
        float halfIdx  = floor((angle + PI) / halfSize);
        float halfCtr  = (halfIdx + 0.5) * halfSize - PI;
        vec2  hDir     = vec2(cos(halfCtr), sin(halfCtr));
        return normalize(vec3(hDir * 1.2, 1.0));
    }
}

// ── Procedural HDR-like Environment ──────────────────────────────────────────

// Samples a simple procedural environment in the direction `dir`.
// `t` is elapsed time (drives the two orbiting specular lights).
vec3 envSample(vec3 dir, float t) {
    // Sky gradient: dark near-horizon → cool blue zenith
    float elev = clamp(dir.z * 0.5 + 0.5, 0.0, 1.0);
    vec3  sky  = mix(vec3(0.04, 0.04, 0.12), vec3(0.25, 0.35, 0.65), elev);

    // Two animated specular lights (warm key + cool fill)
    vec3 L1 = normalize(vec3(cos(t * 0.25), sin(t * 0.25), 0.85));
    vec3 L2 = normalize(vec3(cos(t * 0.25 + PI * 0.6), sin(t * 0.25 + PI * 0.6), 0.60));
    sky += vec3(1.6, 1.4, 1.1) * pow(max(0.0, dot(dir, L1)), 55.0);
    sky += vec3(0.8, 0.9, 1.2) * pow(max(0.0, dot(dir, L2)), 45.0);

    // Warm floor bounce
    float ground = clamp(-dir.z * 2.5, 0.0, 1.0);
    sky = mix(sky, vec3(0.55, 0.38, 0.08) * 0.45, ground);

    return sky;
}

// ── Main ─────────────────────────────────────────────────────────────────────

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv        = fragCoord / uSize;

    // ── Rotation ──────────────────────────────────────────────────────────
    vec2 centered   = uv - 0.5;
    centered        = rotate2D(centered, uRotation);
    vec2 rotatedUv  = centered + 0.5;

    // ── Diamond facet normals (Voronoi-based) ─────────────────────────────
    vec2 facetUv = centered * 5.0;
    vec2 fi      = floor(facetUv);
    vec2 ff      = fract(facetUv);

    vec2  closestOffset = vec2(0.0);
    float minDist       = 10.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 nb      = vec2(float(x), float(y));
            vec2 rndOff  = vec2(
                hash21(fi + nb),
                hash21(fi + nb + vec2(1.7, 9.2))
            ) * 0.5 + 0.25;
            float d = length(ff - (nb + rndOff));
            if (d < minDist) {
                minDist       = d;
                closestOffset = (nb + rndOff) - ff;
            }
        }
    }

    // ── Blend Voronoi normal with round-brilliant geometry ─────────────────
    // uFacetDepth == 0 → pure Voronoi micro-facets; == 1 → brilliant geometry
    vec3 voronoiNormal = normalize(vec3(closestOffset, 1.0 / max(uFacetDepth, 0.01)));
    vec3 brillNormal   = brilliantNormal(centered);
    vec3 facetNormal   = normalize(mix(voronoiNormal, brillNormal, uFacetDepth));

    // ── Refraction ────────────────────────────────────────────────────────
    float ior          = uRefractionIndex / DIAMOND_IOR;
    vec2  refractOff   = closestOffset * uFacetDepth * (ior - 1.0) * 0.06;
    vec2  sampleUv     = clamp(rotatedUv + refractOff, 0.0, 1.0);

    // ── Image sampling (with optional blur) ───────────────────────────────
    vec4 col = mix(
        texture(uUserImage, sampleUv),
        blurSample(sampleUv, uBlur),
        clamp(uBlur, 0.0, 1.0)
    );

    // ── Colour adjustments ────────────────────────────────────────────────
    vec3 rgb = col.rgb * uBrightness;
    rgb = (rgb - 0.5) * uContrast + 0.5;
    float lum = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb = mix(vec3(lum), rgb, uSaturation);

    // ── Chromatic dispersion ──────────────────────────────────────────────
    float disp = uFacetDepth * 0.025;
    float r    = texture(uUserImage, clamp(sampleUv + vec2( disp, 0.0), 0.0, 1.0)).r;
    float b    = texture(uUserImage, clamp(sampleUv + vec2(-disp, 0.0), 0.0, 1.0)).b;
    rgb.r = mix(rgb.r, r * uBrightness, 0.35);
    rgb.b = mix(rgb.b, b * uBrightness, 0.35);

    // ── Facet highlight ───────────────────────────────────────────────────
    float facetHighlight = pow(
        clamp(dot(facetNormal, normalize(uLightPosition)), 0.0, 1.0),
        8.0
    );
    vec3 goldColor = vec3(0.831, 0.686, 0.216);
    rgb += goldColor * facetHighlight * uFacetDepth * 0.4;

    // Subtle edge glow
    float edgeDim = clamp(1.0 - length(centered) * 1.8, 0.0, 1.0);
    rgb += goldColor * (1.0 - edgeDim) * 0.04 * uFacetDepth;

    // ── Environment reflection ─────────────────────────────────────────────
    // Assumes orthographic projection: view ray is constant (0,0,-1) across
    // the canvas. This is correct for a 2D icon preview; if a perspective
    // camera is ever added, pass viewDir as a uniform instead.
    vec3 viewDir  = vec3(0.0, 0.0, -1.0);
    vec3 reflDir  = reflect(viewDir, facetNormal);
    vec3 envColor = envSample(reflDir, uTime);
    // Fresnel-like rim: stronger at grazing angles
    float fresnel = pow(1.0 - clamp(dot(-viewDir, facetNormal), 0.0, 1.0), 2.0);
    rgb = mix(rgb, envColor, uEnvReflection * (0.25 + fresnel * 0.5));

    // ── Sparkle / light rays ──────────────────────────────────────────────
    vec2  lightDir    = uLightPosition.xy - centered;
    float lightDist   = length(lightDir);
    float angle       = atan(lightDir.y, lightDir.x) + uTime * 0.3;
    float rays        = pow(max(0.0, cos(angle * 6.0)), 20.0);
    float falloff     = exp(-lightDist * 5.0);
    rgb += vec3(rays * falloff * uSparkleIntensity * 0.5) * vec3(1.0, 0.95, 0.8);

    // Shimmer over time
    float shimmer = sin(uTime * 1.5 + dot(uv, vec2(8.0, 6.0))) * 0.015 * uSparkleIntensity;
    rgb += shimmer;

    fragColor = vec4(clamp(rgb, 0.0, 1.0), col.a);
}
