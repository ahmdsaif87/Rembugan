"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import {
  ColumnDef,
} from "@tanstack/react-table"
import {
  MoreVerticalIcon,
  UserX,
  Trash2Icon,
  EyeIcon,
  PlusIcon,
  Loader2,
  QrCodeIcon,
} from "lucide-react"
import { toast } from "sonner"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
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
import { fetchUsers, deleteUser, createUser } from "@/lib/api"
import { QrCodeDialog } from "@/components/qr-code"

interface User {
  id: string
  nim: string
  full_name: string
  email: string | null
  photo_url: string | null
  major: string
  bio: string | null
  is_onboarded: boolean
  created_at: string
  skills?: Array<{ skill: { name: string } }>
  ownedProjects?: Array<any>
  memberships?: Array<any>
}

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"
const APP_URL = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"

export default function UsersPage() {
  const queryClient = useQueryClient()
  const [detailUser, setDetailUser] = useState<User | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [onboardFilter, setOnboardFilter] = useState<string>("all")
  const [addOpen, setAddOpen] = useState(false)
  const [form, setForm] = useState({ nim: "", full_name: "", major: "", password: "" })
  const [qrUser, setQrUser] = useState<User | null>(null)
  const [qrOpen, setQrOpen] = useState(false)

  const { data: users = [], isLoading: loading } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetchUsers(0, 200)
      return (res.status === 'success' ? res.data : []) as User[]
    },
  })

  const createMutation = useMutation({
    mutationFn: createUser,
    onSuccess: (response) => {
      if (response.status === 'success') {
        toast.success(`User ${form.full_name} berhasil dibuat`)
        setAddOpen(false)
        setForm({ nim: "", full_name: "", major: "", password: "" })
        queryClient.invalidateQueries({ queryKey: ['users'] })
      } else {
        toast.error(response.detail || "Gagal membuat user")
      }
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: (response, id) => {
      if (response.status === 'success') {
        queryClient.setQueryData<User[]>(['users'], (old) =>
          old?.filter(u => u.id !== id) ?? []
        )
        toast.success("User berhasil dihapus")
      } else {
        toast.error("Gagal menghapus user")
      }
    },
  })

  async function handleAddUser(e: React.FormEvent) {
    e.preventDefault()
    createMutation.mutate(form)
  }

  const filteredUsers = useMemo(() => {
    if (onboardFilter === "all") return users
    return users.filter((u) =>
      onboardFilter === "yes" ? u.is_onboarded : !u.is_onboarded
    )
  }, [users, onboardFilter])

  const columns: ColumnDef<User>[] = [
    {
      accessorKey: "full_name",
      header: "Name",
      cell: ({ row }) => {
        const user = row.original
        const initials = user.full_name
          .split(" ")
          .map((n) => n[0])
          .join("")
          .toUpperCase()
          .slice(0, 2)

        return (
          <div className="flex items-center gap-3">
            <Avatar className="h-8 w-8 rounded-full">
              <AvatarImage src={user.photo_url || undefined} alt={user.full_name} />
              <AvatarFallback className="rounded-full text-xs">{initials}</AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium">{user.full_name}</p>
              <p className="text-xs text-muted-foreground">{user.nim}</p>
            </div>
          </div>
        )
      },
    },
    {
      accessorKey: "email",
      header: "Email",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.email || "—"}</span>
      ),
    },
    {
      accessorKey: "major",
      header: "Major",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.major || "—"}</span>
      ),
    },
    {
      accessorKey: "bio",
      header: "Bio",
      cell: ({ row }) => (
        <span className="line-clamp-1 max-w-[180px] text-sm text-muted-foreground">
          {row.original.bio || "—"}
        </span>
      ),
    },
    {
      accessorKey: "is_onboarded",
      header: "Onboarded",
      cell: ({ row }) => {
        const onboarded = row.original.is_onboarded
        return (
          <Badge
            variant="outline"
            className={
              onboarded
                ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-400"
                : "border-amber-500/30 bg-amber-500/10 text-amber-400"
            }
          >
            {onboarded ? "Yes" : "No"}
          </Badge>
        )
      },
    },
    {
      accessorKey: "skills",
      header: "Skills",
      cell: ({ row }) => {
        const skills = row.original.skills || []
        return (
          <div className="flex flex-wrap gap-1">
            {skills.slice(0, 2).map((s, idx) => (
              <Badge key={idx} variant="secondary" className="text-xs">
                {s.skill.name}
              </Badge>
            ))}
            {skills.length > 2 && (
              <Badge variant="secondary" className="text-xs">
                +{skills.length - 2}
              </Badge>
            )}
            {!skills.length && (
              <span className="text-xs text-muted-foreground">—</span>
            )}
          </div>
        )
      },
    },
    {
      accessorKey: "created_at",
      header: "Joined",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {new Date(row.original.created_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      id: "actions",
      cell: ({ row }) => {
        const user = row.original
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
                <DropdownMenuItem onClick={() => { setDetailUser(user); setDetailOpen(true); }}>
                  <EyeIcon />
                  View Details
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => { setQrUser(user); setQrOpen(true); }}>
                  <QrCodeIcon />
                  QR Profile
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
                  This will permanently delete {user.full_name} and remove their data.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction
                    onClick={() => deleteMutation.mutate(user.id)}
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
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Users</h1>
          <p className="text-sm text-muted-foreground">
            Manage and monitor all registered users
          </p>
        </div>
        <Dialog open={addOpen} onOpenChange={setAddOpen}>
          <DialogTrigger asChild>
            <Button>
              <PlusIcon className="mr-2 h-4 w-4" />
              Add User
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-md">
            <form onSubmit={handleAddUser}>
              <DialogHeader>
                <DialogTitle>Add New User</DialogTitle>
                <DialogDescription>
                  Create a new user account. They will use NIM + password to log in.
                </DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="nim">NIM</Label>
                  <Input
                    id="nim"
                    placeholder="12345678"
                    value={form.nim}
                    onChange={(e) => setForm({ ...form, nim: e.target.value })}
                    required
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="full_name">Full Name</Label>
                  <Input
                    id="full_name"
                    placeholder="John Doe"
                    value={form.full_name}
                    onChange={(e) => setForm({ ...form, full_name: e.target.value })}
                    required
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="major">Major</Label>
                  <Input
                    id="major"
                    placeholder="Informatika"
                    value={form.major}
                    onChange={(e) => setForm({ ...form, major: e.target.value })}
                    required
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="Min. 6 characters"
                    value={form.password}
                    onChange={(e) => setForm({ ...form, password: e.target.value })}
                    required
                    minLength={6}
                  />
                </div>
              </div>
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setAddOpen(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={createMutation.isPending}>
                  {createMutation.isPending ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Creating...
                    </>
                  ) : (
                    "Create User"
                  )}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <DataTableGeneric
        columns={columns}
        data={filteredUsers}
        searchKey="full_name"
        searchPlaceholder="Search by name, NIM, or email..."
        loading={loading}
        totalLabel={`${filteredUsers.length} total`}
        emptyMessage="No users found"
        emptyIcon={<UserX className="h-8 w-8 opacity-30" />}
        filters={
          <Select
            value={onboardFilter}
            onValueChange={(v) => setOnboardFilter(v)}
          >
            <SelectTrigger className="h-9 w-[150px]">
              <SelectValue placeholder="Onboarded" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="yes">Onboarded</SelectItem>
              <SelectItem value="no">Not Onboarded</SelectItem>
            </SelectContent>
          </Select>
        }
      />

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title={detailUser?.full_name || "User Details"}
        fields={[
          { label: "NIM", value: detailUser?.nim },
          { label: "Full Name", value: detailUser?.full_name },
          { label: "Email", value: detailUser?.email },
          { label: "Major", value: detailUser?.major },
          { label: "Bio", value: detailUser?.bio },
          { label: "Onboarded", value: detailUser?.is_onboarded ? "Yes" : "No" },
          { label: "Skills", value: detailUser?.skills?.map(s => s.skill.name).join(", ") },
          { label: "Joined", value: detailUser?.created_at ? new Date(detailUser.created_at).toLocaleDateString() : "—" },
        ]}
      />

      <QrCodeDialog
        open={qrOpen}
        onOpenChange={setQrOpen}
        data={qrUser ? `${APP_URL}/u/${qrUser.id}` : ""}
        title={qrUser ? `Profile: ${qrUser.full_name}` : "QR Profile"}
        description="Scan this QR code to view the user's profile"
      />
    </div>
  )
}
