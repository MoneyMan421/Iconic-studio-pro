import { AppTopbar } from "@/components/app-shell/app-topbar"
import { UsersTable } from "@/components/admin/users-table"
import { mockUsers } from "@/lib/mock-data"

export default function AdminUsersPage() {
  const admins = mockUsers.filter((u) => u.role === "admin").length

  return (
    <>
      <AppTopbar
        title="Users"
        subtitle={`${mockUsers.length} accounts · ${admins} admins`}
      />
      <div className="mx-auto max-w-7xl space-y-6 px-6 py-8">
        <section className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          <Stat label="Total users" value={mockUsers.length.toString()} />
          <Stat label="Admins" value={admins.toString()} />
          <Stat
            label="Total packs"
            value={mockUsers.reduce((acc, u) => acc + u.packs, 0).toString()}
          />
        </section>
        <UsersTable />
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
