"use client"

import { useMemo, useState } from "react"
import Link from "next/link"
import { ArrowLeft, Check, Download, RotateCcw } from "lucide-react"
import { effects, type EffectId } from "@/lib/effects"
import { findIcon, iconLibrary } from "@/lib/icon-library"
import type { IconPack, IconRecord, IconSize } from "@/lib/mock-data"
import { EffectCanvas } from "@/components/effect-canvas"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"
import { toast } from "sonner"

const sizeMap: Record<IconSize, number> = { sm: 96, md: 144, lg: 192, xl: 256 }
const sizeLabel: Record<IconSize, string> = { sm: "Small", md: "Medium", lg: "Large", xl: "X-Large" }

const categories = ["all", "object", "nature", "tech", "symbol", "ui"] as const

export function PackEditor({ pack }: { pack: IconPack }) {
  const [icons, setIcons] = useState<IconRecord[]>(pack.icons)
  const [selectedId, setSelectedId] = useState<string>(pack.icons[0]?.id ?? "")
  const [category, setCategory] = useState<(typeof categories)[number]>("all")

  const selected = useMemo(
    () => icons.find((i) => i.id === selectedId) ?? icons[0],
    [icons, selectedId],
  )

  const update = (patch: Partial<IconRecord>) => {
    if (!selected) return
    setIcons((prev) =>
      prev.map((i) => (i.id === selected.id ? { ...i, ...patch } : i)),
    )
  }

  const applyEffectToAll = (effect: EffectId) => {
    setIcons((prev) => prev.map((i) => ({ ...i, effect })))
    toast.success(`Applied ${effect} to all ${icons.length} icons`)
  }

  const reset = () => {
    setIcons(pack.icons)
    toast("Pack reverted to saved state")
  }

  const exportPack = () => {
    const manifest = {
      pack: { id: pack.id, name: pack.name, description: pack.description },
      icons: icons.map((i) => ({
        name: i.name,
        glyph: i.glyph,
        effect: i.effect,
        size: i.size,
        transparent: i.transparent,
      })),
    }
    const blob = new Blob([JSON.stringify(manifest, null, 2)], {
      type: "application/json",
    })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `${pack.id}.facet.json`
    a.click()
    URL.revokeObjectURL(url)
    toast.success("Pack manifest exported")
  }

  const filtered = useMemo(() => {
    if (category === "all") return iconLibrary
    return iconLibrary.filter((i) => i.category === category)
  }, [category])

  if (!selected) return null

  return (
    <>
      <div className="sticky top-0 z-30 border-b border-border/60 bg-background/70 backdrop-blur-xl">
        <div className="flex h-16 items-center gap-3 px-6">
          <Button asChild variant="ghost" size="sm" className="-ml-2">
            <Link href="/dashboard">
              <ArrowLeft className="size-4" />
              Packs
            </Link>
          </Button>
          <div className="mx-2 h-5 w-px bg-border" aria-hidden="true" />
          <div className="min-w-0 flex-1">
            <h1 className="truncate text-base font-semibold tracking-tight">{pack.name}</h1>
            <p className="truncate text-xs text-muted-foreground">{pack.description}</p>
          </div>
          <Button variant="ghost" size="sm" onClick={reset}>
            <RotateCcw className="size-4" />
            Reset
          </Button>
          <Button size="sm" onClick={exportPack}>
            <Download className="size-4" />
            Export
          </Button>
        </div>
      </div>

      <div className="grid min-h-[calc(100dvh-4rem)] grid-cols-1 gap-px bg-border/60 lg:grid-cols-[18rem_1fr_22rem]">
        {/* Library */}
        <aside className="bg-background/80">
          <div className="flex h-12 items-center border-b border-border/60 px-4">
            <p className="text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Icon library
            </p>
          </div>
          <div className="border-b border-border/60 px-3 py-3">
            <Tabs value={category} onValueChange={(v) => setCategory(v as typeof category)}>
              <TabsList className="h-auto w-full flex-wrap justify-start gap-1 bg-transparent p-0">
                {categories.map((c) => (
                  <TabsTrigger
                    key={c}
                    value={c}
                    className="h-7 rounded-full border border-transparent px-2.5 text-[11px] capitalize data-[state=active]:border-primary/40 data-[state=active]:bg-primary/10 data-[state=active]:text-foreground"
                  >
                    {c}
                  </TabsTrigger>
                ))}
              </TabsList>
            </Tabs>
          </div>
          <ScrollArea className="h-[calc(100dvh-4rem-3rem-3.25rem)]">
            <div className="grid grid-cols-3 gap-2 p-3">
              {filtered.map((lib) => {
                const inPack = icons.find((i) => i.glyph === lib.name)
                return (
                  <button
                    key={lib.name}
                    type="button"
                    onClick={() => {
                      if (inPack) {
                        setSelectedId(inPack.id)
                      } else {
                        const id = `new-${Date.now()}-${lib.name}`
                        const next: IconRecord = {
                          id,
                          name: lib.name,
                          glyph: lib.name,
                          effect: selected.effect,
                          size: selected.size,
                          transparent: true,
                        }
                        setIcons((prev) => [...prev, next])
                        setSelectedId(id)
                        toast.success(`Added ${lib.name} to pack`)
                      }
                    }}
                    className={cn(
                      "group relative flex aspect-square flex-col items-center justify-center gap-1.5 rounded-lg border bg-card/60 p-2 text-muted-foreground transition-colors",
                      inPack
                        ? "border-primary/40 text-foreground"
                        : "border-border/60 hover:border-primary/40 hover:text-foreground",
                    )}
                  >
                    <lib.Icon className="size-5" strokeWidth={2} />
                    <span className="truncate text-[10px]">{lib.name}</span>
                    {inPack ? (
                      <span className="absolute right-1 top-1 grid size-3.5 place-items-center rounded-full bg-primary text-primary-foreground">
                        <Check className="size-2.5" strokeWidth={3} />
                      </span>
                    ) : null}
                  </button>
                )
              })}
            </div>
          </ScrollArea>
        </aside>

        {/* Canvas */}
        <main className="flex flex-col bg-background">
          <div className="flex h-12 items-center justify-between border-b border-border/60 px-6">
            <p className="text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Live preview
            </p>
            <p className="text-xs text-muted-foreground">
              {icons.length} icons in pack
            </p>
          </div>

          <div className="grid flex-1 place-items-center bg-grid p-10">
            <div className="flex flex-col items-center gap-6">
              <div className="rounded-3xl border border-border/60 bg-card/40 p-10 backdrop-blur">
                <EffectCanvas
                  glyph={selected.glyph}
                  effect={selected.effect}
                  size={sizeMap[selected.size]}
                />
              </div>
              <div className="text-center">
                <p className="text-base font-semibold tracking-tight">{selected.name}</p>
                <p className="text-xs text-muted-foreground">
                  {effects.find((e) => e.id === selected.effect)?.name} ·{" "}
                  {sizeLabel[selected.size]} · {selected.transparent ? "Transparent" : "Filled"}
                </p>
              </div>
            </div>
          </div>

          {/* Pack strip */}
          <div className="border-t border-border/60 bg-card/40 px-6 py-4">
            <p className="mb-3 text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Pack contents
            </p>
            <ScrollArea className="w-full">
              <div className="flex gap-2 pb-2">
                {icons.map((i) => {
                  const lib = findIcon(i.glyph)
                  if (!lib) return null
                  const active = i.id === selected.id
                  return (
                    <button
                      key={i.id}
                      type="button"
                      onClick={() => setSelectedId(i.id)}
                      className={cn(
                        "flex shrink-0 flex-col items-center gap-1.5 rounded-lg border bg-background/80 p-2 transition-colors",
                        active
                          ? "border-primary/50 text-foreground"
                          : "border-border/60 text-muted-foreground hover:border-primary/40 hover:text-foreground",
                      )}
                    >
                      <lib.Icon className="size-5" strokeWidth={2} />
                      <span className="text-[10px]">{i.name}</span>
                    </button>
                  )
                })}
              </div>
            </ScrollArea>
          </div>
        </main>

        {/* Inspector */}
        <aside className="bg-background/80">
          <div className="flex h-12 items-center border-b border-border/60 px-5">
            <p className="text-[10px] font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Inspector
            </p>
          </div>
          <ScrollArea className="h-[calc(100dvh-4rem-3rem)]">
            <div className="space-y-6 p-5">
              <section className="space-y-3">
                <Label className="text-xs font-medium text-muted-foreground">
                  Effect
                </Label>
                <div className="grid grid-cols-2 gap-2">
                  {effects.map((eff) => {
                    const active = eff.id === selected.effect
                    return (
                      <button
                        key={eff.id}
                        type="button"
                        onClick={() => update({ effect: eff.id })}
                        className={cn(
                          "group flex flex-col items-stretch overflow-hidden rounded-lg border text-left transition-colors",
                          active
                            ? "border-primary/50 ring-1 ring-primary/30"
                            : "border-border/60 hover:border-primary/40",
                        )}
                      >
                        <div className="grid h-16 place-items-center bg-muted/40">
                          <Card className="rounded-md border-0 bg-transparent p-0 shadow-none">
                            <EffectCanvas
                              glyph={selected.glyph}
                              effect={eff.id}
                              size={48}
                              className="bg-transparent"
                            />
                          </Card>
                        </div>
                        <div className="flex items-center justify-between gap-2 border-t border-border/60 bg-card/60 px-2.5 py-2">
                          <span className="text-xs font-medium">{eff.name}</span>
                          {active ? (
                            <span className="grid size-4 place-items-center rounded-full bg-primary text-primary-foreground">
                              <Check className="size-2.5" strokeWidth={3} />
                            </span>
                          ) : null}
                        </div>
                      </button>
                    )
                  })}
                </div>
              </section>

              <section className="space-y-3">
                <Label className="text-xs font-medium text-muted-foreground">
                  Size
                </Label>
                <ToggleGroup
                  type="single"
                  value={selected.size}
                  onValueChange={(v) => v && update({ size: v as IconSize })}
                  className="grid grid-cols-4 gap-1.5"
                >
                  {(Object.keys(sizeMap) as IconSize[]).map((s) => (
                    <ToggleGroupItem
                      key={s}
                      value={s}
                      className="h-9 rounded-md border border-border/60 text-xs uppercase data-[state=on]:border-primary/50 data-[state=on]:bg-primary/10 data-[state=on]:text-foreground"
                    >
                      {s}
                    </ToggleGroupItem>
                  ))}
                </ToggleGroup>
              </section>

              <section className="flex items-center justify-between gap-3 rounded-lg border border-border/60 bg-card/60 p-3">
                <div className="space-y-0.5">
                  <Label htmlFor="transparent" className="text-sm font-medium">
                    Transparent background
                  </Label>
                  <p className="text-xs text-muted-foreground">
                    Renders with alpha for export overlays.
                  </p>
                </div>
                <Switch
                  id="transparent"
                  checked={selected.transparent}
                  onCheckedChange={(v) => update({ transparent: v })}
                />
              </section>

              <section className="space-y-3">
                <Label className="text-xs font-medium text-muted-foreground">
                  Apply effect to entire pack
                </Label>
                <Select
                  onValueChange={(v) => applyEffectToAll(v as EffectId)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Choose an effect…" />
                  </SelectTrigger>
                  <SelectContent>
                    {effects.map((e) => (
                      <SelectItem key={e.id} value={e.id}>
                        {e.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </section>

              <section className="space-y-3">
                <Label className="text-xs font-medium text-muted-foreground">
                  Export format
                </Label>
                <Select defaultValue="png">
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="png">PNG (transparent)</SelectItem>
                    <SelectItem value="jpeg">JPEG</SelectItem>
                    <SelectItem value="svg">SVG</SelectItem>
                    <SelectItem value="csv">CSV manifest</SelectItem>
                  </SelectContent>
                </Select>
                <Button onClick={exportPack} className="w-full">
                  <Download className="size-4" />
                  Export pack
                </Button>
              </section>
            </div>
          </ScrollArea>
        </aside>
      </div>
    </>
  )
}
