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
        clamp(dot(normalize(vec3(closestOffset, 1.0)), normalize(uLightPosition)), 0.0, 1.0),
        8.0
    );
    vec3 goldColor = vec3(0.831, 0.686, 0.216);
    rgb += goldColor * facetHighlight * uFacetDepth * 0.4;

    // Subtle edge glow
    float edgeDim = clamp(1.0 - length(centered) * 1.8, 0.0, 1.0);
    rgb += goldColor * (1.0 - edgeDim) * 0.04 * uFacetDepth;

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
