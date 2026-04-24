#version 460 core
#include <flutter/runtime_effect.glsl>

// Uniforms: indices must match Dart side!
uniform float uSizeX;            // 0
uniform float uSizeY;            // 1
uniform float uTime;             // 2
uniform float uRefractionIndex;  // 3
uniform float uSparkleIntensity; // 4
uniform float uFacetDepth;       // 5
uniform float uBrightness;       // 6
uniform float uContrast;         // 7
uniform float uSaturation;       // 8
uniform float uBlur;             // 9
uniform vec3  uLightPosition;    // 10, 11, 12
uniform float uRotation;         // 13

uniform sampler2D uUserImage;    // image input

out vec4 fragColor;

const float PI = 3.14159265359;
const float DIAMOND_IOR = 2.42;

void main() {
    // Convert pixel to normalized coordinates
    vec2 uv = FlutterFragCoord().xy / vec2(uSizeX, uSizeY);

    // Center and rotate
    vec2 center = uv - 0.5;
    float c = cos(uRotation);
    float s = sin(uRotation);
    mat2 rot = mat2(c, -s, s, c);
    center = rot * center;
    uv = center + 0.5;

    // Sample the image
    vec4 color = texture(uUserImage, uv);

    // Apply brightness/contrast/saturation
    color.rgb = color.rgb * uBrightness;
    color.rgb = (color.rgb - 0.5) * uContrast + 0.5;
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(gray), color.rgb, uSaturation);

    // Apply blur (simple, for demo)
    if (uBlur > 0.0) {
        // Divide by 300.0 to convert blur (0–20 px range) into a UV-space offset
        float blurSize = uBlur / 300.0;
        color.rgb += texture(uUserImage, uv + vec2(blurSize, 0.0)).rgb;
        color.rgb += texture(uUserImage, uv - vec2(blurSize, 0.0)).rgb;
        color.rgb += texture(uUserImage, uv + vec2(0.0, blurSize)).rgb;
        color.rgb += texture(uUserImage, uv - vec2(0.0, blurSize)).rgb;
        color.rgb /= 5.0;
    }

    // Simulate sparkle (simple animation)
    float sparkle = abs(sin(uTime + uv.x * 10.0 + uv.y * 10.0)) * uSparkleIntensity;
    // Multiply by 0.1 to keep sparkle contribution subtle relative to base color
    color.rgb += sparkle * 0.1;

    // Simulate refraction/facet (demo only)
    color.rgb *= 1.0 + uFacetDepth * 0.1 * sin(20.0 * (uv.x + uv.y) + uTime);

    // Output
    fragColor = color;
}
