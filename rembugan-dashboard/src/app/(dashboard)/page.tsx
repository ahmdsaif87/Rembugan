"use client"

import { useEffect, useState } from "react"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Skeleton } from "@/components/ui/skeleton"
import {
  Users,
  FolderKanban,
  Trophy,
  Sparkles,
  FileText,
  ListChecks,
  TrendingUp,
  Activity,
} from "lucide-react"
import { fetchDashboardStats, fetchCompetitions } from "@/lib/api"

interface Stats {
  total_users: number
  active_projects: number
  scraped_competitions: number
  total_projects?: number
  total_showcases?: number
  pending_applications?: number
  total_tasks?: number
}

interface Competition {
  id: string
  sumber: string
  judul: string
  poster: string
  caption: string
  link_pendaftaran: string[]
  link_direct: string
}

const statCardConfig = [
  {
    key: "total_users" as const,
    label: "Total Users",
    icon: Users,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
  {
    key: "active_projects" as const,
    label: "Active Projects",
    icon: FolderKanban,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
  {
    key: "scraped_competitions" as const,
    label: "Competitions",
    icon: Trophy,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
  {
    key: "total_showcases" as const,
    label: "Showcases",
    icon: Sparkles,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
  {
    key: "pending_applications" as const,
    label: "Pending Applications",
    icon: FileText,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
  {
    key: "total_tasks" as const,
    label: "Total Tasks",
    icon: ListChecks,
    gradient: "from-rose-950 via-rose-900 to-rose-800",
    iconColor: "text-white",
    borderGlow: "hover:border-rose-500/30",
  },
]

export default function Overview() {
  const [stats, setStats] = useState<Stats>({
    total_users: 0,
    active_projects: 0,
    scraped_competitions: 0,
  })
  const [competitions, setCompetitions] = useState<Competition[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadData() {
      try {
        const [statsResponse, competitionsResponse] = await Promise.all([
          fetchDashboardStats(),
          fetchCompetitions(),
        ])

        if (statsResponse.status === 'success') {
          setStats(statsResponse.data)
        }

        if (competitionsResponse.status === 'success') {
          setCompetitions(competitionsResponse.data)
        }
      } catch (error) {
        console.error('Error loading dashboard data:', error)
      } finally {
        setLoading(false)
      }
    }

    loadData()
  }, [])

  if (loading) {
    return (
      <>
        <div className="space-y-6">
          {/* Header skeleton */}
          <div>
            <Skeleton className="h-8 w-48" />
            <Skeleton className="mt-2 h-4 w-72" />
          </div>

          {/* Stat cards skeleton */}
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {[...Array(6)].map((_, i) => (
              <Card key={i} className="border-border/50">
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <Skeleton className="h-4 w-28" />
                  <Skeleton className="h-8 w-8 rounded-lg" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-8 w-20" />
                  <Skeleton className="mt-2 h-3 w-32" />
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Table skeleton */}
          <Card className="border-border/50">
            <CardHeader>
              <Skeleton className="h-6 w-56" />
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {[...Array(5)].map((_, i) => (
                  <Skeleton key={i} className="h-12 w-full" />
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
        <div>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-900">
              <Activity className="h-5 w-5 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">Overview</h1>
              <p className="text-sm text-muted-foreground">
                Platform analytics and recent activity
              </p>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {statCardConfig.map((config) => {
            const value = stats[config.key] ?? 0
            const Icon = config.icon

            return (
              <Card
                key={config.key}
                className={`group border-border/50 bg-gradient-to-br ${config.gradient} transition-all duration-300 ${config.borderGlow}`}
              >
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium text-white">
                    {config.label}
                  </CardTitle>
                  <div className={`rounded-lg bg-background/50 p-2 ${config.iconColor}`}>
                    <Icon className="h-4 w-4 text-white" />
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold tracking-tight text-white">
                    {value.toLocaleString()}
                  </div>
                  <div className="mt-1 flex items-center gap-1 text-xs text-white">
                    <TrendingUp className="h-3 w-3 text-white" />
                    <span>Live data</span>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Competitions Table */}
        <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-rose-900">
                <Trophy className="h-4 w-4 text-white" />
              </div>
              <div>
                <CardTitle className="text-lg">Recent Scraped Competitions</CardTitle>
                <CardDescription>
                  Latest competitions found by the scraper
                </CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border/50 hover:bg-transparent">
                  <TableHead className="text-muted-foreground">ID</TableHead>
                  <TableHead className="text-muted-foreground">Judul</TableHead>
                  <TableHead className="text-muted-foreground">Sumber</TableHead>
                  <TableHead className="text-muted-foreground">Link</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {competitions.length > 0 ? (
                  competitions.slice(0, 10).map((comp) => (
                    <TableRow key={comp.id} className="border-border/50">
                      <TableCell className="font-mono text-xs text-muted-foreground">
                        {comp.id.substring(0, 8)}
                      </TableCell>
                      <TableCell>
                        <div className="font-medium line-clamp-1">{comp.judul}</div>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        <Badge variant="outline">{comp.sumber}</Badge>
                      </TableCell>
                      <TableCell>
                        <a href={comp.link_direct} target="_blank" rel="noreferrer" className="text-rose-800 hover:underline text-sm">
                          View
                        </a>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={4} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <Trophy className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No competitions data available</p>
                        <p className="text-xs">Run the scraper to fetch competition data</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </>
  )
}
