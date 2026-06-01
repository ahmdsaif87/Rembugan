"use client"

import { useEffect, useState } from "react"
import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Skeleton } from "@/components/ui/skeleton"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Trophy, TrendingUpIcon, MoreVerticalIcon, EyeIcon } from "lucide-react"
import { DetailSheet } from "@/components/ui/detail-sheet"
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

const statCards = [
  { key: "total_users" as const, label: "Total Users", desc: "Active platform users" },
  { key: "active_projects" as const, label: "Active Projects", desc: "Ongoing collaborations" },
  { key: "scraped_competitions" as const, label: "Competitions", desc: "Scraped competitions" },
  { key: "total_showcases" as const, label: "Showcases", desc: "Portfolio showcases" },
  { key: "pending_applications" as const, label: "Pending", desc: "Awaiting review" },
  { key: "total_tasks" as const, label: "Total Tasks", desc: "Across all projects" },
]

export default function Overview() {
  const [detailComp, setDetailComp] = useState<Competition | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)
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
      <div className="flex flex-col gap-4">
        <Skeleton className="h-8 w-48" />
        <div className="grid grid-cols-1 gap-4 @xl/main:grid-cols-2 @5xl/main:grid-cols-4">
          {[...Array(6)].map((_, i) => (
            <Card key={i}>
              <CardHeader>
                <Skeleton className="h-4 w-24" />
                <Skeleton className="mt-2 h-8 w-20" />
              </CardHeader>
            </Card>
          ))}
        </div>
        <Skeleton className="h-64 w-full" />
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="*:data-[slot=card]:shadow-xs @xl/main:grid-cols-2 @5xl/main:grid-cols-4 grid grid-cols-1 gap-4 *:data-[slot=card]:bg-gradient-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card dark:*:data-[slot=card]:bg-card">
        {statCards.map((config) => {
          const value = stats[config.key] ?? 0
          return (
            <Card key={config.key} className="@container/card">
              <CardHeader className="relative">
                <CardDescription>{config.label}</CardDescription>
                <CardTitle className="@[250px]/card:text-3xl text-2xl font-semibold tabular-nums">
                  {value.toLocaleString()}
                </CardTitle>
                <div className="absolute right-4 top-4">
                  <Badge variant="outline" className="flex gap-1 rounded-lg text-xs">
                    <TrendingUpIcon className="size-3" />
                    Live
                  </Badge>
                </div>
              </CardHeader>
              <CardFooter className="flex-col items-start gap-1 text-sm">
                <div className="line-clamp-1 flex gap-2 font-medium">
                  Real-time data <TrendingUpIcon className="size-4" />
                </div>
                <div className="text-muted-foreground">{config.desc}</div>
              </CardFooter>
            </Card>
          )
        })}
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <div>
              <CardTitle>Recent Scraped Competitions</CardTitle>
              <CardDescription>
                Latest competitions found by the scraper
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <div className="px-4 pb-4 lg:px-6">
          <div className="overflow-hidden rounded-lg border">
            <Table>
              <TableHeader className="bg-muted">
                <TableRow>
                  <TableHead className="text-muted-foreground">ID</TableHead>
                  <TableHead className="text-muted-foreground">Judul</TableHead>
                  <TableHead className="text-muted-foreground">Sumber</TableHead>
                  <TableHead className="text-muted-foreground">Link</TableHead>
                  <TableHead className="text-muted-foreground text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {competitions.length > 0 ? (
                  competitions.slice(0, 10).map((comp) => (
                    <TableRow key={comp.id}>
                      <TableCell className="font-mono text-xs text-muted-foreground">
                        {comp.id.substring(0, 8)}
                      </TableCell>
                      <TableCell>
                        <div className="font-medium line-clamp-1">{comp.judul}</div>
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="px-1.5 text-muted-foreground">
                          {comp.sumber}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <a href={comp.link_direct} target="_blank" rel="noreferrer" className="text-foreground/70 hover:underline text-sm">
                          View
                        </a>
                      </TableCell>
                      <TableCell className="text-right">
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
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={5} className="h-32 text-center">
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
          </div>
        </div>
      </Card>

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title={detailComp?.judul || "Competition Details"}
        fields={[
          { label: "Title", value: detailComp?.judul },
          { label: "Source", value: detailComp?.sumber },
          { label: "Caption", value: detailComp?.caption },
          { label: "Direct Link", value: detailComp?.link_direct ? <a href={detailComp.link_direct} target="_blank" rel="noreferrer" className="text-blue-500 hover:underline">{detailComp.link_direct}</a> : "—" },
          { label: "Registration Links", value: detailComp?.link_pendaftaran?.join(", ") },
        ]}
      />
    </div>
  )
}
