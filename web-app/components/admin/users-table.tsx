"use client"

import { useState } from "react"
import { MoreHorizontal, Search } from "lucide-react"
import { mockUsers, type AdminUser } from "@/lib/mock-data"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { toast } from "sonner"

function fmtDate(iso: string) {
  return new Date(iso).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric",
  })
}

export function UsersTable() {
  const [users, setUsers] = useState<AdminUser[]>(mockUsers)
  const [query, setQuery] = useState("")

  const setRole = (id: number, role: AdminUser["role"]) => {
    setUsers((prev) =>
      prev.map((u) => (u.id === id ? { ...u, role } : u)),
    )
    toast.success(`Role updated to ${role}`)
  }

  const removeUser = (id: number) => {
    setUsers((prev) => prev.filter((u) => u.id !== id))
    toast("User removed")
  }

  const filtered = users.filter((u) =>
    u.email.toLowerCase().includes(query.toLowerCase()),
  )

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="w-full max-w-sm">
          <InputGroup>
            <InputGroupAddon>
              <Search className="size-4" />
            </InputGroupAddon>
            <InputGroupInput
              placeholder="Search by email…"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </InputGroup>
        </div>
        <p className="ml-auto text-sm text-muted-foreground">
          {filtered.length} of {users.length}
        </p>
      </div>

      <div className="overflow-hidden rounded-xl border border-border/60 bg-card/40">
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
              <TableHead className="text-right">Packs</TableHead>
              <TableHead>Joined</TableHead>
              <TableHead className="w-12"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((u) => (
              <TableRow key={u.id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <div className="grid size-8 place-items-center rounded-full bg-muted text-xs font-medium uppercase">
                      {u.email.slice(0, 2)}
                    </div>
                    <span className="font-medium">{u.email}</span>
                  </div>
                </TableCell>
                <TableCell>
                  {u.role === "admin" ? (
                    <Badge className="border-primary/30 bg-primary/15 text-primary hover:bg-primary/15">
                      Admin
                    </Badge>
                  ) : (
                    <Badge variant="secondary">User</Badge>
                  )}
                </TableCell>
                <TableCell className="text-right tabular-nums">{u.packs}</TableCell>
                <TableCell className="text-muted-foreground">{fmtDate(u.createdAt)}</TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon" aria-label="Actions">
                        <MoreHorizontal className="size-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem onClick={() => setRole(u.id, "user")}>
                        Set as user
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => setRole(u.id, "admin")}>
                        Promote to admin
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem
                        onClick={() => removeUser(u.id)}
                        className="text-destructive focus:text-destructive"
                      >
                        Remove user
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
