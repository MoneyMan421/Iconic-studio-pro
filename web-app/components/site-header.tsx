import Link from "next/link"
import { Diamond } from "lucide-react"
import { Button } from "@/components/ui/button"

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-border/60 bg-background/70 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between gap-4 px-6">
        <Link href="/" className="flex items-center gap-2">
          <span
            aria-hidden="true"
            className="grid size-8 place-items-center rounded-md bg-primary/15 text-primary ring-1 ring-primary/30"
          >
            <Diamond className="size-4" strokeWidth={2.25} />
          </span>
          <span className="text-base font-semibold tracking-tight">Facet</span>
          <span className="ml-2 hidden rounded-full border border-border/70 bg-muted/40 px-2 py-0.5 text-[10px] font-medium uppercase tracking-wider text-muted-foreground sm:inline-block">
            Studio
          </span>
        </Link>

        <nav className="hidden items-center gap-7 text-sm text-muted-foreground md:flex">
          <Link href="/#effects" className="transition-colors hover:text-foreground">
            Effects
          </Link>
          <Link href="/#workflow" className="transition-colors hover:text-foreground">
            Workflow
          </Link>
          <Link href="/#pricing" className="transition-colors hover:text-foreground">
            Pricing
          </Link>
          <Link href="/admin" className="transition-colors hover:text-foreground">
            Admin
          </Link>
        </nav>

        <div className="flex items-center gap-2">
          <Button asChild variant="ghost" size="sm" className="hidden sm:inline-flex">
            <Link href="/login">Sign in</Link>
          </Button>
          <Button asChild size="sm">
            <Link href="/dashboard">Open studio</Link>
          </Button>
        </div>
      </div>
    </header>
  )
}
