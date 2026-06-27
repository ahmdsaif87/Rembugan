"use client"

import { use, useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Heart, MessageSquare, ExternalLink, Smartphone, Loader2, FileText } from "lucide-react"
import { API_BASE_URL, APP_URL } from "@/lib/api"

interface ShowcaseData {
  id: string
  content: string
  media_urls: string[]
  tags: string[]
  author_name: string | null
  author_photo: string | null
  likes_count: number
  comments_count: number
  created_at: string
}

export default function ShowcasePublicPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [showcase, setShowcase] = useState<ShowcaseData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")

  useEffect(() => {
    async function fetchShowcase() {
      try {
        const res = await fetch(`${API_BASE_URL}/showcase/${id}`, { headers: { "ngrok-skip-browser-warning": "true" } })
        const data = await res.json()
        if (data.status === "success" && data.data) {
          setShowcase(data.data)
        } else {
          setError("Postingan tidak ditemukan")
        }
      } catch {
        setError("Gagal memuat data")
      } finally {
        setLoading(false)
      }
    }
    fetchShowcase()
  }, [id])

  function openInApp() {
    window.location.href = `rembugan://showcase/${id}`
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

  if (error || !showcase) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30">
        <Card className="w-full max-w-sm shadow-lg">
          <CardContent className="flex flex-col items-center gap-4 py-12">
            <FileText className="h-12 w-12 text-muted-foreground/50" />
            <p className="text-lg font-medium text-muted-foreground">{error || "Postingan tidak ditemukan"}</p>
            <Button variant="outline" onClick={() => router.push(APP_URL)}>
              Go to Rembugan
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-background to-muted/30 p-4">
      <Card className="w-full max-w-lg shadow-lg">
        <CardContent className="flex flex-col gap-4 p-6">
          {/* Author */}
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src={showcase.author_photo || undefined} />
              <AvatarFallback>{(showcase.author_name || "?").charAt(0)}</AvatarFallback>
            </Avatar>
            <div>
              <p className="font-semibold">{showcase.author_name || "Anonymous"}</p>
              <p className="text-xs text-muted-foreground">
                {new Date(showcase.created_at).toLocaleDateString("id-ID", {
                  year: "numeric", month: "long", day: "numeric",
                })}
              </p>
            </div>
          </div>

          {/* Content */}
          <p className="text-sm leading-relaxed whitespace-pre-wrap">{showcase.content}</p>

          {/* Media */}
          {showcase.media_urls && showcase.media_urls.length > 0 && (
            <div className="grid gap-2">
              {showcase.media_urls.map((url, i) => (
                <div key={i} className="relative overflow-hidden rounded-lg bg-muted">
                  {url.match(/\.(jpeg|jpg|gif|png|webp)/i) ? (
                    <img src={url} alt="" className="w-full h-auto object-cover max-h-96" />
                  ) : (
                    <div className="flex items-center gap-2 p-4 text-sm text-muted-foreground">
                      <FileText className="h-4 w-4" />
                      <a href={url} target="_blank" rel="noopener noreferrer" className="underline">
                        {url.split("/").pop()}
                      </a>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {/* Tags */}
          {showcase.tags && showcase.tags.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {showcase.tags.map((tag) => (
                <Badge key={tag} variant="secondary" className="text-xs">
                  #{tag}
                </Badge>
              ))}
            </div>
          )}

          {/* Stats */}
          <div className="flex items-center gap-4 text-sm text-muted-foreground">
            <span className="flex items-center gap-1">
              <Heart className="h-4 w-4" /> {showcase.likes_count}
            </span>
            <span className="flex items-center gap-1">
              <MessageSquare className="h-4 w-4" /> {showcase.comments_count}
            </span>
          </div>

          {/* Actions */}
          <div className="flex gap-2 pt-2">
            <Button variant="default" className="flex-1 gap-2" onClick={openInApp}>
              <Smartphone className="h-4 w-4" />
              Buka di Aplikasi
            </Button>
            <Button variant="outline" size="icon" onClick={() => {
              navigator.clipboard.writeText(`${APP_URL}/s/${id}`)
            }}>
              <ExternalLink className="h-4 w-4" />
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
