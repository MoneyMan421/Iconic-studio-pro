"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  Diamond,
  LayoutGrid,
  Package,
  Sparkles,
  Settings,
  Users,
  ShieldCheck,
  LogOut,
} from "lucide-react"
import { cn } from "@/lib/utils"

interface NavItem {
  href: string
  label: string
  icon: typeof LayoutGrid
  match?: (pathname: string) => boolean
}

const studioNav: NavItem[] = [
  { href: "/dashboard", label: "Overview", icon: LayoutGrid, match: (p) => p === "/dashboard" },
  { href: "/dashboard", label: "Icon packs", icon: Package, match: (p) => p.startsWith("/dashboard") },
  { href: "/#effects", label: "Effects", icon: Sparkles },
]

const adminNav: NavItem[] = [
  { href: "/admin", label: "Users", icon: Users, match: (p) => p === "/admin" },
  { href: "/admin/effects", label: "Effects", icon: ShieldCheck, match: (p) => p.startsWith("/admin/effects") },
]

export function AppSidebar({ variant = "studio" }: { variant?: "studio" | "admin" }) {
  const pathname = usePathname() || ""
  const items = variant === "admin" ? adminNav : studioNav
  const sectionLabel = variant === "admin" ? "Admin" : "Studio"

  return (
    <aside className="hidden w-64 shrink-0 flex-col border-r border-border/60 bg-sidebar/60 md:flex">
      <div className="flex h-16 items-center gap-2 border-b border-border/60 px-5">
        <span
          aria-hidden="true"
          className="grid size-8 place-items-center rounded-md bg-primary/15 text-primary ring-1 ring-primary/30"
        >
          <Diamond className="size-4" strokeWidth={2.25} />
        </span>
        <div className="flex flex-col leading-tight">
          <span className="text-sm font-semibold tracking-tight">Facet</span>
          <span className="text-[10px] uppercase tracking-[0.18em] text-muted-foreground">
            {sectionLabel}
          </span>
        </div>
      </div>

      <nav className="flex-1 space-y-1 p-3 text-sm">
        <p className="px-3 pb-2 pt-3 text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
          Workspace
        </p>
        {items.map((item) => {
          const active = item.match
            ? item.match(pathname)
            : pathname === item.href || pathname.startsWith(item.href + "/")
          return (
            <Link
              key={`${item.href}-${item.label}`}
              href={item.href}
              className={cn(
                "flex items-center gap-2.5 rounded-lg px-3 py-2 transition-colors",
                active
                  ? "bg-primary/10 text-foreground ring-1 ring-primary/25"
                  : "text-muted-foreground hover:bg-muted/50 hover:text-foreground",
              )}
            >
              <item.icon className="size-4" strokeWidth={2.25} />
              <span>{item.label}</span>
            </Link>
          )
        })}

        {variant === "studio" ? (
          <>
            <p className="px-3 pb-2 pt-6 text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Account
            </p>
            <Link
              href="/admin"
              className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-muted-foreground transition-colors hover:bg-muted/50 hover:text-foreground"
            >
              <ShieldCheck className="size-4" strokeWidth={2.25} />
              <span>Admin panel</span>
            </Link>
            <Link
              href="/dashboard"
              className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-muted-foreground transition-colors hover:bg-muted/50 hover:text-foreground"
            >
              <Settings className="size-4" strokeWidth={2.25} />
              <span>Settings</span>
            </Link>
          </>
        ) : null}
      </nav>

      <div className="border-t border-border/60 p-3">
        <div className="flex items-center gap-3 rounded-lg px-3 py-2.5">
          <div className="grid size-8 shrink-0 place-items-center rounded-full bg-muted text-xs font-medium">
            AD
          </div>
          <div className="min-w-0 flex-1 leading-tight">
            <p className="truncate text-sm font-medium">Ada Studio</p>
            <p className="truncate text-xs text-muted-foreground">ada@facet.studio</p>
          </div>
          <Link
            href="/login"
            aria-label="Sign out"
            className="rounded-md p-1.5 text-muted-foreground hover:bg-muted/60 hover:text-foreground"
          >
            <LogOut className="size-4" />
          </Link>
        </div>
      </div>
    </aside>
  )
}
