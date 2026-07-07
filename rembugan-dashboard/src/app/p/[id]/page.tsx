"use client"

import { use, useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { MessageSquare, ExternalLink, Smartphone, Loader2, FolderOpen, Users, ListChecks } from "lucide-react"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"
const APP_URL = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"

interface ProjectData {
  id: number
  title: string
  description: string
  status: string
  required_skills: string[]
  owner_name: string | null
  members: Array<{ name: string; role: string }>
  tasks: Array<{ title: string; status: string }>
}

export default function ProjectPublicPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [project, setProject] = useState<ProjectData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    setIsMobile(/Android|iPhone|iPad|iPod/i.test(navigator.userAgent))
  }, [])

  useEffect(() => {
    async function fetchProject() {
      try {
        const res = await fetch(`${API_BASE_URL}/projects/${id}`)
        const data = await res.json()
        if (data.status === "success") {
          setProject(data.data)
        } else {
          setError("Project tidak ditemukan")
        }
      } catch {
        setError("Gagal memuat data")
      } finally {
        setLoading(false)
      }
    }
    fetchProject()
  }, [id])

  function openInApp() {
    window.location.href = `rembugan://project/${id}`
    setTimeout(() => {
      if (!document.hidden) {
        window.location.href = `https://play.google.com/store/apps/details?id=com.rembugan.app`
      }
    }, 2000)
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    )
  }

  if (error || !project) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
        <Card className="w-full max-w-sm shadow-lg">
          <CardContent className="flex flex-col items-center gap-4 py-12">
            <FolderOpen className="h-12 w-12 text-muted-foreground/50" />
            <p className="text-lg font-medium text-muted-foreground text-center">{error || "Project tidak ditemukan"}</p>
            <Button variant="outline" onClick={() => router.push(APP_URL)}>
              Go to Rembugan
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  const statusColor: Record<string, string> = {
    open: "border-blue-500/30 bg-blue-500/10 text-blue-400",
    ongoing: "border-neutral-500/30 bg-neutral-500/10 text-neutral-400",
    completed: "border-emerald-500/30 bg-emerald-500/10 text-emerald-400",
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
      <Card className="w-full max-w-sm shadow-xl border-border/50">
        <div className="flex flex-col items-center pt-8 pb-4 px-6">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 mb-4">
            <FolderOpen className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-center">{project.title}</h1>
          <p className="text-sm text-muted-foreground mt-1">by {project.owner_name || "Unknown"}</p>
          <Badge variant="outline" className={`mt-2 text-xs ${statusColor[project.status] || ""}`}>
            {project.status}
          </Badge>
        </div>
        <CardContent className="space-y-5 pb-8 px-6">
          <p className="text-sm text-muted-foreground leading-relaxed text-center">{project.description}</p>

          {project.required_skills.length > 0 && (
            <div className="space-y-2">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide">Required Skills</p>
              <div className="flex flex-wrap gap-1.5">
                {project.required_skills.map((skill) => (
                  <Badge key={skill} variant="secondary" className="text-xs">
                    {skill}
                  </Badge>
                ))}
              </div>
            </div>
          )}

          <div className="flex gap-4 justify-center text-sm text-muted-foreground">
            <div className="flex items-center gap-1.5">
              <Users className="h-4 w-4" />
              <span>{project.members?.length || 0} members</span>
            </div>
            <div className="flex items-center gap-1.5">
              <ListChecks className="h-4 w-4" />
              <span>{project.tasks?.length || 0} tasks</span>
            </div>
          </div>

          <div className="flex flex-col gap-2 pt-2">
            <Button size="lg" className="w-full gap-2" onClick={openInApp}>
              {isMobile ? <Smartphone className="h-4 w-4" /> : <ExternalLink className="h-4 w-4" />}
              {isMobile ? "Open in App" : "View in App"}
            </Button>
            <Button
              variant="outline"
              size="lg"
              className="w-full gap-2"
              onClick={() => window.location.href = `https://play.google.com/store/apps/details?id=com.rembugan.app`}
            >
              <MessageSquare className="h-4 w-4" />
              Download App
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
