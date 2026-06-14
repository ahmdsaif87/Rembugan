"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { ColumnDef } from "@tanstack/react-table"
import {
  MoreVerticalIcon,
  FolderX,
  Trash2Icon,
  EyeIcon,
  QrCodeIcon,
  Loader2,
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
import { DetailSheet } from "@/components/ui/detail-sheet"
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
import { fetchProjects, deleteProject } from "@/lib/api"
import { QrCodeDialog } from "@/components/qr-code"
import { toast } from "sonner"

interface Project {
  id: number
  title: string
  description: string
  status: string
  required_skills: string[]
  created_at: string
  owner?: { full_name: string }
  members?: Array<any>
  tasks?: Array<any>
}

const statusColors: Record<string, string> = {
  open: "border-blue-500/30 bg-blue-500/10 text-blue-400",
  ongoing: "border-neutral-500/30 bg-neutral-500/10 text-neutral-400",
  completed: "border-emerald-500/30 bg-emerald-500/10 text-emerald-400",
}

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"
const APP_URL = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"

export default function ProjectsPage() {
  const queryClient = useQueryClient()
  const [detailProject, setDetailProject] = useState<Project | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [qrProject, setQrProject] = useState<Project | null>(null)
  const [qrOpen, setQrOpen] = useState(false)
  const [qrData, setQrData] = useState("")
  const [qrLoading, setQrLoading] = useState(false)
  const [qrInviteData, setQrInviteData] = useState("")

  const { data: projects = [], isLoading: loading } = useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      const res = await fetchProjects(0, 200)
      return (res.status === 'success' ? res.data : []) as Project[]
    },
  })

  async function handleGenerateQr(project: Project) {
    setQrLoading(true)
    setQrProject(project)
    setQrInviteData("")
    try {
      const token = localStorage.getItem("admin_token")
      const res = await fetch(`${API_BASE_URL}/qr/project/${project.id}/invite`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      })
      const data = await res.json()
      if (data.status === "success") {
        setQrData(data.data.qr_data)
        setQrInviteData(data.data.qr_data)
        setQrOpen(true)
      } else {
        toast.error(data.detail || "Gagal generate QR")
      }
    } catch {
      toast.error("Network error")
    } finally {
      setQrLoading(false)
    }
  }

  const deleteMutation = useMutation({
    mutationFn: deleteProject,
    onSuccess: (response, id) => {
      if (response.status === 'success') {
        queryClient.setQueryData<Project[]>(['projects'], (old) =>
          old?.filter(p => String(p.id) !== id) ?? []
        )
      }
    },
  })

  const filteredProjects = useMemo(() => {
    if (statusFilter === "all") return projects
    return projects.filter((p) => p.status === statusFilter)
  }, [projects, statusFilter])

  const columns: ColumnDef<Project>[] = [
    {
      id: "qr",
      header: "QR",
      cell: ({ row }) => {
        const project = row.original
        return (
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 text-muted-foreground hover:text-foreground"
            onClick={() => {
              setQrProject(project)
              setQrData(`${APP_URL}/p/${project.id}`)
              setQrOpen(true)
            }}
          >
            <QrCodeIcon className="h-4 w-4" />
          </Button>
        )
      },
    },
    {
      accessorKey: "id",
      header: "ID",
      cell: ({ row }) => (
        <span className="font-mono text-xs text-muted-foreground">{row.original.id}</span>
      ),
    },
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }) => (
        <div>
          <p className="font-medium">{row.original.title}</p>
          <p className="text-xs text-muted-foreground line-clamp-1 max-w-xs">
            {row.original.description}
          </p>
        </div>
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
      accessorKey: "owner",
      header: "Owner",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {row.original.owner?.full_name || "—"}
        </span>
      ),
    },
    {
      accessorKey: "required_skills",
      header: "Skills",
      cell: ({ row }) => {
        const skills = row.original.required_skills
        return (
          <div className="flex flex-wrap gap-1">
            {skills.slice(0, 2).map((skill, idx) => (
              <Badge key={idx} variant="secondary" className="text-xs">
                {skill}
              </Badge>
            ))}
            {skills.length > 2 && (
              <Badge variant="secondary" className="text-xs">
                +{skills.length - 2}
              </Badge>
            )}
          </div>
        )
      },
    },
    {
      accessorKey: "members",
      header: "Members",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.members?.length || 0}</span>
      ),
    },
    {
      accessorKey: "tasks",
      header: "Tasks",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.tasks?.length || 0}</span>
      ),
    },
    {
      accessorKey: "created_at",
      header: "Created",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {new Date(row.original.created_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      id: "actions",
      cell: ({ row }) => {
        const project = row.original
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
                <DropdownMenuItem onClick={() => { setDetailProject(project); setDetailOpen(true); }}>
                  <EyeIcon />
                  View Details
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => handleGenerateQr(project)} disabled={qrLoading}>
                  {qrLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <QrCodeIcon />}
                  {qrLoading ? "Generating..." : "QR Invite"}
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
                  This will permanently delete project "{project.title}" and all its data.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction
                    onClick={() => deleteMutation.mutate(String(project.id))}
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
          <h1 className="text-2xl font-bold tracking-tight">Projects</h1>
          <p className="text-sm text-muted-foreground">
            All collaborative projects on the platform
          </p>
        </div>
      </div>

      <DataTableGeneric
        columns={columns}
        data={filteredProjects}
        searchKey="title"
        searchPlaceholder="Search projects..."
        loading={loading}
        totalLabel={`${filteredProjects.length} total`}
        emptyMessage="No projects found"
        emptyIcon={<FolderX className="h-8 w-8 opacity-30" />}
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
              <SelectItem value="open">Open</SelectItem>
              <SelectItem value="ongoing">Ongoing</SelectItem>
              <SelectItem value="completed">Completed</SelectItem>
            </SelectContent>
          </Select>
        }
      />

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title={detailProject?.title || "Project Details"}
        fields={[
          { label: "Title", value: detailProject?.title },
          { label: "Description", value: detailProject?.description },
          { label: "Status", value: detailProject?.status },
          { label: "Owner", value: detailProject?.owner?.full_name },
          { label: "Required Skills", value: detailProject?.required_skills?.join(", ") },
          { label: "Members", value: String(detailProject?.members?.length ?? 0) },
          { label: "Tasks", value: String(detailProject?.tasks?.length ?? 0) },
          { label: "Created", value: detailProject?.created_at ? new Date(detailProject.created_at).toLocaleDateString() : "—" },
        ]}
        />

        <div className="flex gap-2 px-6 pb-4">
          <Button
            variant="outline"
            size="sm"
            className="flex-1 gap-2"
            onClick={() => {
              if (detailProject) {
                setQrData(`${APP_URL}/p/${detailProject.id}`)
                setQrInviteData("")
                setQrProject(detailProject)
                setQrOpen(true)
              }
            }}
          >
            <QrCodeIcon className="h-4 w-4" />
            Project QR
          </Button>
          <Button
            variant="outline"
            size="sm"
            className="flex-1 gap-2"
            onClick={() => {
              if (detailProject) handleGenerateQr(detailProject)
            }}
            disabled={qrLoading}
          >
            {qrLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <QrCodeIcon className="h-4 w-4" />}
            {qrLoading ? "Generating..." : "Invite QR"}
          </Button>
        </div>

      <QrCodeDialog
        open={qrOpen}
        onOpenChange={setQrOpen}
        data={qrData}
        title={qrProject ? (qrInviteData ? `Invite: ${qrProject.title}` : `Project: ${qrProject.title}`) : "QR"}
        description={qrInviteData ? "Scan to join this project" : "Scan to view project details"}
      />
    </div>
  )
}
