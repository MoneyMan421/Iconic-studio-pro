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

vec2 rotate2D(vec2 p, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

vec3 applyBrightnessContrast(vec3 color, float brightness, float contrast) {
    color *= brightness;
    color = (color - 0.5) * contrast + 0.5;
    return clamp(color, 0.0, 1.0);
}

vec3 applySaturation(vec3 color, float saturation) {
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    return clamp(mix(vec3(luma), color, saturation), 0.0, 1.0);
}

// 7×7 box blur (radius driven by uBlur pixels)
vec4 blurSample(sampler2D tex, vec2 uv, float blurPx) {
    vec2 texel = 1.0 / uSize;
    vec4 acc = vec4(0.0);
    float total = 0.0;
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * texel * blurPx;
            acc   += texture(tex, clamp(uv + offset, 0.0, 1.0));
            total += 1.0;
        }
    }
    return acc / total;
}

// Diamond facet pattern – returns a scalar modulation in [0,1]
float diamondFacets(vec2 uv, float depth, float time) {
    vec2 p  = uv * 6.0;
    vec2 r1 = rotate2D(p, time * 0.25);
    vec2 r2 = rotate2D(p, time * 0.18 + PI / 3.0);
    float f1 = abs(fract(r1.x) - 0.5) + abs(fract(r1.y) - 0.5);
    float f2 = abs(fract(r2.x) - 0.5) + abs(fract(r2.y) - 0.5);
    return 1.0 - min(f1, f2) * depth;
}

// Refraction distortion – bends UVs towards the centre based on IOR
vec2 refractUV(vec2 uv, float ior, float depth) {
    vec2 dir   = uv - 0.5;
    float dist = length(dir);
    float bend = (ior - 1.0) * depth * 0.12;
    return clamp(uv + dir * bend * (1.0 - dist), 0.0, 1.0);
}

// Sparkle / caustic
float sparkle(vec2 uv, vec3 lightPos, float intensity, float time) {
    if (intensity <= 0.0) return 0.0;

    // Orbiting shimmer points
    float s = 0.0;
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 sp = vec2(
            sin(time * 1.3 + fi * 1.7 + uv.x * 3.0),
            cos(time * 1.1 + fi * 2.3 + uv.y * 3.0)
        ) * 0.4 + 0.5;
        float d = length(uv - sp);
        float sh = exp(-d * 12.0) * max(0.0, sin(time * 4.0 + fi * PI * 0.5));
        s += sh;
    }

    // 6-point star burst around light position
    vec2 centered = uv - 0.5 - lightPos.xy * 0.3;
    float burst = 0.0;
    for (int k = 0; k < 6; k++) {
        float ang = float(k) * PI / 3.0;
        vec2  dir2 = vec2(cos(ang + time * 0.5), sin(ang + time * 0.5));
        float proj = dot(centered, dir2);
        float perp = length(centered - dir2 * proj);
        burst += exp(-perp * 28.0) * exp(-abs(proj) * 4.0);
    }

    // Fresnel highlight from light direction
    vec2  ld      = normalize(lightPos.xy - (uv - 0.5));
    float fresnel = pow(1.0 - abs(dot(ld, vec2(0.0, 1.0))), 3.0);

    return (s * 0.3 + burst * 0.4 + fresnel * 0.3) * intensity;
}

// ── Main ─────────────────────────────────────────────────────────────────────

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv        = fragCoord / uSize;

    // Rotation around centre
    vec2 rotUV = rotate2D(uv - 0.5, uRotation) + 0.5;

    // Refraction distortion
    vec2 refUV = refractUV(rotUV, uRefractionIndex, uFacetDepth);

    // Sample image (with optional blur)
    vec4 imgColor = (uBlur > 0.0)
        ? blurSample(uUserImage, refUV, uBlur)
        : texture(uUserImage, refUV);

    // Colour adjustments
    vec3 color = imgColor.rgb;
    color = applyBrightnessContrast(color, uBrightness, uContrast);
    color = applySaturation(color, uSaturation);

    // Facet overlay
    float facet = diamondFacets(uv, uFacetDepth * 0.3, uTime);
    color = mix(color, color * facet, uFacetDepth * 0.4);

    // Sparkle / caustics
    float sp = sparkle(uv, uLightPosition, uSparkleIntensity, uTime);
    color += vec3(sp) * 0.8;

    // Prismatic edge dispersion
    float edgeDist = length(uv - 0.5);
    float prism    = smoothstep(0.3, 0.5, edgeDist) * uSparkleIntensity * 0.3;
    vec3 rainbow   = vec3(
        sin(uTime * 2.0 + edgeDist * 8.0)                    * 0.5 + 0.5,
        sin(uTime * 2.0 + edgeDist * 8.0 + PI * 2.0 / 3.0)  * 0.5 + 0.5,
        sin(uTime * 2.0 + edgeDist * 8.0 + PI * 4.0 / 3.0)  * 0.5 + 0.5
    );
    color = mix(color, color + rainbow * prism, prism);

    fragColor = vec4(clamp(color, 0.0, 1.0), imgColor.a);
}
