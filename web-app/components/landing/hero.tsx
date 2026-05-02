import Link from "next/link"
import { ArrowRight, Sparkles } from "lucide-react"
import { Button } from "@/components/ui/button"
import { EffectCanvas } from "@/components/effect-canvas"

export function Hero() {
  return (
    <section className="relative overflow-hidden border-b border-border/60">
      <div className="bg-grid bg-radial-spot absolute inset-0 -z-10 opacity-60" aria-hidden="true" />
      <div className="absolute inset-x-0 top-0 -z-10 h-px bg-gradient-to-r from-transparent via-primary/40 to-transparent" aria-hidden="true" />

      <div className="mx-auto flex max-w-7xl flex-col items-center gap-12 px-6 py-20 text-center md:py-28">
        <span className="inline-flex items-center gap-2 rounded-full border border-border/70 bg-card/60 px-3 py-1 text-xs font-medium text-muted-foreground backdrop-blur">
          <Sparkles className="size-3.5 text-primary" />
          New: animated hologram shader is live
        </span>

        <div className="max-w-3xl space-y-6">
          <h1 className="text-balance text-5xl font-semibold tracking-tight sm:text-6xl md:text-7xl">
            Icon packs that look like
            <span className="bg-gradient-to-r from-foreground to-primary bg-clip-text text-transparent"> jewelry.</span>
          </h1>
          <p className="mx-auto max-w-2xl text-pretty text-base leading-relaxed text-muted-foreground sm:text-lg">
            Facet is a studio for crafting elite icon packs. Apply real WebGL effects—diamond, ruby,
            glassmorphism, neon, chrome, hologram—then export crisp assets in seconds. Built for
            product teams that ship.
          </p>
        </div>

        <div className="flex flex-wrap items-center justify-center gap-3">
          <Button asChild size="lg" className="h-11 px-6">
            <Link href="/dashboard">
              Open the studio
              <ArrowRight className="size-4" />
            </Link>
          </Button>
          <Button asChild size="lg" variant="outline" className="h-11 px-6">
            <Link href="/#effects">See the effects</Link>
          </Button>
        </div>

        <HeroShowcase />
      </div>
    </section>
  )
}

function HeroShowcase() {
  const tiles: Array<{ glyph: string; effect: "diamond" | "ruby" | "glass" | "neon" | "chrome" | "hologram"; label: string }> = [
    { glyph: "Diamond", effect: "diamond", label: "Diamond" },
    { glyph: "Gem", effect: "ruby", label: "Ruby" },
    { glyph: "Aperture", effect: "glass", label: "Glass" },
    { glyph: "Zap", effect: "neon", label: "Neon" },
    { glyph: "Star", effect: "chrome", label: "Chrome" },
    { glyph: "Sparkles", effect: "hologram", label: "Hologram" },
  ]

  return (
    <div className="relative mt-4 w-full max-w-5xl">
      <div className="absolute -inset-x-6 -inset-y-3 rounded-[2rem] bg-gradient-to-b from-primary/10 to-transparent blur-2xl" aria-hidden="true" />
      <div className="relative grid grid-cols-2 gap-3 rounded-3xl border border-border/70 bg-card/50 p-4 backdrop-blur sm:grid-cols-3 lg:grid-cols-6">
        {tiles.map((t) => (
          <div
            key={t.label}
            className="group flex flex-col items-center gap-3 rounded-2xl border border-border/60 bg-background/70 p-4 transition-colors hover:border-primary/50"
          >
            <EffectCanvas glyph={t.glyph} effect={t.effect} size={120} className="rounded-xl" />
            <span className="text-xs font-medium text-muted-foreground transition-colors group-hover:text-foreground">
              {t.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  )
}
