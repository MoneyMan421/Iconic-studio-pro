import Link from "next/link"
import { Diamond } from "lucide-react"

export function SiteFooter() {
  return (
    <footer className="border-t border-border/60 bg-card/30">
      <div className="mx-auto flex max-w-7xl flex-col items-start justify-between gap-8 px-6 py-12 md:flex-row md:items-center">
        <div className="flex items-center gap-2">
          <span className="grid size-8 place-items-center rounded-md bg-primary/15 text-primary ring-1 ring-primary/30">
            <Diamond className="size-4" strokeWidth={2.25} />
          </span>
          <span className="font-semibold tracking-tight">Facet</span>
          <span className="ml-3 text-sm text-muted-foreground">© {new Date().getFullYear()}</span>
        </div>
        <nav className="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-muted-foreground">
          <Link href="/dashboard" className="hover:text-foreground">Studio</Link>
          <Link href="/admin" className="hover:text-foreground">Admin</Link>
          <Link href="/login" className="hover:text-foreground">Sign in</Link>
          <Link href="/#effects" className="hover:text-foreground">Effects</Link>
          <Link href="/#pricing" className="hover:text-foreground">Pricing</Link>
        </nav>
      </div>
    </footer>
  )
}
