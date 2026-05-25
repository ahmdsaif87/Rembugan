"use client"

import { useEffect, useState, useMemo } from "react"
import { ColumnDef } from "@tanstack/react-table"
import {
  MoreVerticalIcon,
  ClipboardX,
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
import { fetchTasks, deleteTask } from "@/lib/api"

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
  const [detailTask, setDetailTask] = useState<Task | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadTasks()
  }, [])

  async function loadTasks() {
    try {
      const response = await fetchTasks(0, 200)
      if (response.status === 'success') {
        setTasks(response.data)
      }
    } catch (error) {
      console.error('Error loading tasks:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleDelete(id: string) {
    const response = await deleteTask(id)
    if (response.status === 'success') {
      setTasks(tasks.filter(t => String(t.id) !== id))
    }
  }

  const filteredTasks = useMemo(() => {
    if (statusFilter === "all") return tasks
    return tasks.filter((t) => t.status === statusFilter)
  }, [tasks, statusFilter])

  const columns: ColumnDef<Task>[] = [
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
        <span className="font-medium">{row.original.title}</span>
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
                <DropdownMenuItem onClick={() => { setDetailTask(row.original); setDetailOpen(true); }}>
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
                  This will permanently delete task "{task.title}".
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction
                  onClick={() => handleDelete(String(task.id))}
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
