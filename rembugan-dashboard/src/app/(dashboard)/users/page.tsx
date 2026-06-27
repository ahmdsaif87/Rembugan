"use client"

import { useState, useMemo, useRef } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import {
  ColumnDef,
} from "@tanstack/react-table"
import {
  UserX,
  PlusIcon,
  Loader2,
  QrCodeIcon,
  Trash2Icon,
  UploadIcon,
} from "lucide-react"
import { toast } from "sonner"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
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
} from "@/components/ui/dialog"
import { DataTableGeneric } from "@/components/ui/data-table-generic"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { RowActions } from "@/components/ui/row-actions"
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
import { fetchUsers, deleteUser, createUser, importUsers } from "@/lib/api"
import { QrCodeDialog } from "@/components/qr-code"

interface User {
  id: string
  nim: string | null
  email: string | null
  full_name: string
  photo_url: string | null
  bio: string | null
  interest: string | null
  faculty: string | null
  major: string | null
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
  const [importOpen, setImportOpen] = useState(false)
  const [form, setForm] = useState({ email: "", full_name: "", interest: "", password: "", nim: "", faculty: "", major: "" })
  const [qrUser, setQrUser] = useState<User | null>(null)
  const [qrOpen, setQrOpen] = useState(false)
  const [importPreview, setImportPreview] = useState<Array<{ nim: string; full_name: string; faculty: string; major: string }> | null>(null)
  const [defaultPassword, setDefaultPassword] = useState("uhn2025")
  const fileInputRef = useRef<HTMLInputElement>(null)

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
        setForm({ email: "", full_name: "", interest: "", password: "", nim: "", faculty: "", major: "" })
        queryClient.invalidateQueries({ queryKey: ['users'] })
      } else {
        toast.error(response.detail || "Gagal membuat user")
      }
    },
  })

  const importMutation = useMutation({
    mutationFn: importUsers,
    onSuccess: (response) => {
      if (response.status === 'success') {
        toast.success(response.message || `Berhasil import ${response.data?.success_count} mahasiswa`)
        setImportOpen(false)
        setImportPreview(null)
        queryClient.invalidateQueries({ queryKey: ['users'] })
        if (response.data?.errors?.length > 0) {
          toast.warning(`${response.data.errors.length} data gagal diimport`)
        }
      } else {
        toast.error(response.detail || "Gagal import mahasiswa")
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

  function handleFileUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (event) => {
      const text = event.target?.result as string
      const lines = text.split('\n').filter(l => l.trim())
      if (lines.length < 2) {
        toast.error('CSV harus memiliki header dan minimal 1 data')
        return
      }
      const headers = lines[0].split(',').map(h => h.trim().toLowerCase())
      const nimIdx = headers.indexOf('nim')
      const nameIdx = headers.indexOf('full_name')
      const facultyIdx = headers.indexOf('faculty')
      const majorIdx = headers.indexOf('major')

      if (nimIdx === -1 || nameIdx === -1 || facultyIdx === -1 || majorIdx === -1) {
        toast.error('CSV harus memiliki kolom: nim, full_name, faculty, major')
        return
      }

      const preview = lines.slice(1).map(line => {
        const cols = line.split(',').map(c => c.trim())
        return {
          nim: cols[nimIdx] || '',
          full_name: cols[nameIdx] || '',
          faculty: cols[facultyIdx] || '',
          major: cols[majorIdx] || '',
        }
      }).filter(row => row.nim && row.full_name)

      if (preview.length === 0) {
        toast.error('Tidak ada data valid di CSV')
        return
      }

      setImportPreview(preview)
      toast.success(`${preview.length} data siap diimport`)
    }
    reader.readAsText(file)
    // Reset file input
    if (fileInputRef.current) fileInputRef.current.value = ''
  }

  function handleImport() {
    if (!importPreview || importPreview.length === 0) return
    importMutation.mutate({ users: importPreview, default_password: defaultPassword })
  }

  const filteredUsers = useMemo(() => {
    if (onboardFilter === "all") return users
    return users.filter((u) =>
      onboardFilter === "yes" ? u.is_onboarded : !u.is_onboarded
    )
  }, [users, onboardFilter])

  const columns = useMemo((): ColumnDef<User>[] => [
    {
      accessorKey: "nim",
      header: "NIM",
      cell: ({ row }) => (
        <span className="font-mono text-xs font-medium">{row.original.nim || "—"}</span>
      ),
    },
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
              <p className="table-primary">{user.full_name}</p>
              <p className="text-xs text-muted-foreground">{user.email || user.nim}</p>
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
      accessorKey: "faculty",
      header: "Fakultas",
      cell: ({ row }) => (
        <span className="text-sm text-muted-foreground">{row.original.faculty || "—"}</span>
      ),
    },
    {
      accessorKey: "major",
      header: "Jurusan",
      cell: ({ row }) => (
        <span className="text-sm text-muted-foreground">{row.original.major || "—"}</span>
      ),
    },
    {
      accessorKey: "interest",
      header: "Interest",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.major || "—"}</span>
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
          <RowActions
            onView={() => { setDetailUser(user); setDetailOpen(true) }}
            onDelete={() => deleteMutation.mutate(user.id)}
            deleteLabel={`${user.full_name} and remove their data`}
            extraItems={[
              {
                icon: <QrCodeIcon />,
                label: "QR Profile",
                onClick: () => { setQrUser(user); setQrOpen(true) },
              },
            ]}
          />
        )
      },
    },
  ], [deleteMutation])

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Users</h1>
          <p className="text-sm text-muted-foreground">
            Manage and monitor all registered users
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => setImportOpen(true)}>
            <UploadIcon className="mr-2 h-4 w-4" />
            Import CSV
          </Button>
          <Dialog open={addOpen} onOpenChange={setAddOpen}>
            <Button onClick={() => setAddOpen(true)}>
              <PlusIcon className="mr-2 h-4 w-4" />
              Add User
            </Button>
            <DialogContent className="sm:max-w-md">
              <form onSubmit={handleAddUser}>
                <DialogHeader>
                  <DialogTitle>Add New User</DialogTitle>
                  <DialogDescription>
                    Create a new user account.
                  </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                  <div className="grid gap-2">
                    <Label htmlFor="nim">NIM</Label>
                    <Input
                      id="nim"
                      placeholder="23090101"
                      value={form.nim}
                      onChange={(e) => setForm({ ...form, nim: e.target.value })}
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
                    <Label htmlFor="faculty">Fakultas</Label>
                    <Input
                      id="faculty"
                      placeholder="Sekolah Vokasi"
                      value={form.faculty}
                      onChange={(e) => setForm({ ...form, faculty: e.target.value })}
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="major">Jurusan</Label>
                    <Input
                      id="major"
                      placeholder="D-4 Teknik Informatika"
                      value={form.major}
                      onChange={(e) => setForm({ ...form, major: e.target.value })}
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="user@example.com"
                      value={form.email}
                      onChange={(e) => setForm({ ...form, email: e.target.value })}
                    />
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="interest">Interest</Label>
                    <Input
                      id="interest"
                      placeholder="Mobile Development"
                      value={form.interest}
                      onChange={(e) => setForm({ ...form, interest: e.target.value })}
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
      </div>

      {/* Import CSV Dialog */}
      <Dialog open={importOpen} onOpenChange={setImportOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Import Mahasiswa via CSV</DialogTitle>
            <DialogDescription>
              Upload file CSV dengan kolom: nim, full_name, faculty, major
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="rounded-lg border bg-muted/50 p-4">
              <p className="text-xs font-medium text-muted-foreground mb-2">Format CSV:</p>
              <code className="text-xs">
                nim,full_name,faculty,major{'\n'}
                23090101,Ahmad Maulana,Sekolah Vokasi,D-4 Teknik Informatika{'\n'}
                23090102,Siti Nurjanah,Sekolah Vokasi,D-4 Teknik Informatika
              </code>
            </div>
            <input
              ref={fileInputRef}
              type="file"
              accept=".csv"
              onChange={handleFileUpload}
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm file:border-0 file:bg-transparent file:text-sm file:font-medium"
            />
            <div className="grid gap-2">
              <Label htmlFor="defaultPassword">Default Password</Label>
              <Input
                id="defaultPassword"
                value={defaultPassword}
                onChange={(e) => setDefaultPassword(e.target.value)}
                placeholder="uhn2025"
              />
            </div>
            {importPreview && (
              <div className="rounded-lg border p-3">
                <p className="text-sm font-medium mb-2">Preview: {importPreview.length} data</p>
                <div className="max-h-40 overflow-y-auto">
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="text-left text-muted-foreground">
                        <th className="pb-1 pr-2">NIM</th>
                        <th className="pb-1 pr-2">Nama</th>
                        <th className="pb-1">Fakultas</th>
                      </tr>
                    </thead>
                    <tbody>
                      {importPreview.slice(0, 5).map((row, i) => (
                        <tr key={i} className="border-t border-border/50">
                          <td className="py-1 pr-2 font-mono">{row.nim}</td>
                          <td className="py-1 pr-2">{row.full_name}</td>
                          <td className="py-1">{row.faculty}</td>
                        </tr>
                      ))}
                      {importPreview.length > 5 && (
                        <tr className="border-t border-border/50">
                          <td colSpan={3} className="py-1 text-center text-muted-foreground">
                            ...dan {importPreview.length - 5} lainnya
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => { setImportOpen(false); setImportPreview(null) }}>
              Cancel
            </Button>
            <Button
              onClick={handleImport}
              disabled={!importPreview || importPreview.length === 0 || importMutation.isPending}
            >
              {importMutation.isPending ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Importing...
                </>
              ) : (
                `Import ${importPreview?.length || 0} Mahasiswa`
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

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
        identity={detailUser ? {
          name: detailUser.full_name,
          subtitle: detailUser.major ?? undefined,
          avatar: detailUser.photo_url,
        } : undefined}
        fields={[
          { label: "NIM", value: detailUser?.nim || "—" },
          { label: "Email", value: detailUser?.email || "—" },
          { label: "Fakultas", value: detailUser?.faculty || "—" },
          { label: "Jurusan", value: detailUser?.major || "—" },
          { label: "Interest", value: detailUser?.interest || "—" },
          { label: "Onboarded", value: detailUser?.is_onboarded ? "Yes" : "No" },
          { label: "Skills", value: detailUser?.skills?.map(s => s.skill.name).join(", "), variant: "badge" },
          { label: "Bio", value: detailUser?.bio || "", variant: "bio" },
          { label: "Joined", value: detailUser?.created_at ? new Date(detailUser.created_at).toLocaleDateString() : "—" },
        ]}
        actions={
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              className="flex-1 gap-2"
              onClick={() => {
                if (detailUser) {
                  setQrUser(detailUser)
                  setQrOpen(true)
                }
              }}
            >
              <QrCodeIcon className="h-4 w-4" />
              QR Profile
            </Button>
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button
                  variant="outline"
                  size="sm"
                  className="flex-1 gap-2 text-destructive hover:text-destructive"
                >
                  <Trash2Icon className="h-4 w-4" />
                  Delete
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                  <AlertDialogDescription>
                    This will permanently delete {detailUser?.full_name} and remove their data.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction
                    onClick={() => detailUser && deleteMutation.mutate(detailUser.id)}
                    className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                  >
                    Delete
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        }
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
