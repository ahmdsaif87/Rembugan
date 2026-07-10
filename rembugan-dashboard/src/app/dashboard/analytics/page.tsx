"use client"

import { useState, useMemo } from "react"
import { useQuery } from "@tanstack/react-query"
import { fetchAnalytics } from "@/lib/api"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { AnalyticsChart } from "@/components/dashboard/analytics-chart"
import { Skeleton } from "@/components/ui/skeleton"
import {
  TrendingUp,
  FolderKanban,
  Users,
  BarChart3,
  ListChecks,
  Sparkles,
  ClipboardList,
} from "lucide-react"

interface AnalyticsData {
  user_registrations: { period: string; total: number }[]
  project_creations: { period: string; total: number }[]
  users_by_faculty: { faculty: string; total: number }[]
  projects_by_category: { category: string; total: number }[]
  projects_by_status: { status: string; total: number }[]
  task_distribution: { status: string; total: number }[]
  showcase_engagement: { total_likes: number; total_comments: number; total_showcases: number }
  total_users: number
  total_projects: number
  available_faculties: string[]
  available_categories: string[]
}

export default function AnalyticsPage() {
  const [period, setPeriod] = useState("all")
  const [faculty, setFaculty] = useState("")
  const [granularity, setGranularity] = useState("monthly")

  const dates = useMemo(() => {
    const now = new Date()
    let start: string | undefined
    if (period === "7d") start = new Date(now.getTime() - 7 * 86400000).toISOString().slice(0, 10)
    else if (period === "30d") start = new Date(now.getTime() - 30 * 86400000).toISOString().slice(0, 10)
    else if (period === "90d") start = new Date(now.getTime() - 90 * 86400000).toISOString().slice(0, 10)
    else if (period === "1y") start = new Date(now.getTime() - 365 * 86400000).toISOString().slice(0, 10)
    return start
  }, [period])

  const { data: raw, isLoading } = useQuery({
    queryKey: ['analytics', period, faculty, granularity],
    queryFn: async () => {
      const res = await fetchAnalytics({
        start_date: dates,
        end_date: undefined,
        faculty: faculty || undefined,
        category: undefined,
        granularity,
      })
      if (res.status !== 'success' || !res.data) return null
      return res.data as AnalyticsData
    },
  })

  const stats = useMemo(() => {
    if (!raw) return { total_users: 0, total_projects: 0, total_showcases: 0, total_likes: 0, total_comments: 0 }
    return {
      total_users: raw.total_users,
      total_projects: raw.total_projects,
      total_showcases: raw.showcase_engagement.total_showcases,
      total_likes: raw.showcase_engagement.total_likes,
      total_comments: raw.showcase_engagement.total_comments,
    }
  }, [raw])

  const statusLabel: Record<string, string> = {
    open: "Terbuka",
    ongoing: "Berjalan",
    completed: "Selesai",
  }

  const taskStatusLabel: Record<string, string> = {
    todo: "Belum Dikerjakan",
    doing: "Sedang Dikerjakan",
    done: "Selesai",
  }

  return (
    <div className="flex flex-col gap-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Analitik</h1>
          <p className="text-sm text-muted-foreground">Wawasan big data dan penyaringan data</p>
        </div>
      </div>

      <Card className="rounded-2xl border border-border/50 shadow-sm">
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold tracking-tight">Filter</CardTitle>
          <CardDescription className="text-xs">Saring data berdasarkan kriteria</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            <div className="space-y-1.5">
              <Label className="text-xs">Periode</Label>
              <Select value={period} onValueChange={setPeriod}>
                <SelectTrigger className="h-9">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="7d">7 Hari Terakhir</SelectItem>
                  <SelectItem value="30d">30 Hari Terakhir</SelectItem>
                  <SelectItem value="90d">90 Hari Terakhir</SelectItem>
                  <SelectItem value="1y">1 Tahun Terakhir</SelectItem>
                  <SelectItem value="all">Semua Waktu</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Fakultas</Label>
              <Select value={faculty || " "} onValueChange={(v) => setFaculty(v === " " ? "" : v)}>
                <SelectTrigger className="h-9">
                  <SelectValue placeholder="Semua Fakultas" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value=" ">Semua Fakultas</SelectItem>
                  {(raw?.available_faculties ?? []).map((f) => (
                    <SelectItem key={f} value={f}>{f}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Skala Waktu</Label>
              <Select value={granularity} onValueChange={setGranularity}>
                <SelectTrigger className="h-9">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="daily">Harian</SelectItem>
                  <SelectItem value="weekly">Mingguan</SelectItem>
                  <SelectItem value="monthly">Bulanan</SelectItem>
                  <SelectItem value="yearly">Tahunan</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4 md:grid-cols-5">
            {[...Array(5)].map((_, i) => (
              <Card key={i} className="rounded-2xl border border-border/50 shadow-sm">
                <CardContent className="p-4">
                  <Skeleton className="h-3 w-20 mb-2" />
                  <Skeleton className="h-8 w-16" />
                </CardContent>
              </Card>
            ))}
          </div>
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            {[...Array(2)].map((_, i) => (
              <Card key={i} className="rounded-2xl border border-border/50 shadow-sm">
                <CardHeader>
                  <Skeleton className="h-5 w-32" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-[300px] w-full" />
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      ) : !raw ? (
        <div className="flex items-center justify-center py-20 text-sm text-muted-foreground">Tidak ada data</div>
      ) : (
        <>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-5">
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardContent className="flex items-center justify-between p-4">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">Total Pengguna</p>
                  <p className="text-2xl font-bold">{stats.total_users}</p>
                </div>
                <Users className="h-5 w-5 text-muted-foreground" />
              </CardContent>
            </Card>
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardContent className="flex items-center justify-between p-4">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">Total Proyek</p>
                  <p className="text-2xl font-bold">{stats.total_projects}</p>
                </div>
                <FolderKanban className="h-5 w-5 text-muted-foreground" />
              </CardContent>
            </Card>
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardContent className="flex items-center justify-between p-4">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">Showcase</p>
                  <p className="text-2xl font-bold">{stats.total_showcases}</p>
                </div>
                <Sparkles className="h-5 w-5 text-muted-foreground" />
              </CardContent>
            </Card>
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardContent className="flex items-center justify-between p-4">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">Suka</p>
                  <p className="text-2xl font-bold">{stats.total_likes}</p>
                </div>
                <BarChart3 className="h-5 w-5 text-muted-foreground" />
              </CardContent>
            </Card>
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardContent className="flex items-center justify-between p-4">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">Komentar</p>
                  <p className="text-2xl font-bold">{stats.total_comments}</p>
                </div>
                <ClipboardList className="h-5 w-5 text-muted-foreground" />
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <AnalyticsChart
              title="Pendaftaran Pengguna"
              description="Jumlah pendaftaran baru per periode"
              icon={TrendingUp}
              data={raw.user_registrations}
              type="area"
              dataKey="total"
              nameKey="period"
            />
            <AnalyticsChart
              title="Pembuatan Proyek"
              description="Jumlah proyek baru per periode"
              icon={FolderKanban}
              data={raw.project_creations}
              type="area"
              dataKey="total"
              nameKey="period"
            />
          </div>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <AnalyticsChart
              title="Pengguna per Fakultas"
              description="Distribusi pengguna berdasarkan fakultas"
              icon={Users}
              data={raw.users_by_faculty.map((d) => ({ name: d.faculty, total: d.total }))}
              type="bar"
              dataKey="total"
              nameKey="name"
            />
            <AnalyticsChart
              title="Proyek per Kategori"
              description="Distribusi proyek berdasarkan kategori"
              icon={BarChart3}
              data={raw.projects_by_category.map((d) => ({ name: d.category, total: d.total }))}
              type="bar"
              dataKey="total"
              nameKey="name"
            />
            <AnalyticsChart
              title="Status Proyek"
              description="Kondisi proyek saat ini"
              icon={ListChecks}
              data={raw.projects_by_status.map((d) => ({ name: statusLabel[d.status] || d.status, total: d.total }))}
              type="bar"
              dataKey="total"
              nameKey="name"
            />
          </div>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <AnalyticsChart
              title="Distribusi Tugas"
              description="Tugas berdasarkan status kanban"
              icon={ListChecks}
              data={raw.task_distribution.map((d) => ({ name: taskStatusLabel[d.status] || d.status, total: d.total }))}
              type="bar"
              dataKey="total"
              nameKey="name"
            />
            <Card className="rounded-2xl border border-border/50 shadow-sm">
              <CardHeader className="flex flex-row items-center gap-4 pb-4">
                <div className="rounded-lg bg-primary/10 p-2">
                  <Sparkles className="h-5 w-5 text-primary" />
                </div>
                <div className="space-y-1">
                  <CardTitle className="text-base font-semibold tracking-tight">Engagement Showcase</CardTitle>
                  <CardDescription className="text-xs">Rata-rata suka & komentar per showcase</CardDescription>
                </div>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 gap-4">
                  <div className="rounded-xl bg-muted p-4 text-center">
                    <p className="text-xs text-muted-foreground">Rata-rata Suka</p>
                    <p className="text-3xl font-bold">
                      {stats.total_showcases > 0
                        ? (stats.total_likes / stats.total_showcases).toFixed(1)
                        : "0"}
                    </p>
                  </div>
                  <div className="rounded-xl bg-muted p-4 text-center">
                    <p className="text-xs text-muted-foreground">Rata-rata Komentar</p>
                    <p className="text-3xl font-bold">
                      {stats.total_showcases > 0
                        ? (stats.total_comments / stats.total_showcases).toFixed(1)
                        : "0"}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </>
      )}
    </div>
  )
}