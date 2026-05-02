import Link from "next/link"
import { Plus, Sparkles } from "lucide-react"
import { Button } from "@/components/ui/button"
import { AppTopbar } from "@/components/app-shell/app-topbar"
import { PackCard } from "@/components/dashboard/pack-card"
import { mockPacks } from "@/lib/mock-data"

export default function DashboardPage() {
  const totalIcons = mockPacks.reduce((acc, p) => acc + p.iconCount, 0)

  return (
    <>
      <AppTopbar
        title="Studio"
        subtitle="Design and ship icon packs"
        action={
          <Button size="sm">
            <Plus className="size-4" />
            New pack
          </Button>
        }
      />

      <div className="mx-auto max-w-7xl space-y-8 px-6 py-8">
        <section className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          <Stat label="Packs" value={mockPacks.length.toString()} />
          <Stat label="Icons" value={totalIcons.toString()} />
          <Stat label="Effects available" value="6" />
        </section>

        <section className="space-y-4">
          <div className="flex items-end justify-between gap-3">
            <div>
              <h2 className="text-lg font-semibold tracking-tight">Your packs</h2>
              <p className="text-sm text-muted-foreground">
                Click a pack to open the editor.
              </p>
            </div>
            <Link
              href="/#effects"
              className="hidden items-center gap-1.5 text-sm text-muted-foreground transition-colors hover:text-foreground sm:inline-flex"
            >
              <Sparkles className="size-3.5 text-primary" />
              Browse effect library
            </Link>
          </div>

          <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-3">
            {mockPacks.map((p) => (
              <PackCard key={p.id} pack={p} />
            ))}
          </div>
        </section>
      </div>
    </>
  )
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-border/60 bg-card/60 px-5 py-4">
      <p className="text-xs font-medium uppercase tracking-[0.16em] text-muted-foreground">
        {label}
      </p>
      <p className="mt-1.5 text-2xl font-semibold tracking-tight">{value}</p>
    </div>
  )
}
