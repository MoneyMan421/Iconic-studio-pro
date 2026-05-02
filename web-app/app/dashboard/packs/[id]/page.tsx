import { notFound } from "next/navigation"
import { findPack, mockPacks } from "@/lib/mock-data"
import { PackEditor } from "@/components/dashboard/pack-editor"

export function generateStaticParams() {
  return mockPacks.map((p) => ({ id: p.id }))
}

export default async function PackEditorPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const pack = findPack(id)
  if (!pack) notFound()

  return <PackEditor pack={pack} />
}
