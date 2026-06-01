"use client"

import { useEffect, useState, useMemo } from "react"
import { ColumnDef } from "@tanstack/react-table"
import {
  MoreVerticalIcon,
  FileX,
  Trash2Icon,
  EyeIcon,
} from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { DataTableGeneric } from "@/components/ui/data-table-generic"
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
import { DetailSheet } from "@/components/ui/detail-sheet"
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
  const [detailApp, setDetailApp] = useState<Application | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [applications, setApplications] = useState<Application[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadApplications()
  }, [])

  async function loadApplications() {
    try {
      const response = await fetchApplications(0, 200)
      if (response.status === 'success') {
        setApplications(response.data)
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
    if (statusFilter === "all") return applications
    return applications.filter((a) => a.status === statusFilter)
  }, [applications, statusFilter])

  const columns: ColumnDef<Application>[] = [
    {
      accessorKey: "id",
      header: "ID",
      cell: ({ row }) => (
        <span className="font-mono text-xs text-muted-foreground">{row.original.id}</span>
      ),
    },
    {
      id: "project.title",
      accessorFn: (row) => row.project?.title,
      header: "Project",
      cell: ({ row }) => (
        <span className="font-medium">
          {row.original.project?.title || `Project ${row.original.project_id}`}
        </span>
      ),
    },
    {
      id: "applicant.name",
      accessorFn: (row) => row.applicant?.full_name,
      header: "Applicant",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {row.original.applicant?.full_name || row.original.applicant_id}
        </span>
      ),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <Badge
          variant="outline"
          className={statusColors[row.original.status] || ""}
        >
          {row.original.status}
        </Badge>
      ),
    },
    {
      accessorKey: "applied_at",
      header: "Applied At",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {new Date(row.original.applied_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      id: "actions",
      cell: ({ row }) => {
        const app = row.original
        return (
          <AlertDialog>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="flex size-8 text-muted-foreground data-[state=open]:bg-muted"
                  size="icon"
                >
                  <MoreVerticalIcon />
                  <span className="sr-only">Open menu</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-32">
                <DropdownMenuItem onClick={() => { setDetailApp(row.original); setDetailOpen(true); }}>
                  <EyeIcon />
                  View Details
                </DropdownMenuItem>
                <AlertDialogTrigger asChild>
                  <DropdownMenuItem className="text-destructive">
                    <Trash2Icon />
                    Delete
                  </DropdownMenuItem>
                </AlertDialogTrigger>
              </DropdownMenuContent>
            </DropdownMenu>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                <AlertDialogDescription>
                  This will permanently delete this application.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction
                  onClick={() => handleDelete(String(app.id))}
                  className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                >
                  Delete
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        )
      },
    },
  ]

  return (
    <div className="flex flex-col gap-4">
      <div>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Applications</h1>
          <p className="text-sm text-muted-foreground">
            Project membership applications
          </p>
        </div>
      </div>

      <DataTableGeneric
        columns={columns}
        data={filteredApplications}
        searchKey="project.title"
        searchPlaceholder="Search applications..."
        loading={loading}
        totalLabel={`${filteredApplications.length} total`}
        emptyMessage="No applications found"
        emptyIcon={<FileX className="h-8 w-8 opacity-30" />}
        filters={
          <Select
            value={statusFilter}
            onValueChange={(v) => setStatusFilter(v)}
          >
            <SelectTrigger className="h-9 w-[150px]">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="pending">Pending</SelectItem>
              <SelectItem value="accepted">Accepted</SelectItem>
              <SelectItem value="rejected">Rejected</SelectItem>
            </SelectContent>
          </Select>
        }
      />

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title="Application Details"
        fields={[
          { label: "Applicant", value: detailApp?.applicant?.full_name },
          { label: "Project", value: detailApp?.project?.title },
          { label: "Status", value: detailApp?.status },
          { label: "Applied At", value: detailApp?.applied_at ? new Date(detailApp.applied_at).toLocaleDateString() : "—" },
        ]}
      />
    </div>
  )
}
