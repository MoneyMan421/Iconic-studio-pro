import Link from "next/link"
import { Check } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"

const tiers = [
  {
    name: "Starter",
    price: "Free",
    blurb: "For solo designers exploring the effect library.",
    features: ["Up to 3 packs", "All 6 effects", "PNG + SVG export", "Community support"],
    cta: "Start free",
    highlighted: false,
  },
  {
    name: "Studio",
    price: "$24",
    suffix: "/mo",
    blurb: "For product teams shipping branded icon systems.",
    features: [
      "Unlimited packs",
      "Custom shader uploads",
      "Team workspaces",
      "Priority support",
      "Audit logs",
    ],
    cta: "Open the studio",
    highlighted: true,
  },
  {
    name: "Enterprise",
    price: "Custom",
    blurb: "SSO, on-prem rendering, and white-label exports.",
    features: ["SAML / SSO", "Self-hosted runner", "Dedicated success manager", "SLA"],
    cta: "Contact sales",
    highlighted: false,
  },
]

export function Pricing() {
  return (
    <section id="pricing" className="border-b border-border/60">
      <div className="mx-auto max-w-7xl px-6 py-20 md:py-28">
        <div className="mb-14 flex flex-col items-start justify-between gap-4 md:flex-row md:items-end">
          <div className="max-w-2xl">
            <p className="mb-3 text-xs font-medium uppercase tracking-[0.2em] text-primary">
              Pricing
            </p>
            <h2 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl">
              Simple, predictable, premium.
            </h2>
          </div>
          <p className="max-w-md text-pretty text-sm leading-relaxed text-muted-foreground">
            Try every effect on the free plan. Upgrade when your team is ready to ship.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
          {tiers.map((t) => (
            <Card
              key={t.name}
              className={
                t.highlighted
                  ? "relative overflow-hidden border-primary/50 bg-card shadow-[0_0_0_1px_var(--primary)]"
                  : "border-border/60 bg-card/60"
              }
            >
              {t.highlighted ? (
                <div
                  className="absolute inset-0 -z-10 bg-gradient-to-b from-primary/10 to-transparent"
                  aria-hidden="true"
                />
              ) : null}
              <CardContent className="flex flex-col gap-6 p-6">
                <div className="flex items-baseline justify-between">
                  <h3 className="text-lg font-semibold tracking-tight">{t.name}</h3>
                  {t.highlighted ? (
                    <span className="rounded-full border border-primary/40 bg-primary/10 px-2 py-0.5 text-[10px] font-medium uppercase tracking-wider text-primary">
                      Popular
                    </span>
                  ) : null}
                </div>
                <div className="flex items-baseline gap-1">
                  <span className="text-4xl font-semibold tracking-tight">{t.price}</span>
                  {t.suffix ? (
                    <span className="text-sm text-muted-foreground">{t.suffix}</span>
                  ) : null}
                </div>
                <p className="text-sm text-muted-foreground">{t.blurb}</p>
                <ul className="space-y-2.5">
                  {t.features.map((f) => (
                    <li key={f} className="flex items-center gap-2.5 text-sm">
                      <Check className="size-4 text-primary" strokeWidth={2.5} />
                      <span>{f}</span>
                    </li>
                  ))}
                </ul>
                <Button asChild variant={t.highlighted ? "default" : "outline"} className="w-full">
                  <Link href="/dashboard">{t.cta}</Link>
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
