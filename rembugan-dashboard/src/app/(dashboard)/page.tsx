"use client"

import { useState, useMemo } from "react"
import { useQuery } from "@tanstack/react-query"
import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
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
import {
  Users,
  FolderKanban,
  Trophy,
  Sparkles,
  Clock,
  ListChecks,
  MoreVerticalIcon,
  EyeIcon,
  TrendingUp,
  TrendingDown,
} from "lucide-react"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { fetchDashboardStats, fetchCompetitions, fetchUsers } from "@/lib/api"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  AreaChart,
  Area,
} from "recharts"

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

interface User {
  id: string
  full_name: string
  photo_url: string | null
  created_at: string
}

const statCards = [
  {
    key: "total_users" as const,
    label: "Total Users",
    icon: Users,
    color: "blue",
    desc: "Active platform users",
  },
  {
    key: "active_projects" as const,
    label: "Active Projects",
    icon: FolderKanban,
    color: "emerald",
    desc: "Ongoing collaborations",
  },
  {
    key: "scraped_competitions" as const,
    label: "Competitions",
    icon: Trophy,
    color: "violet",
    desc: "Scraped competitions",
  },
  {
    key: "total_showcases" as const,
    label: "Showcases",
    icon: Sparkles,
    color: "orange",
    desc: "Portfolio showcases",
  },
  {
    key: "pending_applications" as const,
    label: "Pending Review",
    icon: Clock,
    color: "amber",
    desc: "Awaiting review",
  },
  {
    key: "total_tasks" as const,
    label: "Total Tasks",
    icon: ListChecks,
    color: "rose",
    desc: "Across all projects",
  },
]

const colorConfig: Record<string, { bg: string; text: string; border: string; bar: string }> = {
  blue: {
    bg: "bg-blue-50 dark:bg-blue-950/20",
    text: "text-blue-600 dark:text-blue-400",
    border: "border-t-blue-500",
    bar: "#3b82f6",
  },
  emerald: {
    bg: "bg-emerald-50 dark:bg-emerald-950/20",
    text: "text-emerald-600 dark:text-emerald-400",
    border: "border-t-emerald-500",
    bar: "#10b981",
  },
  violet: {
    bg: "bg-violet-50 dark:bg-violet-950/20",
    text: "text-violet-600 dark:text-violet-400",
    border: "border-t-violet-500",
    bar: "#8b5cf6",
  },
  orange: {
    bg: "bg-orange-50 dark:bg-orange-950/20",
    text: "text-orange-600 dark:text-orange-400",
    border: "border-t-orange-500",
    bar: "#f97316",
  },
  amber: {
    bg: "bg-amber-50 dark:bg-amber-950/20",
    text: "text-amber-600 dark:text-amber-400",
    border: "border-t-amber-500",
    bar: "#f59e0b",
  },
  rose: {
    bg: "bg-rose-50 dark:bg-rose-950/20",
    text: "text-rose-600 dark:text-rose-400",
    border: "border-t-rose-500",
    bar: "#f43f5e",
  },
}

