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
import { FolderKanban, Search, ChevronLeft, ChevronRight, FolderX } from "lucide-react"
import { fetchProjects } from "@/lib/api"

interface Project {
  id: number
  title: string
  description: string
  status: string
  owner_id: string
  required_skills: string[]
  created_at: string
  owner?: { full_name: string }
  members?: Array<{ user: { full_name: string } }>
  applications?: Array<any>
  tasks?: Array<any>
}

const statusColors: Record<string, string> = {
  open: "border-blue-500/30 bg-blue-500/10 text-blue-400",
  ongoing: "border-rose-900 bg-rose-900/10 text-rose-400",
  completed: "border-emerald-500/30 bg-emerald-500/10 text-emerald-400",
}

export default function ProjectsPage() {
  const [projects, setProjects] = useState<Project[]>([])
  const [loading, setLoading] = useState(true)
  const [pagination, setPagination] = useState({ skip: 0, limit: 20, total: 0 })
  const [search, setSearch] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadProjects()
  }, [])

  async function loadProjects() {
    try {
      const response = await fetchProjects(0, 200)
      if (response.status === 'success') {
        setProjects(response.data)
        setPagination(prev => ({ ...prev, total: response.pagination?.total ?? response.data.length }))
      }
    } catch (error) {
      console.error('Error loading projects:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredProjects = useMemo(() => {
    let result = projects
    if (search) {
      const q = search.toLowerCase()
      result = result.filter(
        (p) =>
          p.title.toLowerCase().includes(q) ||
          p.description.toLowerCase().includes(q) ||
          p.owner?.full_name?.toLowerCase().includes(q)
      )
    }
    if (statusFilter !== "all") {
      result = result.filter((p) => p.status === statusFilter)
    }
    return result
  }, [projects, search, statusFilter])

  const paginatedProjects = useMemo(() => {
    return filteredProjects.slice(pagination.skip, pagination.skip + pagination.limit)
  }, [filteredProjects, pagination.skip, pagination.limit])

  const totalPages = Math.ceil(filteredProjects.length / pagination.limit)
  const currentPage = Math.floor(pagination.skip / pagination.limit) + 1

  if (loading) {
    return (
      <>
        <div className="space-y-6">
          <div>
            <Skeleton className="h-8 w-36" />
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
            <FolderKanban className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Projects</h1>
            <p className="text-sm text-muted-foreground">
              All collaborative projects on the platform
            </p>
          </div>
          <Badge variant="secondary" className="ml-auto text-sm">
            {filteredProjects.length} total
          </Badge>
        </div>

        {/* Data Table */}
        <Card className="border-border/50">
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search projects…"
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
                  <SelectItem value="open">Open</SelectItem>
                  <SelectItem value="ongoing">Ongoing</SelectItem>
                  <SelectItem value="completed">Completed</SelectItem>
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
                  <TableHead className="text-muted-foreground">Status</TableHead>
                  <TableHead className="text-muted-foreground">Owner</TableHead>
                  <TableHead className="text-muted-foreground">Skills</TableHead>
                  <TableHead className="text-muted-foreground">Members</TableHead>
                  <TableHead className="text-muted-foreground">Tasks</TableHead>
                  <TableHead className="text-muted-foreground">Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedProjects.length > 0 ? (
                  paginatedProjects.map((project) => (
                    <TableRow key={project.id} className="border-border/50">
                      <TableCell className="font-mono text-xs text-muted-foreground">{project.id}</TableCell>
                      <TableCell>
                        <div>
                          <p className="font-medium">{project.title}</p>
                          <p className="text-xs text-muted-foreground line-clamp-1 max-w-xs">
                            {project.description}
                          </p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="outline"
                          className={statusColors[project.status] || ""}
                        >
                          {project.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {project.owner?.full_name || "—"}
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                          {project.required_skills.slice(0, 2).map((skill, idx) => (
                            <Badge key={idx} variant="secondary" className="text-xs">
                              {skill}
                            </Badge>
                          ))}
                          {project.required_skills.length > 2 && (
                            <Badge variant="secondary" className="text-xs">
                              +{project.required_skills.length - 2}
                            </Badge>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-muted-foreground">{project.members?.length || 0}</TableCell>
                      <TableCell className="text-muted-foreground">{project.tasks?.length || 0}</TableCell>
                      <TableCell className="text-muted-foreground">
                        {new Date(project.created_at).toLocaleDateString()}
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <FolderX className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No projects found</p>
                        <p className="text-xs">Try adjusting your search or filters</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            {/* Pagination */}
            {filteredProjects.length > pagination.limit && (
              <div className="flex items-center justify-between border-t border-border/50 pt-4 mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {pagination.skip + 1}–{Math.min(pagination.skip + pagination.limit, filteredProjects.length)} of {filteredProjects.length}
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
                    disabled={pagination.skip + pagination.limit >= filteredProjects.length}
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