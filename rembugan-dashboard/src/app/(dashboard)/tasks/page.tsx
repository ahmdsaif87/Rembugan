"use client"

import { useEffect, useState, useMemo } from "react"

import { Card, CardContent, CardHeader } from "@/components/ui/card"
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
import { ListChecks, Search, ChevronLeft, ChevronRight, ClipboardX } from "lucide-react"
import { fetchTasks } from "@/lib/api"

interface Task {
  id: number
  project_id: number
  assignee_id: string | null
  title: string
  status: string
  deadline: string | null
  created_at: string
  project?: { title: string }
  assignee?: { full_name: string }
}

const statusColors: Record<string, string> = {
  todo: "border-slate-500/30 bg-slate-500/10 text-slate-400",
  doing: "border-amber-500/30 bg-amber-500/10 text-amber-400",
  done: "border-emerald-500/30 bg-emerald-500/10 text-emerald-400",
}

export default function TasksPage() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [pagination, setPagination] = useState({ skip: 0, limit: 20, total: 0 })
  const [search, setSearch] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadTasks()
  }, [])

  async function loadTasks() {
    try {
      const response = await fetchTasks(0, 200)
      if (response.status === 'success') {
        setTasks(response.data)
        setPagination(prev => ({ ...prev, total: response.pagination?.total ?? response.data.length }))
      }
    } catch (error) {
      console.error('Error loading tasks:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredTasks = useMemo(() => {
    let result = tasks
    if (search) {
      const q = search.toLowerCase()
      result = result.filter(
        (t) =>
          t.title.toLowerCase().includes(q) ||
          t.project?.title?.toLowerCase().includes(q) ||
          t.assignee?.full_name?.toLowerCase().includes(q)
      )
    }
    if (statusFilter !== "all") {
      result = result.filter((t) => t.status === statusFilter)
    }
    return result
  }, [tasks, search, statusFilter])

  const paginatedTasks = useMemo(() => {
    return filteredTasks.slice(pagination.skip, pagination.skip + pagination.limit)
  }, [filteredTasks, pagination.skip, pagination.limit])

  const totalPages = Math.ceil(filteredTasks.length / pagination.limit)
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
            <ListChecks className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Tasks</h1>
            <p className="text-sm text-muted-foreground">
              All project tasks across the platform
            </p>
          </div>
          <Badge variant="secondary" className="ml-auto text-sm">
            {filteredTasks.length} total
          </Badge>
        </div>

        {/* Data Table */}
        <Card className="border-border/50">
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search tasks…"
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value)
                    setPagination((p) => ({ ...p, skip: 0 }))
                  }}
                  className="pl-9 bg-background"
                />
              </div>
              <Select
                value={statusFilter}
                onValueChange={(v) => {
                  setStatusFilter(v)
                  setPagination((p) => ({ ...p, skip: 0 }))
                }}
              >
                <SelectTrigger className="w-[160px] bg-background">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="todo">Todo</SelectItem>
                  <SelectItem value="doing">Doing</SelectItem>
                  <SelectItem value="done">Done</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border/50 hover:bg-transparent">
                  <TableHead className="text-muted-foreground">ID</TableHead>
                  <TableHead className="text-muted-foreground">Title</TableHead>
                  <TableHead className="text-muted-foreground">Project</TableHead>
                  <TableHead className="text-muted-foreground">Assignee</TableHead>
                  <TableHead className="text-muted-foreground">Status</TableHead>
                  <TableHead className="text-muted-foreground">Deadline</TableHead>
                  <TableHead className="text-muted-foreground">Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedTasks.length > 0 ? (
                  paginatedTasks.map((task) => {
                    const isOverdue =
                      task.deadline &&
                      task.status !== "done" &&
                      new Date(task.deadline) < new Date()

                    return (
                      <TableRow key={task.id} className="border-border/50">
                        <TableCell className="font-mono text-xs text-muted-foreground">{task.id}</TableCell>
                        <TableCell className="font-medium">{task.title}</TableCell>
                        <TableCell className="text-muted-foreground">
                          {task.project?.title || `Project ${task.project_id}`}
                        </TableCell>
                        <TableCell className="text-muted-foreground">
                          {task.assignee?.full_name || "Unassigned"}
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant="outline"
                            className={statusColors[task.status] || ""}
                          >
                            {task.status}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          {task.deadline ? (
                            <span className={isOverdue ? "text-red-400 font-medium" : "text-muted-foreground"}>
                              {new Date(task.deadline).toLocaleDateString()}
                              {isOverdue && " ⚠"}
                            </span>
                          ) : (
                            <span className="text-muted-foreground">—</span>
                          )}
                        </TableCell>
                        <TableCell className="text-muted-foreground">
                          {new Date(task.created_at).toLocaleDateString()}
                        </TableCell>
                      </TableRow>
                    )
                  })
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <ClipboardX className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No tasks found</p>
                        <p className="text-xs">Try adjusting your search or filters</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            {/* Pagination */}
            {filteredTasks.length > pagination.limit && (
              <div className="flex items-center justify-between border-t border-border/50 pt-4 mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {pagination.skip + 1}–{Math.min(pagination.skip + pagination.limit, filteredTasks.length)} of {filteredTasks.length}
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
                    disabled={pagination.skip + pagination.limit >= filteredTasks.length}
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