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

vec2 rotate2D(vec2 v, float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

float facetPattern(vec2 uv, float depth) {
  vec2 p = uv * 6.0;
  float d = 0.0;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      vec2 neighbor = floor(p) + vec2(float(i), float(j));
      vec2 offset = vec2(
        fract(sin(dot(neighbor, vec2(127.1, 311.7))) * 43758.5453),
        fract(sin(dot(neighbor, vec2(269.5, 183.3))) * 43758.5453)
      );
      vec2 diff = neighbor + offset - p;
      d = max(d, 1.0 - length(diff) * 2.0);
    }
  }
  return clamp(d * depth, 0.0, 1.0);
}

float sparkle(vec2 uv, float time, float intensity) {
  float s = 0.0;
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    vec2 pos = vec2(
      fract(sin(fi * 127.1 + 1.0) * 43758.5453),
      fract(sin(fi * 311.7 + 2.0) * 43758.5453)
    );
    float phase = fract(sin(fi * 43.0) * 6271.0) * 2.0 * PI;
    float blink = 0.5 + 0.5 * sin(time * (2.0 + fi * 0.7) + phase);
    s += blink * intensity * max(0.0, 1.0 - length(uv - pos) * 12.0);
  }
  return s;
}

// Box blur: max 9x9 tap grid (runs on GPU; separable passes would halve taps
// but require an intermediate render target not available in single-pass shaders).
vec4 blurSample(sampler2D tex, vec2 uv, float radius, vec2 texelSize) {
  if (radius < 0.5) return texture(tex, uv);
  vec4 col = vec4(0.0);
  float total = 0.0;
  int steps = int(clamp(radius * 2.0, 2.0, 9.0));
  float stepSize = clamp(radius, 0.0, 10.0) / float(steps);
  for (int x = -steps; x <= steps; x++) {
    for (int y = -steps; y <= steps; y++) {
      vec2 off = vec2(float(x), float(y)) * stepSize * texelSize;
      col += texture(tex, clamp(uv + off, vec2(0.0), vec2(1.0)));
      total += 1.0;
    }
  }
  return col / total;
}

vec3 adjustColor(vec3 color, float brightness, float contrast, float saturation) {
  color *= brightness;
  color = (color - 0.5) * contrast + 0.5;
  float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
  return clamp(mix(vec3(luma), color, saturation), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  vec2 texelSize = 1.0 / uSize;

  vec2 centered = uv - 0.5;
  centered = rotate2D(centered, uRotation);

  float facet = facetPattern(centered + 0.5, uFacetDepth);
  vec2 refractionOffset = vec2(
    sin(centered.x * uRefractionIndex * PI + uTime * 0.3) * 0.02,
    cos(centered.y * uRefractionIndex * PI + uTime * 0.3) * 0.02
  ) * facet;

  vec3 lightDir = normalize(uLightPosition - vec3(centered, 0.0));
  float specular = pow(max(0.0, dot(vec3(0.0, 0.0, 1.0), lightDir)), 32.0) * uSparkleIntensity;

  vec2 sampleUV = clamp(centered + 0.5 + refractionOffset, vec2(0.0), vec2(1.0));
  vec4 baseColor = blurSample(uUserImage, sampleUV, uBlur, texelSize);

  vec3 adjusted = adjustColor(baseColor.rgb, uBrightness, uContrast, uSaturation);

  float prism = facet * uFacetDepth * 0.3;
  vec3 prismColor = vec3(
    0.5 + 0.5 * sin(uTime + centered.x * 4.0),
    0.5 + 0.5 * sin(uTime * 1.1 + centered.y * 4.0 + 2.1),
    0.5 + 0.5 * sin(uTime * 0.9 + (centered.x + centered.y) * 4.0 + 4.2)
  );
  adjusted = mix(adjusted, prismColor, prism);
  adjusted += vec3(sparkle(uv, uTime, uSparkleIntensity * 0.3));
  adjusted += vec3(specular * 0.5);

  fragColor = vec4(clamp(adjusted, 0.0, 1.0), baseColor.a);
}
