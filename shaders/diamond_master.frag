#version 460 core
#include <flutter/runtime_effect.glsl>

// ------------------------------------------------------------
// Uniforms  (indices must match _configureShader in main.dart)
// ------------------------------------------------------------
uniform vec2  uSize;             // [0,1]
uniform float uTime;             // [2]
uniform float uRefractionIndex;  // [3]
uniform float uSparkleIntensity; // [4]
uniform float uFacetDepth;       // [5]
uniform float uBrightness;       // [6]
uniform float uContrast;         // [7]
uniform float uSaturation;       // [8]
uniform float uBlur;             // [9]
uniform vec3  uLightPosition;    // [10,11,12]
uniform float uDispersion;       // [13]
uniform float uBevelDepth;       // [14]
uniform float uStoneCount;       // [15]
uniform float uCaratSize;        // [16]
uniform sampler2D uUserImage;    // sampler[0]

out vec4 fragColor;

const float PI        = 3.14159265359;
const float GOLD_ANGLE = PI * (3.0 - sqrt(5.0));

// ---- Utilities -------------------------------------------------------

float hash(vec2 p) {
    p  = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

float hash1(float n) { return fract(sin(n) * 43758.5453123); }

vec2 rotate2D(vec2 v, float a) {
    float s = sin(a), c = cos(a);
    return vec2(c * v.x - s * v.y, s * v.x + c * v.y);
}

// ---- S2 fix: branchless refract2D — no TIR early-return branch -------
//
// Buggy version had:
//   float sinT2 = eta*eta*(1.0 - cosI*cosI);
//   if (sinT2 > 1.0) return uv;   // <-- GPU warp divergence on all edge pixels
//
// Fixed: step(sinT2, 1.0) == 1 when propagating, 0 when TIR;
//        mix() chooses between pass-through and refracted ray, fully branchless.
vec2 refract2D(vec2 incident, vec2 normal, float eta) {
    float cosI  = dot(-incident, normal);
    float sinT2 = eta * eta * (1.0 - cosI * cosI);
    float cosT  = sqrt(max(0.0, 1.0 - sinT2));
    float active = step(sinT2, 1.0);          // 1 = propagate, 0 = TIR
    vec2  refr   = eta * incident + (eta * cosI - cosT) * normal;
    return mix(incident, refr, active);
}

// ---- Facet distortion ------------------------------------------------
float facetPattern(vec2 uv, float scale, float depth) {
    vec2  scaled = uv * scale;
    vec2  cell   = floor(scaled);
    vec2  fr     = fract(scaled) - 0.5;
    float angle  = hash(cell) * PI * 2.0;
    return length(rotate2D(fr, angle)) * depth;
}

// ---- Sparkle ---------------------------------------------------------
//
// S3 fix: removed the unused variable `d = length(uv - pos)` that appeared
//         before the actual distance computation on `dp`.  Now `dp` carries
//         the vector and `dist` is computed once from it.
float sparkleContrib(vec2 uv, vec2 pos, float idx, float t) {
    vec2  dp    = uv - pos;                   // S3: reuse dp; was: float d = length(dp) (dead)
    float dist  = length(dp);
    float angle = atan(dp.y, dp.x);
    float rays  = abs(cos(angle * 4.0 + t * 2.0 + idx));
    float glint = pow(max(0.0, rays - 0.7), 3.0) / (dist * 10.0 + 0.1);
    return glint * hash1(idx * 13.1 + t * 0.5);
}

float sparkle(vec2 uv, float t, float intensity) {
    float result = 0.0;
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2  pos = vec2(hash1(fi * 7.3), hash1(fi * 3.7));
        result   += sparkleContrib(uv, pos, fi, t);
    }
    return result * intensity;
}

// ---- Pavé stones (fibonacci spiral on bevel ring) --------------------
float paveStones(vec2 uv, float count, float caratSize, float t) {
    float result = 0.0;
    for (int i = 0; i < 64; i++) {
        float fi     = float(i);
        float active = step(fi, count - 1.0);   // branchless stone count gate
        float angle  = fi * GOLD_ANGLE;
        float r      = 0.44;
        vec2  sc     = vec2(0.5 + r * cos(angle), 0.5 + r * sin(angle));
        float dist   = length(uv - sc);
        float stoneR = caratSize * 0.25 + 0.006;
        float shimmer = hash1(fi * 3.1 + t * 0.3);
        float stone   = (1.0 - smoothstep(stoneR * 0.5, stoneR, dist)) * active;
        float sp      = pow(max(0.0, 1.0 - dist / stoneR), 4.0) * shimmer * active;
        result       += max(stone * 0.5, sp);
    }
    return clamp(result, 0.0, 1.0);
}