export default function Overview() {
  const [detailComp, setDetailComp] = useState<Competition | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)

  const { data: stats = { total_users: 0, active_projects: 0, scraped_competitions: 0 }, isLoading: statsLoading } = useQuery({
    queryKey: ['dashboardStats'],
    queryFn: async () => {
      const res = await fetchDashboardStats()
      return (res.status === 'success' ? res.data : { total_users: 0, active_projects: 0, scraped_competitions: 0 }) as Stats
    },
  })

  const { data: competitions = [], isLoading: compLoading } = useQuery({
    queryKey: ['competitions'],
    queryFn: async () => {
      const res = await fetchCompetitions()
      return (res.status === 'success' ? res.data : []) as Competition[]
    },
  })

  const { data: users = [] } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetchUsers(0, 200)
      return (res.status === 'success' ? res.data : []) as User[]
    },
  })

  const loading = statsLoading || compLoading

  const sourceData = useMemo(() => {
    const counts: Record<string, number> = {}
    competitions.forEach((c) => {
      const source = c.sumber || "Unknown"
      counts[source] = (counts[source] || 0) + 1
    })
    return Object.entries(counts)
      .map(([name, total]) => ({ name, total }))
      .sort((a, b) => b.total - a.total)
      .slice(0, 6)
  }, [competitions])

  const userGrowthData = useMemo(() => {
    const monthly: Record<string, number> = {}
    users.forEach((u) => {
      const date = new Date(u.created_at)
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`
      monthly[key] = (monthly[key] || 0) + 1
    })
    return Object.entries(monthly)
      .sort(([a], [b]) => a.localeCompare(b))
      .slice(-6)
      .map(([name, total]) => ({ name, total }))
  }, [users])

  const latestUsers = useMemo(() => {
    return [...users]
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 5)
  }, [users])

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Overview</h1>
          <p className="text-sm text-muted-foreground">Platform analytics and insights</p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        {statCards.map((config) => {
          const value = config.key === 'scraped_competitions' ? competitions.length : (stats[config.key] ?? 0)
          const colors = colorConfig[config.color]
          const Icon = config.icon
          return (
            <Card
              key={config.key}
              className={`border-t-4 ${colors.border} shadow-sm border-x-0 border-b-0`}
            >
              <CardHeader className="pb-2">
                <div className="flex items-center justify-between">
                  <CardDescription className="text-xs font-medium uppercase tracking-wider">
                    {config.label}
                  </CardDescription>
                  <div className={`rounded-lg p-1.5 ${colors.bg}`}>
                    <Icon className={`h-4 w-4 ${colors.text}`} />
                  </div>
                </div>
                <CardTitle className="text-3xl font-bold tabular-nums mt-1">
                  {value.toLocaleString()}
                </CardTitle>
              </CardHeader>
            </Card>
          )
        })}
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2 shadow-sm border-0">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-primary/10 p-2">
                <TrendingUp className="h-5 w-5 text-primary" />
              </div>
              <div>
                <CardTitle className="text-base">User Growth</CardTitle>
                <CardDescription>New users per month</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-72">
              {userGrowthData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={userGrowthData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="userGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.25} />
                        <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="hsl(var(--border))" />
                    <XAxis dataKey="name" stroke="hsl(var(--muted-foreground))" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis stroke="hsl(var(--muted-foreground))" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: 'hsl(var(--card))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                      }}
                    />
                    <Area type="monotone" dataKey="total" stroke="hsl(var(--primary))" strokeWidth={2} fill="url(#userGradient)" />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
                  No user growth data yet
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="shadow-sm border-0">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-violet-50 p-2 dark:bg-violet-950/20">
                <Trophy className="h-5 w-5 text-violet-600 dark:text-violet-400" />
              </div>
              <div>
                <CardTitle className="text-base">By Source</CardTitle>
                <CardDescription>Competition distribution</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-72">
              {sourceData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={sourceData} layout="vertical" margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="hsl(var(--border))" />
                    <XAxis type="number" stroke="hsl(var(--muted-foreground))" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis dataKey="name" type="category" stroke="hsl(var(--muted-foreground))" fontSize={12} tickLine={false} axisLine={false} width={80} />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: 'hsl(var(--card))',
                        border: '1px solid hsl(var(--border))',
                        borderRadius: '8px',
                      }}
                    />
                    <Bar dataKey="total" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
                  No source data
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2 shadow-sm border-0">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-emerald-50 p-2 dark:bg-emerald-950/20">
                <Users className="h-5 w-5 text-emerald-600 dark:text-emerald-400" />
              </div>
              <div>
                <CardTitle className="text-base">Recent Competitions</CardTitle>
                <CardDescription>Latest scraped competitions</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow className="border-b border-border/50 hover:bg-transparent">
                  <TableHead className="text-xs font-medium text-muted-foreground">Source</TableHead>
                  <TableHead className="text-xs font-medium text-muted-foreground">Title</TableHead>
                  <TableHead className="text-xs font-medium text-muted-foreground text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {competitions.length > 0 ? (
                  competitions.slice(0, 6).map((comp) => (
                    <TableRow key={comp.id} className="border-b border-border/30">
                      <TableCell>
                        <Badge variant="secondary" className="text-xs font-normal">
                          {comp.sumber || "Unknown"}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <span className="text-sm line-clamp-1 table-primary">{comp.judul}</span>
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon" className="size-7 text-muted-foreground hover:text-foreground hover:bg-accent">
                              <MoreVerticalIcon className="h-3.5 w-3.5" />
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
                    <TableCell colSpan={3} className="h-24 text-center text-sm text-muted-foreground">
                      No competitions available
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        <Card className="shadow-sm border-0">
          <CardHeader>
            <div className="flex items-center gap-3">
              <div className="rounded-lg bg-blue-50 p-2 dark:bg-blue-950/20">
                <Users className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <CardTitle className="text-base">Latest Users</CardTitle>
                <CardDescription>Recently joined</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            {latestUsers.length > 0 ? (
              <div className="divide-y divide-border/30">
                {latestUsers.map((user) => (
                  <div key={user.id} className="flex items-center gap-3 px-6 py-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-xs font-medium text-primary">
                      {user.full_name.charAt(0).toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{user.full_name}</p>
                      <p className="text-xs text-muted-foreground">
                        {new Date(user.created_at).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="flex h-24 items-center justify-center text-sm text-muted-foreground px-6">
                No users yet
              </div>
            )}
          </CardContent>
        </Card>
      </div>

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
