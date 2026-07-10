"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { ColumnDef } from "@tanstack/react-table"
import {
  ClipboardX,
} from "lucide-react"

import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { DataTableGeneric } from "@/components/ui/data-table-generic"
import { RowActions } from "@/components/ui/row-actions"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { fetchTasks, deleteTask } from "@/lib/api"
import { toast } from "sonner"

interface Task {
  id: number
  project_id: number
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
  const queryClient = useQueryClient()
  const [detailTask, setDetailTask] = useState<Task | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [statusFilter, setStatusFilter] = useState<string>("all")

  const { data: tasks = [], isLoading: loading } = useQuery({
    queryKey: ['tasks'],
    queryFn: async () => {
      const res = await fetchTasks(0, 200)
      return (res.status === 'success' ? res.data : []) as Task[]
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteTask,
    onSuccess: (response, id) => {
      if (response.status === 'success') {
        queryClient.setQueryData<Task[]>(['tasks'], (old) =>
          old?.filter(t => String(t.id) !== id) ?? []
        )
        toast.success("Tugas berhasil dihapus")
      }
    },
    onError: () => {
      toast.error("Gagal menghapus tugas")
    },
  })

  const filteredTasks = useMemo(() => {
    if (statusFilter === "all") return tasks
    return tasks.filter((t) => t.status === statusFilter)
  }, [tasks, statusFilter])

  const columns = useMemo((): ColumnDef<Task>[] => [
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
        <span className="table-primary">{row.original.title}</span>
      ),
    },
    {
      accessorKey: "project",
      header: "Project",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {row.original.project?.title || `Project ${row.original.project_id}`}
        </span>
      ),
    },
    {
      accessorKey: "assignee",
      header: "Assignee",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {row.original.assignee?.full_name || "Unassigned"}
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
      accessorKey: "deadline",
      header: "Deadline",
      cell: ({ row }) => {
        const isOverdue =
          row.original.deadline &&
          row.original.status !== "done" &&
          new Date(row.original.deadline) < new Date()

        return row.original.deadline ? (
          <span className={isOverdue ? "text-red-400 font-medium" : "text-muted-foreground"}>
            {new Date(row.original.deadline).toLocaleDateString()}
          </span>
        ) : (
          <span className="text-muted-foreground">—</span>
        )
      },
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
        const task = row.original
        return (
          <RowActions
            onView={() => { setDetailTask(task); setDetailOpen(true) }}
            onDelete={() => deleteMutation.mutate(String(task.id))}
            deleteLabel={`task "${task.title}"`}
          />
        )
      },
    },
  ], [deleteMutation])

  return (
    <div className="flex flex-col gap-4">
      <div>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Tasks</h1>
          <p className="text-sm text-muted-foreground">
            All project tasks across the platform
          </p>
        </div>
      </div>

      <DataTableGeneric
        columns={columns}
        data={filteredTasks}
        searchKey="title"
        searchPlaceholder="Search tasks..."
        loading={loading}
        totalLabel={`${filteredTasks.length} total`}
        emptyMessage="No tasks found"
        emptyIcon={<ClipboardX className="h-8 w-8 opacity-30" />}
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
              <SelectItem value="todo">Todo</SelectItem>
              <SelectItem value="doing">Doing</SelectItem>
              <SelectItem value="done">Done</SelectItem>
            </SelectContent>
          </Select>
        }
      />

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title={detailTask?.title || "Task Details"}
        fields={[
          { label: "Title", value: detailTask?.title },
          { label: "Project", value: detailTask?.project?.title },
          { label: "Status", value: detailTask?.status },
          { label: "Assignee", value: detailTask?.assignee?.full_name },
          { label: "Deadline", value: detailTask?.deadline ? new Date(detailTask.deadline).toLocaleDateString() : "—" },
          { label: "Created", value: detailTask?.created_at ? new Date(detailTask.created_at).toLocaleDateString() : "—" },
        ]}
      />
    </div>
  )
}
