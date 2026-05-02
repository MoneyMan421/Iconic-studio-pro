// Catalog of WebGL fragment shader effects applied to icon textures.
// Each effect samples the incoming icon texture (`uTexture`) and uses the
// alpha channel as a mask for the icon silhouette. Optional `uTime` enables
// animated effects (currently used by the hologram preset).

export type EffectId =
  | "diamond"
  | "ruby"
  | "glass"
  | "neon"
  | "chrome"
  | "hologram"

export interface EffectDefinition {
  id: EffectId
  name: string
  description: string
  /** Display swatch color used in pickers and previews. */
  swatch: string
  /** Whether the shader animates (uses uTime). */
  animated: boolean
  fragmentShader: string
}

const VARYING = `precision mediump float;
varying vec2 vUv;
uniform sampler2D uTexture;`

export const effects: EffectDefinition[] = [
  {
    id: "diamond",
    name: "Diamond",
    description: "Faceted, sparkling highlight that catches the light.",
    swatch: "oklch(0.92 0.05 220)",
    animated: false,
    fragmentShader: `${VARYING}
void main() {
  vec4 base = texture2D(uTexture, vUv);
  if (base.a < 0.02) discard;
  float facetX = abs(sin(vUv.x * 24.0));
  float facetY = abs(cos(vUv.y * 24.0));
  float sparkle = pow((facetX + facetY) * 0.5, 3.0);
  vec3 tint = vec3(0.78, 0.88, 1.0);
  vec3 color = mix(tint, vec3(1.0), sparkle);
  gl_FragColor = vec4(color, base.a);
}`,
  },
  {
    id: "ruby",
    name: "Ruby",
    description: "Deep crimson gem with a warm inner glow.",
    swatch: "oklch(0.62 0.2 25)",
    animated: false,
    fragmentShader: `${VARYING}
void main() {
  vec4 base = texture2D(uTexture, vUv);
  if (base.a < 0.02) discard;
  vec2 c = vUv - 0.5;
  float dist = length(c);
  float glow = smoothstep(0.5, 0.0, dist);
  vec3 ruby = vec3(0.78, 0.06, 0.18);
  ruby += glow * vec3(0.5, 0.12, 0.12);
  gl_FragColor = vec4(ruby, base.a);
}`,
  },
  {
    id: "glass",
    name: "Glass",
    description: "Frosted glassmorphism with subtle refraction.",
    swatch: "oklch(0.88 0.04 220)",
    animated: false,
    fragmentShader: `${VARYING}
float random(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}
void main() {
  vec2 offset = (random(vUv * 50.0) - 0.5) * 0.012;
  vec4 base = texture2D(uTexture, vUv + offset);
  if (base.a < 0.02) discard;
  float vignette = smoothstep(0.95, 0.35, length(vUv - 0.5));
  vec3 glass = mix(vec3(0.95, 0.97, 1.0), vec3(0.7, 0.85, 0.95), 0.6);
  glass *= vignette;
  gl_FragColor = vec4(glass, base.a * 0.92);
}`,
  },
  {
    id: "neon",
    name: "Neon",
    description: "Bright neon outline with a saturated halo.",
    swatch: "oklch(0.85 0.18 165)",
    animated: false,
    fragmentShader: `${VARYING}
void main() {
  vec4 base = texture2D(uTexture, vUv);
  if (base.a < 0.02) discard;
  vec3 neon = vec3(0.18, 1.0, 0.74);
  vec3 color = mix(neon * 0.55, neon, base.a);
  gl_FragColor = vec4(color, base.a);
}`,
  },
  {
    id: "chrome",
    name: "Chrome",
    description: "Polished metallic finish with horizontal banding.",
    swatch: "oklch(0.85 0.01 240)",
    animated: false,
    fragmentShader: `${VARYING}
void main() {
  vec4 base = texture2D(uTexture, vUv);
  if (base.a < 0.02) discard;
  float stripe = sin(vUv.y * 32.0) * 0.5 + 0.5;
  vec3 chrome = mix(vec3(0.22, 0.24, 0.28), vec3(0.94, 0.95, 0.98), stripe);
  gl_FragColor = vec4(chrome, base.a);
}`,
  },
  {
    id: "hologram",
    name: "Hologram",
    description: "Iridescent, animated holographic shimmer.",
    swatch: "oklch(0.78 0.16 300)",
    animated: true,
    fragmentShader: `${VARYING}
uniform float uTime;
void main() {
  vec4 base = texture2D(uTexture, vUv);
  if (base.a < 0.02) discard;
  float angle = vUv.x * 6.2831 + vUv.y * 3.1415 + uTime * 0.6;
  float shift = sin(angle) * 0.5 + 0.5;
  vec3 a = vec3(0.4, 0.2, 1.0);
  vec3 b = vec3(0.1, 1.0, 0.95);
  vec3 holo = mix(a, b, shift);
  gl_FragColor = vec4(holo, base.a);
}`,
  },
]

export const effectsById: Record<EffectId, EffectDefinition> = effects.reduce(
  (acc, eff) => {
    acc[eff.id] = eff
    return acc
  },
  {} as Record<EffectId, EffectDefinition>,
)

export function getEffect(id: EffectId | string | undefined): EffectDefinition {
  if (id && id in effectsById) return effectsById[id as EffectId]
  return effectsById.diamond
}
