import Link from "next/link"
import { Bell, Search } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"

interface AppTopbarProps {
  title: string
  subtitle?: string
  action?: React.ReactNode
}

export function AppTopbar({ title, subtitle, action }: AppTopbarProps) {
  return (
    <div className="sticky top-0 z-30 border-b border-border/60 bg-background/70 backdrop-blur-xl">
      <div className="flex h-16 items-center gap-3 px-6">
        <div className="min-w-0 flex-1">
          <h1 className="truncate text-base font-semibold tracking-tight">{title}</h1>
          {subtitle ? (
            <p className="truncate text-xs text-muted-foreground">{subtitle}</p>
          ) : null}
        </div>

        <div className="hidden w-72 sm:block">
          <InputGroup>
            <InputGroupAddon>
              <Search className="size-4" />
            </InputGroupAddon>
            <InputGroupInput placeholder="Search packs, icons…" />
          </InputGroup>
        </div>

        <Button variant="ghost" size="icon" aria-label="Notifications" asChild>
          <Link href="#">
            <Bell className="size-4" />
          </Link>
        </Button>

        {action}
      </div>
    </div>
  )
}
