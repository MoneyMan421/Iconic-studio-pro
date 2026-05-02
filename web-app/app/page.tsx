import { SiteHeader } from "@/components/site-header"
import { SiteFooter } from "@/components/site-footer"
import { Hero } from "@/components/landing/hero"
import { EffectsShowcase } from "@/components/landing/effects-showcase"
import { Workflow } from "@/components/landing/workflow"
import { Pricing } from "@/components/landing/pricing"

export default function HomePage() {
  return (
    <main className="min-h-dvh">
      <SiteHeader />
      <Hero />
      <EffectsShowcase />
      <Workflow />
      <Pricing />
      <SiteFooter />
    </main>
  )
}
