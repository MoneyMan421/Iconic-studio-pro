import { AppTopbar } from "@/components/app-shell/app-topbar"
import { EffectsManager } from "@/components/admin/effects-manager"
import { effects } from "@/lib/effects"

export default function AdminEffectsPage() {
  return (
    <>
      <AppTopbar
        title="Effects"
        subtitle={`${effects.length} shaders available to the studio`}
      />
      <div className="mx-auto max-w-7xl px-6 py-8">
        <EffectsManager />
      </div>
    </>
  )
}
