"use client"

import { useState } from "react"
import { Plus } from "lucide-react"
import { effects as seedEffects, type EffectDefinition } from "@/lib/effects"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  Field,
  FieldGroup,
  FieldLabel,
  FieldDescription,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { EffectCanvas } from "@/components/effect-canvas"
import { toast } from "sonner"

interface EffectRow extends EffectDefinition {
  /** ISO timestamp for the row's createdAt — only stored client-side here. */
  createdAt: string
}

export function EffectsManager() {
  const [rows, setRows] = useState<EffectRow[]>(
    seedEffects.map((e, idx) => ({
      ...e,
      createdAt: new Date(Date.now() - idx * 86_400_000 * 6).toISOString(),
    })),
  )
  const [open, setOpen] = useState(false)
  const [name, setName] = useState("")
  const [description, setDescription] = useState("")
  const [shader, setShader] = useState("")

  const onSave = (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      toast.error("Name is required")
      return
    }
    if (rows.some((r) => r.name.toLowerCase() === name.trim().toLowerCase())) {
      toast.error("Effect name already exists")
      return
    }
    const id = name.trim().toLowerCase().replace(/\s+/g, "-") as EffectRow["id"]
    setRows((prev) => [
      {
        id,
        name: name.trim(),
        description: description.trim() || "Custom shader",
        swatch: "oklch(0.78 0.16 162)",
        animated: false,
        fragmentShader: shader,
        createdAt: new Date().toISOString(),
      } as EffectRow,
      ...prev,
    ])
    setName("")
    setDescription("")
    setShader("")
    setOpen(false)
    toast.success("Effect saved")
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-muted-foreground">
            Manage shader presets available to studio users.
          </p>
        </div>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button size="sm">
              <Plus className="size-4" />
              New effect
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-2xl">
            <DialogHeader>
              <DialogTitle>Create effect</DialogTitle>
              <DialogDescription>
                Add a new GLSL fragment shader. Once saved it&apos;s available to all studio users.
              </DialogDescription>
            </DialogHeader>
            <form onSubmit={onSave}>
              <FieldGroup>
                <Field>
                  <FieldLabel htmlFor="effect-name">Name</FieldLabel>
                  <Input
                    id="effect-name"
                    placeholder="e.g. Topaz V2"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                  />
                </Field>
                <Field>
                  <FieldLabel htmlFor="effect-desc">Description</FieldLabel>
                  <Textarea
                    id="effect-desc"
                    placeholder="What this effect is best used for"
                    rows={2}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                  />
                </Field>
                <Field>
                  <FieldLabel htmlFor="effect-shader">Fragment shader</FieldLabel>
                  <Textarea
                    id="effect-shader"
                    placeholder="precision mediump float; ..."
                    rows={8}
                    className="font-mono text-xs"
                    value={shader}
                    onChange={(e) => setShader(e.target.value)}
                  />
                  <FieldDescription>
                    Sample texture from <code className="font-mono">uTexture</code> using <code className="font-mono">vUv</code>.
                  </FieldDescription>
                </Field>
              </FieldGroup>
              <DialogFooter className="mt-6">
                <Button type="button" variant="ghost" onClick={() => setOpen(false)}>
                  Cancel
                </Button>
                <Button type="submit">Save effect</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-3">
        {rows.map((row) => (
          <Card key={row.id} className="border-border/60 bg-card/60">
            <CardContent className="flex flex-col gap-4 p-5">
              <div className="flex h-32 items-center justify-center rounded-xl border border-border/60 bg-muted/40">
                <EffectCanvas glyph="Diamond" effect={row.id} size={96} className="bg-transparent" />
              </div>
              <div className="space-y-1.5">
                <div className="flex items-center justify-between gap-2">
                  <h3 className="text-base font-semibold tracking-tight">{row.name}</h3>
                  {row.animated ? (
                    <Badge className="border-primary/30 bg-primary/15 text-primary hover:bg-primary/15">
                      Animated
                    </Badge>
                  ) : (
                    <Badge variant="secondary">Static</Badge>
                  )}
                </div>
                <p className="line-clamp-2 text-sm leading-relaxed text-muted-foreground">
                  {row.description}
                </p>
              </div>
              <p className="text-xs text-muted-foreground">
                Created {new Date(row.createdAt).toLocaleDateString()}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}
