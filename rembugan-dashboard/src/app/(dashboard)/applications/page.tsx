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
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { FileText, Search, ChevronLeft, ChevronRight, FileX, Trash2 } from "lucide-react"
import { fetchApplications, deleteApplication } from "@/lib/api"

interface Application {
  id: number
  project_id: number
  applicant_id: string
  status: string
  applied_at: string
  project?: { title: string }
  applicant?: { full_name: string }
}

const statusColors: Record<string, string> = {
  pending: "border-amber-500/30 bg-amber-500/10 text-amber-400",
  accepted: "border-emerald-500/30 bg-emerald-500/10 text-emerald-400",
  rejected: "border-red-500/30 bg-red-500/10 text-red-400",
}

export default function ApplicationsPage() {
  const [applications, setApplications] = useState<Application[]>([])
  const [loading, setLoading] = useState(true)
  const [pagination, setPagination] = useState({ skip: 0, limit: 20, total: 0 })
  const [search, setSearch] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadApplications()
  }, [])

  async function loadApplications() {
    try {
      const response = await fetchApplications(0, 200)
      if (response.status === 'success') {
        setApplications(response.data)
        setPagination(prev => ({ ...prev, total: response.pagination?.total ?? response.data.length }))
      }
    } catch (error) {
      console.error('Error loading applications:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleDelete(id: string) {
    const response = await deleteApplication(id)
    if (response.status === 'success') {
      setApplications(applications.filter(a => String(a.id) !== id))
    }
  }

  const filteredApplications = useMemo(() => {
    let result = applications
    if (search) {
      const q = search.toLowerCase()
      result = result.filter(
        (a) =>
          a.project?.title?.toLowerCase().includes(q) ||
          a.applicant?.full_name?.toLowerCase().includes(q)
      )
    }
    if (statusFilter !== "all") {
      result = result.filter((a) => a.status === statusFilter)
    }
    return result
  }, [applications, search, statusFilter])

  const paginatedApplications = useMemo(() => {
    return filteredApplications.slice(pagination.skip, pagination.skip + pagination.limit)
  }, [filteredApplications, pagination.skip, pagination.limit])

  const totalPages = Math.ceil(filteredApplications.length / pagination.limit)
  const currentPage = Math.floor(pagination.skip / pagination.limit) + 1

  if (loading) {
    return (
      <>
        <div className="space-y-6">
          <div>
            <Skeleton className="h-8 w-44" />
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
            <FileText className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Applications</h1>
            <p className="text-sm text-muted-foreground">
              Project membership applications
            </p>
          </div>
          <Badge variant="secondary" className="ml-auto text-sm">
            {filteredApplications.length} total
          </Badge>
        </div>

        {/* Data Table */}
        <Card className="border-border/50">
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search applications…"
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
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="accepted">Accepted</SelectItem>
                  <SelectItem value="rejected">Rejected</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border/50 hover:bg-transparent">
                  <TableHead className="text-muted-foreground">ID</TableHead>
                  <TableHead className="text-muted-foreground">Project</TableHead>
                  <TableHead className="text-muted-foreground">Applicant</TableHead>
                  <TableHead className="text-muted-foreground">Status</TableHead>
                  <TableHead className="text-muted-foreground">Applied At</TableHead>
                  <TableHead className="text-right text-muted-foreground">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedApplications.length > 0 ? (
                  paginatedApplications.map((app) => (
                    <TableRow key={app.id} className="border-border/50">
                      <TableCell className="font-mono text-xs text-muted-foreground">{app.id}</TableCell>
                      <TableCell className="font-medium">
                        {app.project?.title || `Project ${app.project_id}`}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {app.applicant?.full_name || app.applicant_id}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="outline"
                          className={statusColors[app.status] || ""}
                        >
                          {app.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {new Date(app.applied_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell className="text-right">
                        <AlertDialog>
                          <AlertDialogTrigger asChild>
                            <Button variant="ghost" size="icon" className="text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </AlertDialogTrigger>
                          <AlertDialogContent>
                            <AlertDialogHeader>
                              <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                              <AlertDialogDescription>
                                This action cannot be undone. This will permanently delete the application
                                and all its associated data.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Cancel</AlertDialogCancel>
                              <AlertDialogAction onClick={() => handleDelete(String(app.id))} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                                Delete
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={6} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <FileX className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No applications found</p>
                        <p className="text-xs">Try adjusting your search or filters</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            {/* Pagination */}
            {filteredApplications.length > pagination.limit && (
              <div className="flex items-center justify-between border-t border-border/50 pt-4 mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {pagination.skip + 1}–{Math.min(pagination.skip + pagination.limit, filteredApplications.length)} of {filteredApplications.length}
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
                    disabled={pagination.skip + pagination.limit >= filteredApplications.length}
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