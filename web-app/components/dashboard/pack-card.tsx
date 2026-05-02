import Link from "next/link"
import { ArrowUpRight } from "lucide-react"
import type { IconPack } from "@/lib/mock-data"
import { EffectCanvas } from "@/components/effect-canvas"
import { Card } from "@/components/ui/card"

function relativeDate(iso: string) {
  const ms = Date.now() - new Date(iso).getTime()
  const day = 86_400_000
  if (ms < day) return "today"
  const days = Math.round(ms / day)
  if (days < 30) return `${days}d ago`
  const months = Math.round(days / 30)
  return `${months}mo ago`
}

export function PackCard({ pack }: { pack: IconPack }) {
  return (
    <Card className="group relative overflow-hidden border-border/60 bg-card/60 transition-colors hover:border-primary/50">
      <Link
        href={`/dashboard/packs/${pack.id}`}
        className="flex flex-col gap-4 p-5"
      >
        <div className="flex h-40 items-center justify-center rounded-xl border border-border/60 bg-muted/40">
          <EffectCanvas
            glyph={pack.cover.glyph}
            effect={pack.cover.effect}
            size={130}
            className="bg-transparent"
          />
        </div>

        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0 space-y-1">
            <h3 className="truncate text-base font-semibold tracking-tight">{pack.name}</h3>
            <p className="line-clamp-2 text-sm leading-relaxed text-muted-foreground">
              {pack.description}
            </p>
          </div>
          <ArrowUpRight className="size-4 shrink-0 text-muted-foreground transition-colors group-hover:text-primary" />
        </div>

        <div className="flex items-center justify-between text-xs text-muted-foreground">
          <span>{pack.iconCount} icons</span>
          <span>Updated {relativeDate(pack.updatedAt)}</span>
        </div>
      </Link>
    </Card>
  )
}
