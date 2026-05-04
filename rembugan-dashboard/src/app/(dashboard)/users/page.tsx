"use client"

import { useEffect, useState, useMemo } from "react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Users as UsersIcon, Search, ChevronLeft, ChevronRight, UserX } from "lucide-react"
import { fetchUsers } from "@/lib/api"

interface User {
  id: string
  nim: string
  full_name: string
  email: string | null
  is_onboarded: boolean
  created_at: string
  skills?: Array<{ skill: { name: string } }>
  experiences?: Array<any>
  showcases?: Array<any>
  ownedProjects?: Array<any>
  memberships?: Array<any>
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [pagination, setPagination] = useState({ skip: 0, limit: 20, total: 0 })
  const [search, setSearch] = useState("")
  const [onboardFilter, setOnboardFilter] = useState<string>("all")

  useEffect(() => {
    loadUsers()
  }, [])

  async function loadUsers() {
    try {
      const response = await fetchUsers(0, 200)
      if (response.status === 'success') {
        setUsers(response.data)
        setPagination(prev => ({ ...prev, total: response.pagination?.total ?? response.data.length }))
      }
    } catch (error) {
      console.error('Error loading users:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredUsers = useMemo(() => {
    let result = users
    if (search) {
      const q = search.toLowerCase()
      result = result.filter(
        (u) =>
          u.full_name.toLowerCase().includes(q) ||
          u.nim.toLowerCase().includes(q) ||
          (u.email && u.email.toLowerCase().includes(q))
      )
    }
    if (onboardFilter !== "all") {
      result = result.filter((u) =>
        onboardFilter === "yes" ? u.is_onboarded : !u.is_onboarded
      )
    }
    return result
  }, [users, search, onboardFilter])

  const paginatedUsers = useMemo(() => {
    return filteredUsers.slice(pagination.skip, pagination.skip + pagination.limit)
  }, [filteredUsers, pagination.skip, pagination.limit])

  const totalPages = Math.ceil(filteredUsers.length / pagination.limit)
  const currentPage = Math.floor(pagination.skip / pagination.limit) + 1

  if (loading) {
    return (
      <>
        <div className="space-y-6">
          <div>
            <Skeleton className="h-8 w-32" />
            <Skeleton className="mt-2 h-4 w-64" />
          </div>
          <Card className="border-border/50">
            <CardHeader>
              <div className="flex gap-3">
                <Skeleton className="h-9 w-64" />
                <Skeleton className="h-9 w-36" />
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {[...Array(8)].map((_, i) => (
                  <Skeleton key={i} className="h-14 w-full" />
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </>
    )
  }

  return (
    <>
      <div className="space-y-6">
        {/* Page Header */}
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-900">
            <UsersIcon className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Users</h1>
            <p className="text-sm text-muted-foreground">
              Manage and monitor all registered users
            </p>
          </div>
          <Badge variant="secondary" className="ml-auto text-sm">
            {filteredUsers.length} total
          </Badge>
        </div>

        {/* Data Table */}
        <Card className="border-border/50">
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search by name, NIM, or email…"
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value)
                    setPagination((p) => ({ ...p, skip: 0 }))
                  }}
                  className="pl-9 bg-background"
                />
              </div>
              <Select
                value={onboardFilter}
                onValueChange={(v) => {
                  setOnboardFilter(v)
                  setPagination((p) => ({ ...p, skip: 0 }))
                }}
              >
                <SelectTrigger className="w-[160px] bg-background">
                  <SelectValue placeholder="Onboarded" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="yes">Onboarded</SelectItem>
                  <SelectItem value="no">Not Onboarded</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border/50 hover:bg-transparent">
                  <TableHead className="text-muted-foreground">NIM</TableHead>
                  <TableHead className="text-muted-foreground">Full Name</TableHead>
                  <TableHead className="text-muted-foreground">Email</TableHead>
                  <TableHead className="text-muted-foreground">Onboarded</TableHead>
                  <TableHead className="text-muted-foreground">Skills</TableHead>
                  <TableHead className="text-muted-foreground">Projects</TableHead>
                  <TableHead className="text-muted-foreground">Joined</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedUsers.length > 0 ? (
                  paginatedUsers.map((user) => (
                    <TableRow key={user.id} className="border-border/50">
                      <TableCell className="font-mono text-xs text-muted-foreground">{user.nim}</TableCell>
                      <TableCell className="font-medium">{user.full_name}</TableCell>
                      <TableCell className="text-muted-foreground">{user.email || "—"}</TableCell>
                      <TableCell>
                        <Badge
                          variant="outline"
                          className={
                            user.is_onboarded
                              ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-400"
                              : "border-amber-500/30 bg-amber-500/10 text-amber-400"
                          }
                        >
                          {user.is_onboarded ? "Yes" : "No"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                          {user.skills?.slice(0, 2).map((s, idx) => (
                            <Badge key={idx} variant="secondary" className="text-xs">
                              {s.skill.name}
                            </Badge>
                          ))}
                          {(user.skills?.length ?? 0) > 2 && (
                            <Badge variant="secondary" className="text-xs">
                              +{(user.skills?.length ?? 0) - 2}
                            </Badge>
                          )}
                          {!user.skills?.length && (
                            <span className="text-xs text-muted-foreground">—</span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {user.ownedProjects?.length || 0}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {new Date(user.created_at).toLocaleDateString()}
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <UserX className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No users found</p>
                        <p className="text-xs">Try adjusting your search or filters</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            {/* Pagination */}
            {filteredUsers.length > pagination.limit && (
              <div className="flex items-center justify-between border-t border-border/50 pt-4 mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {pagination.skip + 1}–{Math.min(pagination.skip + pagination.limit, filteredUsers.length)} of {filteredUsers.length}
                </p>
                <div className="flex items-center gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={pagination.skip === 0}
                    onClick={() => setPagination((p) => ({ ...p, skip: p.skip - p.limit }))}
                  >
                    <ChevronLeft className="h-4 w-4 mr-1" />
                    Previous
                  </Button>
                  <span className="text-sm text-muted-foreground">
                    {currentPage} / {totalPages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={pagination.skip + pagination.limit >= filteredUsers.length}
                    onClick={() => setPagination((p) => ({ ...p, skip: p.skip + p.limit }))}
                  >
                    Next
                    <ChevronRight className="h-4 w-4 ml-1" />
                  </Button>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </>
  )
}