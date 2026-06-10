"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
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
import { Activity, Calendar, Tag, Trash2, List, EyeIcon, MoreVerticalIcon } from "lucide-react"
import {
  BarChart,
  Bar,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts"

import { DetailSheet } from "@/components/ui/detail-sheet"
import { fetchCompetitions, deleteCompetition } from "@/lib/api"

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
      }
    },
  })

  const sourceData = useMemo(() => {
    const counts: Record<string, number> = {}
    competitions.forEach((c) => {
      const source = c.sumber || "Unknown"
      counts[source] = (counts[source] || 0) + 1
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => b.total - a.total)
  }, [competitions])

  const deadlineData = useMemo(() => {
    const counts: Record<string, number> = {}
    competitions.forEach((c) => {
      if (c.deadline) {
        const d = c.deadline
        counts[d] = (counts[d] || 0) + 1
      }
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => a.name.localeCompare(b.name))
  }, [competitions])

  const kategoriData = useMemo(() => {
    const counts: Record<string, number> = {}
    competitions.forEach((c) => {
      if (c.kategori) {
        const k = c.kategori
        counts[k] = (counts[k] || 0) + 1
      }
    })
    return Object.keys(counts).map((key) => ({
      name: key,
      total: counts[key],
    })).sort((a, b) => b.total - a.total)
  }, [competitions])

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
          <h1 className="text-2xl font-bold tracking-tight">Competitions Data</h1>
          <p className="text-sm text-muted-foreground">
            Visualizing scraped competitions data
          </p>
        </div>
      </div>

      <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Activity className="h-4 w-4 text-muted-foreground" />
              <div>
                <CardTitle>By Source</CardTitle>
                <CardDescription>Distribution by source</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              {sourceData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={sourceData} layout="vertical" margin={{ top: 10, right: 30, left: 80, bottom: 10 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#333" />
                    <XAxis type="number" stroke="#888" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis dataKey="name" type="category" stroke="#888" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip
                      contentStyle={{ backgroundColor: '#ffffffff', borderColor: '#374151', borderRadius: '8px' }}
                    />
                    <Bar dataKey="total" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} name="Competitions" />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-full items-center justify-center text-muted-foreground">
                  No data available
                </div>
              )}
            </div>
          </CardContent>
        </Card>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Calendar className="h-4 w-4 text-muted-foreground" />
              <div>
                <CardTitle>By Deadline</CardTitle>
                <CardDescription>Competitions grouped by deadline</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              {deadlineData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={deadlineData} margin={{ top: 10, right: 30, left: 0, bottom: 20 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#333" />
                    <XAxis
                      dataKey="name"
                      stroke="#888"
                      fontSize={12}
                      tickLine={false}
                      axisLine={false}
                    />
                    <YAxis
                      stroke="#888"
                      fontSize={12}
                      tickLine={false}
                      axisLine={false}
                    />
                    <Tooltip
                      cursor={{fill: 'rgba(255, 255, 255, 0.05)'}}
                      contentStyle={{ backgroundColor: '#ffffffff', borderColor: '#374151', borderRadius: '8px' }}
                    />
                    <Bar
                      dataKey="total"
                      fill="#f59e0b"
                      radius={[4, 4, 0, 0]}
                      name="Competitions"
                    />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-full items-center justify-center text-muted-foreground">
                  No deadline data available
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Tag className="h-4 w-4 text-muted-foreground" />
              <div>
                <CardTitle>By Category</CardTitle>
                <CardDescription>Competitions grouped by category</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              {kategoriData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={kategoriData} margin={{ top: 10, right: 30, left: 0, bottom: 20 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#333" />
                    <XAxis dataKey="name" stroke="#888" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis stroke="#888" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip
                      contentStyle={{ backgroundColor: '#ffffffff', borderColor: '#374151', borderRadius: '8px' }}
                    />
                    <Area type="monotone" dataKey="total" fill="#10b981" fillOpacity={0.3} stroke="#10b981" strokeWidth={2} name="Competitions" />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-full items-center justify-center text-muted-foreground">
                  No category data available
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="border-border/50">
        <CardHeader>
          <div className="flex items-center gap-2">
            <List className="h-4 w-4 text-muted-foreground" />
            <div>
              <CardTitle>All Scraped Competitions</CardTitle>
              <CardDescription>Manage the raw data obtained from scraping</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow className="border-border/50 hover:bg-transparent">
                <TableHead className="text-muted-foreground">Source</TableHead>
                <TableHead className="text-muted-foreground">Title</TableHead>
                <TableHead className="text-muted-foreground">Kategori</TableHead>
                <TableHead className="text-muted-foreground">Registration Link</TableHead>
                <TableHead className="text-right text-muted-foreground">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {competitions.length > 0 ? (
                competitions.map((comp) => (
                  <TableRow key={comp._id || comp.id || Math.random().toString()} className="border-border/50">
                    <TableCell>
                      <Badge variant="secondary" className="text-xs">
                        {comp.sumber || "Unknown"}
                      </Badge>
                    </TableCell>
                    <TableCell className="font-medium max-w-sm">
                      <p className="line-clamp-2">{comp.judul}</p>
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
                        <AlertDialog>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon" className="flex size-8 text-muted-foreground data-[state=open]:bg-muted">
                                <MoreVerticalIcon />
                                <span className="sr-only">Open menu</span>
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end" className="w-32">
                              <DropdownMenuItem onClick={() => { setDetailComp(comp); setDetailOpen(true); }}>
                                <EyeIcon />
                                View Details
                              </DropdownMenuItem>
                              <AlertDialogTrigger asChild>
                                <DropdownMenuItem className="text-destructive">
                                  <Trash2 />
                                  Delete
                                </DropdownMenuItem>
                              </AlertDialogTrigger>
                            </DropdownMenuContent>
                          </DropdownMenu>
                          <AlertDialogContent>
                            <AlertDialogHeader>
                              <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                              <AlertDialogDescription>
                                This action cannot be undone. This will permanently delete the scraped competition.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Cancel</AlertDialogCancel>
                              <AlertDialogAction onClick={() => deleteMutation.mutate(comp._id!)} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                                Delete
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      )}
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={5} className="h-32 text-center text-muted-foreground">
                    No competitions found
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
        title={detailComp?.judul || "Competition Details"}
        fields={[
          { label: "Title", value: detailComp?.judul },
          { label: "Source", value: detailComp?.sumber },
          { label: "Kategori", value: detailComp?.kategori },
          { label: "Deadline", value: detailComp?.deadline },
          { label: "Caption", value: detailComp?.caption },
          { label: "Direct Link", value: detailComp?.link_direct ? <a href={detailComp.link_direct} target="_blank" rel="noreferrer" className="text-blue-500 hover:underline">{detailComp.link_direct}</a> : "—" },
          { label: "Registration Links", value: detailComp?.link_pendaftaran?.join(", ") },
        ]}
      />
    </div>
  )
}
