"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Skeleton } from "@/components/ui/skeleton"
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
import { Activity, Calendar, Tag, List } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Label } from "@/components/ui/label"

import { RowActions } from "@/components/ui/row-actions"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { AnalyticsChart } from "@/components/dashboard/analytics-chart"
import { fetchCompetitions, deleteCompetition } from "@/lib/api"
import { toast } from "sonner"

interface Competition {
  _id?: string
  id?: string
  sumber: string
  judul: string
  caption?: string
  kategori?: string
  deadline?: string
  link_pendaftaran?: string[]
  link_direct?: string
}

export default function CompetitionsPage() {
  const queryClient = useQueryClient()
  const [detailComp, setDetailComp] = useState<Competition | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
  const [sumberFilter, setSumberFilter] = useState("")
  const [kategoriFilter, setKategoriFilter] = useState("")

  const { data: competitions = [], isLoading: loading } = useQuery({
    queryKey: ['competitions'],
    queryFn: async () => {
      const res = await fetchCompetitions()
      return (res.status === 'success' ? res.data : []) as Competition[]
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteCompetition,
    onSuccess: (response, id) => {
      if (response.status === 'success') {
        queryClient.setQueryData<Competition[]>(['competitions'], (old) =>
          old?.filter(c => c._id !== id) ?? []
        )
        toast.success("Kompetisi berhasil dihapus")
      }
    },
    onError: () => {
      toast.error("Gagal menghapus kompetisi")
    },
  })

  const distinctSumber = useMemo(() => {
    const set = new Set(competitions.map(c => c.sumber).filter((s): s is string => !!s))
    return Array.from(set).sort()
  }, [competitions])

  const distinctKategori = useMemo(() => {
    const set = new Set(competitions.map(c => c.kategori).filter((k): k is string => !!k))
    return Array.from(set).sort()
  }, [competitions])

  const filtered = useMemo(() => {
    return competitions.filter(c => {
      if (sumberFilter && c.sumber !== sumberFilter) return false
      if (kategoriFilter && c.kategori !== kategoriFilter) return false
      return true
    })
  }, [competitions, sumberFilter, kategoriFilter])

  const sourceData = useMemo(() => {
    const counts: Record<string, number> = {}
    filtered.forEach((c) => {
      const source = c.sumber || "Unknown"
      counts[source] = (counts[source] || 0) + 1
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => b.total - a.total)
  }, [filtered])

  const deadlineData = useMemo(() => {
    const counts: Record<string, number> = {}
    filtered.forEach((c) => {
      if (c.deadline) {
        const d = c.deadline
        counts[d] = (counts[d] || 0) + 1
      }
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => a.name.localeCompare(b.name))
  }, [filtered])

  const kategoriData = useMemo(() => {
    const counts: Record<string, number> = {}
    filtered.forEach((c) => {
      if (c.kategori) {
        const k = c.kategori
        counts[k] = (counts[k] || 0) + 1
      }
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => b.total - a.total)
  }, [filtered])

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <Skeleton className="h-8 w-48" />
          <Skeleton className="mt-2 h-4 w-72" />
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          <Skeleton className="h-[350px] w-full" />
          <Skeleton className="h-[350px] w-full" />
          <Skeleton className="h-[350px] w-full" />
        </div>
        <Skeleton className="h-[400px] w-full" />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Data Kompetisi</h1>
          <p className="text-sm text-muted-foreground">
            Visualisasi data kompetisi dari scraping
          </p>
        </div>
      </div>

      <Card className="rounded-2xl border border-border/50 shadow-sm">
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold tracking-tight">Filter</CardTitle>
          <CardDescription className="text-xs">Saring data kompetisi</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div className="space-y-1.5">
              <Label className="text-xs">Sumber</Label>
              <Select value={sumberFilter || " "} onValueChange={(v) => setSumberFilter(v === " " ? "" : v)}>
                <SelectTrigger className="h-9">
                  <SelectValue placeholder="Semua Sumber" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value=" ">Semua Sumber</SelectItem>
                  {distinctSumber.map((s) => (
                    <SelectItem key={s} value={s}>{s}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs">Kategori</Label>
              <Select value={kategoriFilter || " "} onValueChange={(v) => setKategoriFilter(v === " " ? "" : v)}>
                <SelectTrigger className="h-9">
                  <SelectValue placeholder="Semua Kategori" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value=" ">Semua Kategori</SelectItem>
                  {distinctKategori.map((k) => (
                    <SelectItem key={k} value={k}>{k}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-4 md:grid-cols-3">
        <AnalyticsChart
          title="Berdasarkan Sumber"
          description="Distribusi berdasarkan sumber"
          icon={Activity}
          data={sourceData}
          type="bar"
          dataKey="total"
          nameKey="name"
        />
        <AnalyticsChart
          title="Berdasarkan Deadline"
          description="Kompetisi dikelompokkan berdasarkan deadline"
          icon={Calendar}
          data={deadlineData}
          type="bar"
          dataKey="total"
          nameKey="name"
        />
        <AnalyticsChart
          title="Berdasarkan Kategori"
          description="Kompetisi dikelompokkan berdasarkan kategori"
          icon={Tag}
          data={kategoriData}
          type="bar"
          dataKey="total"
          nameKey="name"
        />
      </div>

      <Card className="border-border/50">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="rounded-lg bg-primary/10 p-2">
              <List className="h-5 w-5 text-primary" />
            </div>
            <div>
              <CardTitle className="text-base">Semua Kompetisi</CardTitle>
              <CardDescription>Kelola data mentah hasil scraping</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow className="border-border/50 hover:bg-transparent">
                <TableHead className="text-muted-foreground">Sumber</TableHead>
                <TableHead className="text-muted-foreground">Judul</TableHead>
                <TableHead className="text-muted-foreground">Kategori</TableHead>
                <TableHead className="text-muted-foreground">Link Pendaftaran</TableHead>
                <TableHead className="text-right text-muted-foreground">Aksi</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.length > 0 ? (
                filtered.map((comp, idx) => (
                  <TableRow key={comp._id || comp.id || `comp-${idx}`} className="border-border/50">
                    <TableCell>
                      <Badge variant="secondary" className="text-xs">
                        {comp.sumber || "Unknown"}
                      </Badge>
                    </TableCell>
                    <TableCell className="max-w-sm">
                      <p className="line-clamp-2 table-primary">{comp.judul}</p>
                    </TableCell>
                    <TableCell>
                      {comp.kategori ? (
                        <Badge variant="outline" className="text-xs">
                          {comp.kategori}
                        </Badge>
                      ) : (
                        <span className="text-muted-foreground text-sm">—</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {comp.link_pendaftaran && comp.link_pendaftaran.length > 0 ? (
                        <div className="flex flex-wrap gap-1">
                          {comp.link_pendaftaran.map((link, i) => (
                            <a
                              key={i}
                              href={link}
                              target="_blank"
                              rel="noreferrer"
                              className="text-blue-500 hover:underline text-sm truncate max-w-[200px] block"
                            >
                              {link.length > 30 ? link.slice(0, 30) + '...' : link}
                            </a>
                          ))}
                        </div>
                      ) : comp.link_direct ? (
                        <a href={comp.link_direct} target="_blank" rel="noreferrer" className="text-blue-500 hover:underline text-sm">
                          Visit Link
                        </a>
                      ) : (
                        <span className="text-muted-foreground text-sm">—</span>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      {comp._id && (
                        <RowActions
                          onView={() => { setDetailComp(comp); setDetailOpen(true) }}
                          onDelete={() => deleteMutation.mutate(comp._id!)}
                          deleteLabel="this competition"
                        />
                      )}
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={5} className="h-32 text-center text-muted-foreground">
                    Tidak ada kompetisi
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title={detailComp?.judul || "Detail Kompetisi"}
        fields={[
          { label: "Judul", value: detailComp?.judul },
          { label: "Sumber", value: detailComp?.sumber },
          { label: "Kategori", value: detailComp?.kategori },
          { label: "Batas Akhir", value: detailComp?.deadline },
          { label: "Deskripsi", value: detailComp?.caption },
          { label: "Link Direct", value: detailComp?.link_direct ? <a href={detailComp.link_direct} target="_blank" rel="noreferrer" className="text-blue-500 hover:underline">{detailComp.link_direct}</a> : "—" },
          { label: "Link Pendaftaran", value: detailComp?.link_pendaftaran?.join(", ") },
        ]}
      />
    </div>
  )
}
