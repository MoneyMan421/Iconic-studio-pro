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
const float DIAMOND_IOR = 2.42;

vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    mat2 rot = mat2(c, -s, s, c);
    return rot * uv;
}

float facetPattern(vec2 uv, float depth) {
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);

    float facet = cos(angle * 8.0);
    facet = smoothstep(0.0, depth, facet);

    float table = smoothstep(0.15, 0.2, radius);
    float girdle = smoothstep(0.45, 0.5, radius);

    return mix(facet, 1.0, table) * (1.0 - girdle);
}

vec3 dispersion(vec2 uv, float ior, float intensity) {
    vec3 offset = vec3(
        sin(uv.x * 10.0 + uTime) * 0.01 * intensity,
        cos(uv.y * 10.0 + uTime * 1.3) * 0.01 * intensity,
        sin((uv.x + uv.y) * 8.0 + uTime * 0.7) * 0.01 * intensity
    );

    float r = texture(uUserImage, uv + offset.x).r;
    float g = texture(uUserImage, uv + offset.y).g;
    float b = texture(uUserImage, uv + offset.z).b;

    return vec3(r, g, b);
}

float sparkle(vec2 uv, vec3 lightPos, float intensity) {
    vec2 lightXY = lightPos.xy;
    float dist = length(uv - lightXY);
    float angle = atan(uv.y - lightXY.y, uv.x - lightXY.x);

    float star = pow(abs(cos(angle * 6.0)), 32.0);
    float glow = exp(-dist * 4.0) * star;
    float twinkle = sin(uTime * 3.0 + dist * 10.0) * 0.5 + 0.5;

    return glow * twinkle * intensity;
}

vec3 adjustColor(vec3 color, float brightness, float contrast, float saturation) {
    color *= brightness;
    color = (color - 0.5) * contrast + 0.5;
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luminance), color, saturation);
    return clamp(color, 0.0, 1.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;
    vec2 center = uv - 0.5;

    center.x *= uSize.x / uSize.y;

    float rotRad = 0.0;
    center = rotate(center, rotRad);

    float radius = length(center);
    float diamondMask = 1.0 - smoothstep(0.48, 0.5, radius);
    float facets = facetPattern(center, uFacetDepth);
    vec2 refractUV = uv + center * (uRefractionIndex - 1.0) * 0.1 * facets;

    vec3 color = dispersion(refractUV, uRefractionIndex, uSparkleIntensity);
    color = adjustColor(color, uBrightness, uContrast, uSaturation);

    float sparkles = sparkle(center, uLightPosition, uSparkleIntensity);
    color += vec3(1.0, 0.95, 0.8) * sparkles;
    color *= 0.7 + 0.3 * facets;

    float rim = 1.0 - smoothstep(0.4, 0.5, radius);
    color += vec3(0.83, 0.69, 0.22) * rim * 0.3 * uSparkleIntensity;

    if (uBlur > 0.0) {
        vec3 blurColor = vec3(0.0);
        float samples = 8.0;
        for (float i = 0.0; i < samples; i++) {
            float angle = (i / samples) * PI * 2.0;
            vec2 offset = vec2(cos(angle), sin(angle)) * uBlur * 0.001;
            blurColor += texture(uUserImage, uv + offset).rgb;
        }
        color = mix(color, blurColor / samples, uBlur / 20.0);
    }

    fragColor = vec4(color, diamondMask);
}
