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
uniform sampler2D uUserImage;

out vec4 fragColor;

const float PI = 3.14159265359;

// --- Utility -----------------------------------------------------------------

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Returns distance to nearest Voronoi cell centre (used for sparkle on edges).
float voronoiDist(vec2 uv, float scale) {
    vec2 p = uv * scale;
    vec2 i = floor(p);
    vec2 f = fract(p);
    float minDist = 8.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 n = vec2(float(x), float(y));
            vec2 pt = vec2(
                hash21(i + n + vec2(13.7, 57.3)),
                hash21(i + n + vec2(72.5, 31.1))
            );
            float dist = length(n + pt - f);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

// 3x3 Gaussian blur in texture space.
vec4 sampleBlurred(sampler2D tex, vec2 uv, float radius, vec2 pixelSize) {
    if (radius < 0.001) {
        return texture(tex, uv);
    }
    // Weights for a 3x3 kernel (sum = 16)
    vec4 col = vec4(0.0);
    vec2 o = radius * pixelSize;
    col += texture(tex, uv + vec2(-o.x,  o.y)) * 1.0;
    col += texture(tex, uv + vec2( 0.0,  o.y)) * 2.0;
    col += texture(tex, uv + vec2( o.x,  o.y)) * 1.0;
    col += texture(tex, uv + vec2(-o.x,  0.0)) * 2.0;
    col += texture(tex, uv                    ) * 4.0;
    col += texture(tex, uv + vec2( o.x,  0.0)) * 2.0;
    col += texture(tex, uv + vec2(-o.x, -o.y)) * 1.0;
    col += texture(tex, uv + vec2( 0.0, -o.y)) * 2.0;
    col += texture(tex, uv + vec2( o.x, -o.y)) * 1.0;
    return col / 16.0;
}

// Standard brightness / contrast / saturation adjustment.
vec3 adjustColor(vec3 color, float brightness, float contrast, float saturation) {
    color *= brightness;
    color = (color - 0.5) * contrast + 0.5;
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luma), color, saturation);
    return clamp(color, 0.0, 1.0);
}

// --- Main --------------------------------------------------------------------

void main() {
    vec2 fragCoord  = FlutterFragCoord().xy;
    vec2 uv         = fragCoord / uSize;
    vec2 pixelSize  = 1.0 / uSize;

    // ---- Facet normal via finite-difference noise gradient ------------------
    float facetScale = 4.0 + uFacetDepth * 12.0;
    float eps = 0.008;
    float nx0 = smoothNoise(vec2(uv.x - eps, uv.y      ) * facetScale);
    float nx1 = smoothNoise(vec2(uv.x + eps, uv.y      ) * facetScale);
    float ny0 = smoothNoise(vec2(uv.x,       uv.y - eps) * facetScale);
    float ny1 = smoothNoise(vec2(uv.x,       uv.y + eps) * facetScale);
    vec2 facetGrad = vec2(nx1 - nx0, ny1 - ny0);

    // ---- Refraction offset --------------------------------------------------
    float refractionStrength = (uRefractionIndex - 1.0) * 0.04 * uFacetDepth;
    vec2 refractedUv = clamp(uv + facetGrad * refractionStrength, 0.001, 0.999);

    // ---- Chromatic dispersion (colour-channel split around the IOR) ---------
    float dispersion = (uRefractionIndex - 1.0) * 0.012 * uFacetDepth;
    vec2 rUv = clamp(uv + facetGrad * (refractionStrength + dispersion), 0.001, 0.999);
    vec2 bUv = clamp(uv + facetGrad * (refractionStrength - dispersion), 0.001, 0.999);

    // ---- Sample image with optional Gaussian blur ---------------------------
    float blurRadius = uBlur * 20.0;
    vec4 baseColor = sampleBlurred(uUserImage, refractedUv, blurRadius, pixelSize);
    float rChannel  = sampleBlurred(uUserImage, rUv, blurRadius, pixelSize).r;
    float bChannel  = sampleBlurred(uUserImage, bUv, blurRadius, pixelSize).b;

    // Blend in dispersion proportional to facet depth
    vec3 color = baseColor.rgb;
    float dispBlend = dispersion * 5.0 * uFacetDepth;
    color.r = mix(color.r, rChannel, dispBlend);
    color.b = mix(color.b, bChannel, dispBlend);

    // ---- Colour adjustments -------------------------------------------------
    color = adjustColor(color, uBrightness, uContrast, uSaturation);

    // ---- 3-D facet lighting -------------------------------------------------
    vec3 normal   = normalize(vec3(facetGrad * uFacetDepth, 1.0));
    vec3 lightDir = normalize(uLightPosition);
    float diffuse = max(dot(normal, lightDir), 0.0);

    // Blinn-Phong specular
    vec3 viewDir  = vec3(0.0, 0.0, 1.0);
    vec3 halfDir  = normalize(lightDir + viewDir);
    float spec    = pow(max(dot(normal, halfDir), 0.0), 64.0);

    // Modulate colour with diffuse
    color = mix(color, color * (0.6 + diffuse * 0.4), uFacetDepth * 0.7);

    // ---- Animated sparkles --------------------------------------------------
    float t = uTime * 1.5;

    // Soft animated noise sparkle
    float sn = smoothNoise(uv * 22.0 + vec2(cos(t * 0.3), sin(t * 0.7)));
    sn = pow(max(sn - 0.5, 0.0) * 2.0, 3.0);

    // Voronoi-edge sparkle (shifts slowly over time)
    float vDist = voronoiDist(uv + vec2(cos(t * 0.1), sin(t * 0.13)) * 0.01,
                              facetScale * 0.5);
    float edgeSpark = pow(max(0.0, 1.0 - vDist * 3.0), 4.0);

    vec3  sparkColor   = vec3(1.0, 0.97, 0.90);
    float totalSparkle = (spec * 0.6 + sn * 0.3 + edgeSpark * 0.4) * uSparkleIntensity;
    color += sparkColor * totalSparkle * 0.5;

    // ---- Output -------------------------------------------------------------
    fragColor = vec4(clamp(color, 0.0, 1.0), baseColor.a);
}
