import { FileImage, Layers, ShieldCheck, Wand2 } from "lucide-react"

const features = [
  {
    icon: Layers,
    title: "Pack-first workflow",
    body:
      "Group icons into packs, version them, and switch effects across an entire pack with one toggle. Bulk-edit size, transparency, and stroke.",
  },
  {
    icon: Wand2,
    title: "Real-time WebGL preview",
    body:
      "Effects render on the GPU, so swapping between diamond, ruby, glass, neon, chrome and hologram is instant — even at 4K.",
  },
  {
    icon: FileImage,
    title: "Export anywhere",
    body:
      "Ship pristine SVG, transparent PNG, JPEG, and CSV manifests. Pack-level metadata travels with every export.",
  },
  {
    icon: ShieldCheck,
    title: "Admin-grade control",
    body:
      "Granular roles, per-effect access, and audit trails for teams. Built on hashed credentials, JWT sessions, and rate limiting.",
  },
]

export function Workflow() {
  return (
    <section id="workflow" className="border-b border-border/60">
      <div className="mx-auto max-w-7xl px-6 py-20 md:py-28">
        <div className="mb-14 max-w-2xl">
          <p className="mb-3 text-xs font-medium uppercase tracking-[0.2em] text-primary">
            How it works
          </p>
          <h2 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl md:text-5xl">
            From blank canvas to shipped pack in under a minute.
          </h2>
        </div>

        <div className="grid grid-cols-1 gap-px overflow-hidden rounded-2xl border border-border/60 bg-border/60 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((f) => (
            <div key={f.title} className="bg-card/60 p-6">
              <span className="mb-5 inline-grid size-9 place-items-center rounded-lg bg-primary/15 text-primary ring-1 ring-primary/30">
                <f.icon className="size-4" strokeWidth={2.25} />
              </span>
              <h3 className="mb-2 text-base font-semibold tracking-tight">{f.title}</h3>
              <p className="text-sm leading-relaxed text-muted-foreground">{f.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
