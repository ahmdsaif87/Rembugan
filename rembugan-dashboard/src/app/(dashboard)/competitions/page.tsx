"use client"

import { useEffect, useState, useMemo } from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
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
import { Trophy, Activity, Filter, Trash2, List } from "lucide-react"
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Radar,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Legend
} from "recharts"

import { fetchCompetitions, fetchUsers, deleteCompetition } from "@/lib/api"

interface Competition {
  _id?: string
  id?: string
  sumber: string
  judul: string
  caption?: string
  link_pendaftaran?: string[]
  link_direct?: string
}

interface UserSkill {
  skill: {
    name: string
  }
}

interface User {
  id: string
  full_name: string
  skills?: UserSkill[]
}

export default function CompetitionsPage() {
  const [competitions, setCompetitions] = useState<Competition[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [selectedUserId, setSelectedUserId] = useState<string>("all")
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadData() {
      try {
        const [compRes, usersRes] = await Promise.all([
          fetchCompetitions(),
          fetchUsers(0, 100),
        ])

        if (compRes.status === 'success') {
          setCompetitions(compRes.data)
        }
        if (usersRes.status === 'success') {
          setUsers(usersRes.data)
        }
      } catch (error) {
        console.error("Error loading data:", error)
      } finally {
        setLoading(false)
      }
    }
    loadData()
  }, [])

  async function handleDelete(id: string) {
    const response = await deleteCompetition(id)
    if (response.status === 'success') {
      setCompetitions(competitions.filter(c => c._id !== id))
    }
  }

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

  const radarData = useMemo(() => {
    if (selectedUserId === "all") return []
    const user = users.find(u => u.id === selectedUserId)
    if (!user || !user.skills || user.skills.length === 0) return []

    return user.skills.map(us => {
      const skillName = us.skill.name.toLowerCase()
      let matchCount = 0
      competitions.forEach(c => {
        const textToSearch = `${c.judul || ''} ${c.caption || ''}`.toLowerCase()
        if (textToSearch.includes(skillName)) {
          matchCount++
        }
      })
      return {
        subject: us.skill.name,
        A: matchCount,
        fullMark: competitions.length > 0 ? competitions.length : 100,
      }
    })
  }, [selectedUserId, users, competitions])

  const selectedUser = users.find(u => u.id === selectedUserId)

  if (loading) {
    return (
      <div className="space-y-6">
        <div>
          <Skeleton className="h-8 w-48" />
          <Skeleton className="mt-2 h-4 w-72" />
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          <Skeleton className="h-[400px] w-full" />
          <Skeleton className="h-[400px] w-full" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-900">
            <Trophy className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Competitions Data</h1>
            <p className="text-sm text-muted-foreground">
              Visualizing scraped competitions and user matching
            </p>
          </div>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center gap-2">
              <Activity className="h-4 w-4 text-rose-600" />
              <div>
                <CardTitle>Competitions by Source</CardTitle>
                <CardDescription>Distribution of scraped competitions</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-[350px] w-full">
              {sourceData.length > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={sourceData} margin={{ top: 10, right: 30, left: 0, bottom: 20 }}>
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
                      contentStyle={{ backgroundColor: '#1f2937', borderColor: '#374151', borderRadius: '8px' }}
                    />
                    <Bar 
                      dataKey="total" 
                      fill="#e11d48" 
                      radius={[4, 4, 0, 0]} 
                      name="Competitions" 
                    />
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

        <Card className="border-border/50">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Filter className="h-4 w-4 text-rose-600" />
                <div>
                  <CardTitle>User Skill Match</CardTitle>
                  <CardDescription>Competition availability by user skill</CardDescription>
                </div>
              </div>
              <Select value={selectedUserId} onValueChange={setSelectedUserId}>
                <SelectTrigger className="w-[200px]">
                  <SelectValue placeholder="Select a user..." />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all" disabled>Select a user...</SelectItem>
                  {users.map(u => (
                    <SelectItem key={u.id} value={u.id}>
                      {u.full_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            <div className="h-[350px] w-full">
              {selectedUserId === "all" ? (
                <div className="flex h-full items-center justify-center text-muted-foreground">
                  Please select a user to view their skill match radar
                </div>
              ) : !selectedUser?.skills?.length ? (
                <div className="flex h-full flex-col items-center justify-center text-muted-foreground">
                  <p>User {selectedUser?.full_name} has no skills listed.</p>
                </div>
              ) : radarData.length === 0 ? (
                <div className="flex h-full flex-col items-center justify-center text-muted-foreground">
                  <p>No matching competitions found for {selectedUser?.full_name}'s skills.</p>
                </div>
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <RadarChart cx="50%" cy="50%" outerRadius="70%" data={radarData}>
                    <PolarGrid stroke="#333" />
                    <PolarAngleAxis dataKey="subject" tick={{ fill: '#888', fontSize: 12 }} />
                    <PolarRadiusAxis angle={30} domain={[0, 'dataMax']} tick={{ fill: '#888' }} />
                    <Tooltip 
                      contentStyle={{ backgroundColor: '#1f2937', borderColor: '#374151', borderRadius: '8px' }}
                    />
                    <Radar 
                      name={`${selectedUser?.full_name}'s Matches`} 
                      dataKey="A" 
                      stroke="#e11d48" 
                      fill="#e11d48" 
                      fillOpacity={0.4} 
                    />
                    <Legend wrapperStyle={{ paddingTop: '20px' }}/>
                  </RadarChart>
                </ResponsiveContainer>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="border-border/50">
        <CardHeader>
          <div className="flex items-center gap-2">
            <List className="h-4 w-4 text-rose-600" />
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
                <TableHead className="text-muted-foreground">Link</TableHead>
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
                      {comp.link_direct ? (
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
                          <AlertDialogTrigger asChild>
                            <Button variant="ghost" size="icon" className="text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </AlertDialogTrigger>
                          <AlertDialogContent>
                            <AlertDialogHeader>
                              <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                              <AlertDialogDescription>
                                This action cannot be undone. This will permanently delete the scraped competition.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel>Cancel</AlertDialogCancel>
                              <AlertDialogAction onClick={() => handleDelete(comp._id!)} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
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
                  <TableCell colSpan={4} className="h-32 text-center text-muted-foreground">
                    No competitions found
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
