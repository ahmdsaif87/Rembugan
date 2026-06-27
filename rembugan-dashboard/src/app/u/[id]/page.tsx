"use client"

import { use, useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { MessageSquare, ExternalLink, Smartphone, Loader2, User } from "lucide-react"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"
const APP_URL = process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"

interface ProfileData {
  id: string
  full_name: string
  interest: string | null
  bio: string | null
  photo_url: string | null
  skills: string[]
}

const lightVars = {
  "--background": "0 0% 100%",
  "--foreground": "222 34% 11%",
  "--card": "0 0% 100%",
  "--card-foreground": "222 34% 11%",
  "--popover": "0 0% 100%",
  "--popover-foreground": "222 34% 11%",
  "--primary": "234 90% 63%",
  "--primary-foreground": "0 0% 100%",
  "--secondary": "220 3% 96%",
  "--secondary-foreground": "222 34% 11%",
  "--muted": "220 3% 96%",
  "--muted-foreground": "227 8% 46%",
  "--accent": "220 3% 96%",
  "--accent-foreground": "222 34% 11%",
  "--destructive": "0 84% 59%",
  "--destructive-foreground": "0 0% 100%",
  "--border": "216 11% 91%",
  "--input": "216 11% 91%",
  "--ring": "234 90% 63%",
  "--radius": "0.75rem",
} as React.CSSProperties

export default function UserProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [profile, setProfile] = useState<ProfileData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    setIsMobile(/Android|iPhone|iPad|iPod/i.test(navigator.userAgent))
  }, [])

  useEffect(() => {
    async function fetchProfile() {
      try {
        const res = await fetch(`${API_BASE_URL}/profile/${id}`, { headers: { "ngrok-skip-browser-warning": "true" } })
        const data = await res.json()
        if (data.status === "success") {
          setProfile(data.data)
        } else {
          setError("User tidak ditemukan")
        }
      } catch {
        setError("Gagal memuat data")
      } finally {
        setLoading(false)
      }
    }
    fetchProfile()
  }, [id])

  function openInApp() {
    window.location.href = `rembugan://profile/${id}`
    setTimeout(() => {
      if (!document.hidden) {
        window.location.href = `https://play.google.com/store/apps/details?id=com.rembugan.app`
      }
    }, 2000)
  }

  if (loading) {
    return (
      <div style={lightVars} className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    )
  }

  if (error || !profile) {
    return (
      <div style={lightVars} className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30">
        <Card className="w-full max-w-sm shadow-lg">
          <CardContent className="flex flex-col items-center gap-4 py-12">
            <User className="h-12 w-12 text-muted-foreground/50" />
            <p className="text-lg font-medium text-muted-foreground">{error || "User tidak ditemukan"}</p>
            <Button variant="outline" onClick={() => router.push(APP_URL)}>
              Go to Rembugan
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  const initials = profile.full_name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2)

  return (
    <div style={lightVars} className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
      <Card className="w-full max-w-sm shadow-xl border-border/50">
        <div className="flex flex-col items-center pt-8 pb-4 px-6">
          <Avatar className="h-24 w-24 mb-4 ring-4 ring-primary/10">
            <AvatarImage src={profile.photo_url || undefined} alt={profile.full_name} />
            <AvatarFallback className="text-2xl">{initials}</AvatarFallback>
          </Avatar>
          <h1 className="text-2xl font-bold tracking-tight text-center">{profile.full_name}</h1>
          {profile.interest && (
            <p className="text-sm text-muted-foreground">{profile.interest}</p>
          )}
        </div>
        <CardContent className="space-y-4 pb-8 px-6">
          {profile.bio && (
            <p className="text-sm text-center text-muted-foreground leading-relaxed line-clamp-3">
              {profile.bio}
            </p>
          )}
          {profile.skills.length > 0 && (
            <div className="flex flex-wrap justify-center gap-1.5">
              {profile.skills.slice(0, 3).map((skill) => (
                <Badge key={skill} variant="secondary" className="text-xs">
                  {skill}
                </Badge>
              ))}
              {profile.skills.length > 3 && (
                <Badge variant="secondary" className="text-xs">
                  +{profile.skills.length - 3}
                </Badge>
              )}
            </div>
          )}
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
              {isMobile ? "Open in App" : "View in Rembugan App"}
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
