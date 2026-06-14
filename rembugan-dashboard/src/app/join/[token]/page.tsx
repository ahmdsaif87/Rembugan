"use client"

import { use, useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { MessageSquare, ExternalLink, Smartphone, Loader2, FolderOpen, AlertCircle } from "lucide-react"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"

interface InviteData {
  valid: boolean
  project_id: number
  project_title: string | null
}

export default function JoinProjectPage({ params }: { params: Promise<{ token: string }> }) {
  const { token } = use(params)
  const router = useRouter()
  const [invite, setInvite] = useState<InviteData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    setIsMobile(/Android|iPhone|iPad|iPod/i.test(navigator.userAgent))
  }, [])

  useEffect(() => {
    async function verifyToken() {
      try {
        const res = await fetch(`${API_BASE_URL}/qr/project/join/${token}`)
        const data = await res.json()
        if (data.status === "success") {
          setInvite(data.data)
        } else {
          setError(data.detail || "Undangan tidak valid")
        }
      } catch {
        setError("Gagal memverifikasi undangan")
      } finally {
        setLoading(false)
      }
    }
    verifyToken()
  }, [token])

  function openInApp() {
    window.location.href = `rembugan://project/join/${token}`
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

  if (error || !invite) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
        <Card className="w-full max-w-sm shadow-lg">
          <CardContent className="flex flex-col items-center gap-4 py-12">
            <AlertCircle className="h-12 w-12 text-destructive/50" />
            <p className="text-lg font-medium text-muted-foreground text-center">{error}</p>
            <Button variant="outline" onClick={() => router.push("/")}>
              Go to Rembugan
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
      <Card className="w-full max-w-sm shadow-xl border-border/50">
        <div className="flex flex-col items-center pt-8 pb-4 px-6">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 mb-4">
            <FolderOpen className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-center">Project Invitation</h1>
          <p className="text-sm text-muted-foreground mt-1">
            You&apos;ve been invited to join
          </p>
          <p className="text-lg font-semibold mt-2 text-center">{invite.project_title || "a project"}</p>
        </div>
        <CardContent className="space-y-4 pb-8 px-6">
          <div className="flex justify-center gap-2">
            <Badge variant="secondary" className="text-xs">
              Invite Active
            </Badge>
          </div>
          <div className="flex flex-col gap-2 pt-2">
            <Button
              size="lg"
              className="w-full gap-2"
              onClick={openInApp}
            >
              {isMobile ? (
                <Smartphone className="h-4 w-4" />
              ) : (
                <ExternalLink className="h-4 w-4" />
              )}
              {isMobile ? "Open in App to Join" : "View in Rembugan App"}
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
