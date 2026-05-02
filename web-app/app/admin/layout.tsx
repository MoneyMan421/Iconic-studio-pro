import { AppSidebar } from "@/components/app-shell/app-sidebar"

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-dvh">
      <AppSidebar variant="admin" />
      <div className="min-w-0 flex-1">{children}</div>
    </div>
  )
}