// ---- Gold 24k bevel frame (annular ring) -----------------------------
vec4 goldBevelFrame(vec2 uv, float bevelDepth, float t) {
    vec2  c       = uv - 0.5;
    float dist    = length(c);
    float bNorm   = clamp(bevelDepth / 20.0, 0.0, 1.0);
    float innerR  = 0.38 - bNorm * 0.06;
    float ring    = smoothstep(0.50, 0.49, dist) * smoothstep(innerR, innerR + 0.01, dist);
    if (ring < 0.005) return vec4(0.0);

    float angle  = atan(c.y, c.x);
    float sheen  = pow(0.5 + 0.5 * cos(angle * 3.0 + t * 0.7), 2.0);
    vec3  gDark  = vec3(0.545, 0.420, 0.082);
    vec3  gMid   = vec3(0.831, 0.686, 0.216);
    vec3  gLight = vec3(0.957, 0.894, 0.737);
    vec3  gold   = mix(mix(gDark, gMid, sheen), gLight, sheen * sheen)
                 + vec3(pow(sheen, 8.0) * 0.5);  // specular highlight
    return vec4(gold, ring);
}

// ---- Color helpers ---------------------------------------------------
vec3 adjustSaturation(vec3 c, float sat) {
    float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
    return mix(vec3(lum), c, sat);
}

vec3 adjustContrast(vec3 c, float con) {
    return clamp((c - 0.5) * con + 0.5, 0.0, 1.0);
}

// ---- main ------------------------------------------------------------
void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv  = fragCoord / uSize;
    vec2 c   = uv - 0.5;
    vec2 n   = normalize(c + 0.0001);

    // --- Facet + refraction with chromatic dispersion ---
    float facet = facetPattern(uv, 6.0 + uFacetDepth * 4.0, uFacetDepth * 0.05);
    vec2  fOff  = n * facet;
    float eta   = 1.0 / uRefractionIndex;
    vec2  rBase = refract2D(normalize(c + fOff + 0.001), -n, eta) * 0.15 + fOff;

    vec2 uvR = uv + rBase * (1.0 + uDispersion);
    vec2 uvG = uv + rBase;
    vec2 uvB = uv + rBase * (1.0 - uDispersion);

    // --- 5×5 box blur with per-channel UV (blur + dispersion together) ---
    float blurR = uBlur * 0.02 / uSize.x;
    vec3  sampR = vec3(0.0), sampG = vec3(0.0), sampB = vec3(0.0);
    float w = 1.0 / 25.0;
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 off = vec2(float(x), float(y)) * blurR;
            sampR += texture(uUserImage, clamp(uvR + off, 0.0, 1.0)).rgb * w;
            sampG += texture(uUserImage, clamp(uvG + off, 0.0, 1.0)).rgb * w;
            sampB += texture(uUserImage, clamp(uvB + off, 0.0, 1.0)).rgb * w;
        }
    }
    vec3  color = vec3(sampR.r, sampG.g, sampB.b);
    float alpha = texture(uUserImage, clamp(uvG, 0.0, 1.0)).a;

    // --- Adjustments ---
    color = adjustSaturation(color, uSaturation);
    color = adjustContrast(color, uContrast);
    color = clamp(color * uBrightness, 0.0, 1.0);

    // --- Phong lighting ---
    vec3  normal = normalize(vec3(c * 2.0, 1.0 - length(c) * 2.0));
    vec3  lightD = normalize(uLightPosition);
    float diff   = max(0.0, dot(normal, lightD));
    float spec   = pow(max(0.0, dot(reflect(-lightD, normal), vec3(0.0, 0.0, 1.0))), 32.0);
    color = color * (0.7 + diff * 0.3) + vec3(spec * 0.3);

    // --- Sparkle glints ---
    color += vec3(sparkle(uv, uTime, uSparkleIntensity));

    // --- Pavé stones ---
    float stones = paveStones(uv, uStoneCount, uCaratSize, uTime);
    vec3  stoneC = vec3(0.90 + 0.10 * sin(uTime * 3.0 + uv.x * 10.0), 0.95, 1.0);
    color = mix(color, stoneC, stones * 0.7);

    // --- Circle mask ---
    float mask = 1.0 - smoothstep(0.48, 0.50, length(c));

    // S1 fix: no early return on mask < 0.01.
    // Buggy version did: if (mask < 0.01) { fragColor = vec4(0); return; }
    // That caused GPU warp divergence on every edge pixel (all lanes in a warp
    // that hit the edge had to wait for the ones that didn't return early).
    // Fix: multiply mask into the final alpha at output — fully branchless.
    fragColor = vec4(color * mask, alpha * mask);

    // --- Gold bevel frame composited on top ---
    vec4 bevel = goldBevelFrame(uv, uBevelDepth, uTime);
    fragColor  = vec4(mix(fragColor.rgb, bevel.rgb, bevel.a),
                      max(fragColor.a,  bevel.a));
}
