"use client"

import { useState, useMemo } from "react"
import { useQuery } from "@tanstack/react-query"
import { Badge } from "@/components/ui/badge"
import { TableCell } from "@/components/ui/table"
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
  TrendingUp,
} from "lucide-react"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { fetchDashboardStats, fetchCompetitions, fetchUsers } from "@/lib/api"
import { KPICard } from "@/components/dashboard/kpi-card"
import { KPIGrid } from "@/components/dashboard/kpi-grid"
import { AnalyticsChart } from "@/components/dashboard/analytics-chart"
import { RecentItems } from "@/components/dashboard/recent-items"

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
    desc: "Active platform users",
  },
  {
    key: "active_projects" as const,
    label: "Active Projects",
    icon: FolderKanban,
    desc: "Ongoing collaborations",
  },
  {
    key: "scraped_competitions" as const,
    label: "Competitions",
    icon: Trophy,
    desc: "Scraped competitions",
  },
  {
    key: "total_showcases" as const,
    label: "Showcases",
    icon: Sparkles,
    desc: "Portfolio showcases",
  },
  {
    key: "pending_applications" as const,
    label: "Pending Review",
    icon: Clock,
    desc: "Awaiting review",
  },
  {
    key: "total_tasks" as const,
    label: "Total Tasks",
    icon: ListChecks,
    desc: "Across all projects",
  },
]

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
    <div className="flex flex-col gap-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Overview</h1>
          <p className="text-sm text-muted-foreground">Platform analytics and insights</p>
        </div>
      </div>

      <KPIGrid>
        {statCards.map((config) => {
          const value = config.key === 'scraped_competitions' ? competitions.length : (stats[config.key] ?? 0)
          return (
            <KPICard
              key={config.key}
              label={config.label}
              value={value.toLocaleString()}
              icon={config.icon}
              description={config.desc}
            />
          )
        })}
      </KPIGrid>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <AnalyticsChart 
          title="User Growth" 
          description="New users per month" 
          icon={TrendingUp} 
          data={userGrowthData} 
          type="area" 
          dataKey="total" 
          nameKey="name" 
          className="lg:col-span-2"
        />
        <AnalyticsChart 
          title="By Source" 
          description="Competition distribution" 
          icon={Trophy} 
          data={sourceData} 
          type="bar" 
          dataKey="total" 
          nameKey="name" 
        />
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <RecentItems 
          title="Recent Competitions" 
          description="Latest scraped competitions" 
          icon={Trophy} 
          items={competitions.slice(0, 6)} 
          columns={[{ label: "Source" }, { label: "Title" }]}
          onAction={(comp) => { setDetailComp(comp); setDetailOpen(true); }}
          renderRow={(comp) => (
            <>
              <TableCell>
                <Badge variant="secondary" className="text-xs font-normal">
                  {comp.sumber || "Unknown"}
                </Badge>
              </TableCell>
              <TableCell>
                <span className="text-sm font-medium truncate max-w-[200px]">{comp.judul}</span>
              </TableCell>
            </>
          )}
        />
        <RecentItems 
          title="Latest Users" 
          description="Recently joined" 
          icon={Users} 
          items={latestUsers} 
          columns={[{ label: "User" }, { label: "Joined" }]}
          onAction={(user) => {}} 
          renderRow={(user) => (
            <>
              <TableCell>
                <div className="flex items-center gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted text-xs font-medium">
                    {user.full_name.charAt(0).toUpperCase()}
                  </div>
                  <span className="text-sm font-medium truncate">{user.full_name}</span>
                </div>
              </TableCell>
              <TableCell>
                <span className="text-xs text-muted-foreground">
                {new Date(user.created_at).toLocaleDateString()}
                </span>
              </TableCell>
            </>
          )}
        />
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
