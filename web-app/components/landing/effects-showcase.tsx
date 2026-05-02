import { effects } from "@/lib/effects"
import { EffectCanvas } from "@/components/effect-canvas"
import { Card, CardContent } from "@/components/ui/card"

const featureGlyphs: Record<string, string> = {
  diamond: "Diamond",
  ruby: "Gem",
  glass: "Aperture",
  neon: "Zap",
  chrome: "Star",
  hologram: "Sparkles",
}

export function EffectsShowcase() {
  return (
    <section id="effects" className="border-b border-border/60 bg-card/30">
      <div className="mx-auto max-w-7xl px-6 py-20 md:py-28">
        <div className="mb-14 flex flex-col items-start justify-between gap-4 md:flex-row md:items-end">
          <div className="max-w-2xl">
            <p className="mb-3 text-xs font-medium uppercase tracking-[0.2em] text-primary">
              Shader library
            </p>
            <h2 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl">
              Six production-ready effects. Real WebGL, not Photoshop filters.
            </h2>
          </div>
          <p className="max-w-md text-pretty text-sm leading-relaxed text-muted-foreground">
            Each effect is a hand-tuned GLSL fragment shader. Toggle one with a click; preview
            updates in real time on a transparent canvas, ready to export.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {effects.map((eff) => (
            <Card
              key={eff.id}
              className="group overflow-hidden border-border/60 bg-background/60 transition-colors hover:border-primary/50"
            >
              <CardContent className="flex flex-col gap-5 p-5">
                <div className="relative flex h-44 items-center justify-center rounded-xl border border-border/60 bg-muted/40">
                  <EffectCanvas glyph={featureGlyphs[eff.id]} effect={eff.id} size={140} className="bg-transparent" />
                  <span className="absolute right-3 top-3 flex items-center gap-1.5 rounded-full border border-border/70 bg-background/80 px-2 py-0.5 text-[10px] font-medium uppercase tracking-wider text-muted-foreground">
                    <span
                      className="size-1.5 rounded-full"
                      style={{ background: eff.swatch }}
                      aria-hidden="true"
                    />
                    {eff.animated ? "Animated" : "Static"}
                  </span>
                </div>
                <div className="space-y-1.5">
                  <h3 className="text-lg font-semibold tracking-tight">{eff.name}</h3>
                  <p className="text-sm leading-relaxed text-muted-foreground">{eff.description}</p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
