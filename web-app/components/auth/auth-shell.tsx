import Link from "next/link"
import { Diamond } from "lucide-react"
import { EffectCanvas } from "@/components/effect-canvas"

interface AuthShellProps {
  title: string
  subtitle: string
  children: React.ReactNode
  footer: React.ReactNode
}

export function AuthShell({ title, subtitle, children, footer }: AuthShellProps) {
  return (
    <div className="grid min-h-dvh lg:grid-cols-2">
      {/* Form */}
      <div className="relative flex flex-col">
        <div className="flex items-center justify-between p-6">
          <Link href="/" className="flex items-center gap-2">
            <span className="grid size-8 place-items-center rounded-md bg-primary/15 text-primary ring-1 ring-primary/30">
              <Diamond className="size-4" strokeWidth={2.25} />
            </span>
            <span className="font-semibold tracking-tight">Facet</span>
          </Link>
          <Link
            href="/"
            className="text-sm text-muted-foreground transition-colors hover:text-foreground"
          >
            ← Back to site
          </Link>
        </div>

        <div className="flex flex-1 items-center justify-center px-6 pb-16">
          <div className="w-full max-w-sm space-y-8">
            <div className="space-y-2">
              <h1 className="text-balance text-3xl font-semibold tracking-tight">{title}</h1>
              <p className="text-pretty text-sm text-muted-foreground">{subtitle}</p>
            </div>
            {children}
            <p className="text-center text-sm text-muted-foreground">{footer}</p>
          </div>
        </div>
      </div>

      {/* Marketing panel */}
      <div className="relative hidden overflow-hidden border-l border-border/60 bg-card/40 lg:block">
        <div className="bg-grid bg-radial-spot absolute inset-0 opacity-70" aria-hidden="true" />
        <div className="relative flex h-full flex-col justify-between p-12">
          <div className="flex flex-wrap gap-3">
            {(["diamond", "ruby", "glass", "neon", "chrome", "hologram"] as const).map((eff, i) => {
              const glyph = ["Diamond", "Gem", "Aperture", "Zap", "Star", "Sparkles"][i]
              return (
                <div
                  key={eff}
                  className="rounded-2xl border border-border/60 bg-background/60 p-3 backdrop-blur"
                >
                  <EffectCanvas glyph={glyph} effect={eff} size={84} className="bg-transparent" />
                </div>
              )
            })}
          </div>
          <div className="space-y-4">
            <p className="text-xs font-medium uppercase tracking-[0.2em] text-primary">
              Welcome to Facet
            </p>
            <h2 className="max-w-md text-balance text-3xl font-semibold tracking-tight">
              The studio for icon packs that look like jewelry.
            </h2>
            <p className="max-w-md text-pretty text-sm leading-relaxed text-muted-foreground">
              Six WebGL effects, instant preview, transparent exports. Bring the polish of a
              motion design studio to your product&apos;s UI.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
