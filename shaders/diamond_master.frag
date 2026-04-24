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
