"use client"

import { useEffect, useState, useMemo } from "react"

import { Card, CardContent, CardHeader } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Skeleton } from "@/components/ui/skeleton"
import { Sparkles, Search, ChevronLeft, ChevronRight, ImageOff } from "lucide-react"
import { fetchShowcases } from "@/lib/api"

interface Showcase {
  id: string
  author_id: string
  content: string
  tags: string[]
  media_urls: string[]
  created_at: string
  author?: { full_name: string }
  likes?: Array<any>
  comments?: Array<any>
}

export default function ShowcasesPage() {
  const [showcases, setShowcases] = useState<Showcase[]>([])
  const [loading, setLoading] = useState(true)
  const [pagination, setPagination] = useState({ skip: 0, limit: 20, total: 0 })
  const [search, setSearch] = useState("")

  useEffect(() => {
    loadShowcases()
  }, [])

  async function loadShowcases() {
    try {
      const response = await fetchShowcases(0, 200)
      if (response.status === 'success') {
        setShowcases(response.data)
        setPagination(prev => ({ ...prev, total: response.pagination?.total ?? response.data.length }))
      }
    } catch (error) {
      console.error('Error loading showcases:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredShowcases = useMemo(() => {
    if (!search) return showcases
    const q = search.toLowerCase()
    return showcases.filter(
      (s) =>
        s.content.toLowerCase().includes(q) ||
        s.author?.full_name?.toLowerCase().includes(q) ||
        s.tags.some((t) => t.toLowerCase().includes(q))
    )
  }, [showcases, search])

  const paginatedShowcases = useMemo(() => {
    return filteredShowcases.slice(pagination.skip, pagination.skip + pagination.limit)
  }, [filteredShowcases, pagination.skip, pagination.limit])

  const totalPages = Math.ceil(filteredShowcases.length / pagination.limit)
  const currentPage = Math.floor(pagination.skip / pagination.limit) + 1

  if (loading) {
    return (
      <>
        <div className="space-y-6">
          <div>
            <Skeleton className="h-8 w-40" />
            <Skeleton className="mt-2 h-4 w-64" />
          </div>
          <Card className="border-border/50">
            <CardHeader>
              <Skeleton className="h-9 w-64" />
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {[...Array(8)].map((_, i) => (
                  <Skeleton key={i} className="h-14 w-full" />
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
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-rose-900">
            <Sparkles className="h-5 w-5 text-white" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Showcases</h1>
            <p className="text-sm text-muted-foreground">
              Portfolio showcases posted by users
            </p>
          </div>
          <Badge variant="secondary" className="ml-auto text-sm">
            {filteredShowcases.length} total
          </Badge>
        </div>

        {/* Data Table */}
        <Card className="border-border/50">
          <CardHeader className="pb-4">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
              <div className="relative flex-1 max-w-sm">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search showcases…"
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value)
                    setPagination((p) => ({ ...p, skip: 0 }))
                  }}
                  className="pl-9 bg-background"
                />
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-border/50 hover:bg-transparent">
                  <TableHead className="text-muted-foreground">ID</TableHead>
                  <TableHead className="text-muted-foreground">Author</TableHead>
                  <TableHead className="text-muted-foreground">Content</TableHead>
                  <TableHead className="text-muted-foreground">Tags</TableHead>
                  <TableHead className="text-muted-foreground">Media</TableHead>
                  <TableHead className="text-muted-foreground">Likes</TableHead>
                  <TableHead className="text-muted-foreground">Comments</TableHead>
                  <TableHead className="text-muted-foreground">Created</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedShowcases.length > 0 ? (
                  paginatedShowcases.map((showcase) => (
                    <TableRow key={showcase.id} className="border-border/50">
                      <TableCell className="font-mono text-xs text-muted-foreground">
                        {showcase.id.slice(-8)}
                      </TableCell>
                      <TableCell className="font-medium">
                        {showcase.author?.full_name || "—"}
                      </TableCell>
                      <TableCell className="max-w-xs">
                        <p className="line-clamp-2 text-sm text-muted-foreground">
                          {showcase.content}
                        </p>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                          {showcase.tags.slice(0, 2).map((tag, idx) => (
                            <Badge key={idx} variant="secondary" className="text-xs">
                              {tag}
                            </Badge>
                          ))}
                          {showcase.tags.length > 2 && (
                            <Badge variant="secondary" className="text-xs">
                              +{showcase.tags.length - 2}
                            </Badge>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {showcase.media_urls?.length || 0}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {showcase.likes?.length || 0}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {showcase.comments?.length || 0}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {new Date(showcase.created_at).toLocaleDateString()}
                      </TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={8} className="h-32 text-center">
                      <div className="flex flex-col items-center gap-2 text-muted-foreground">
                        <ImageOff className="h-8 w-8 opacity-30" />
                        <p className="text-sm">No showcases found</p>
                        <p className="text-xs">Try adjusting your search</p>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>

            {/* Pagination */}
            {filteredShowcases.length > pagination.limit && (
              <div className="flex items-center justify-between border-t border-border/50 pt-4 mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing {pagination.skip + 1}–{Math.min(pagination.skip + pagination.limit, filteredShowcases.length)} of {filteredShowcases.length}
                </p>
                <div className="flex items-center gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={pagination.skip === 0}
                    onClick={() => setPagination((p) => ({ ...p, skip: p.skip - p.limit }))}
                  >
                    <ChevronLeft className="h-4 w-4 mr-1" />
                    Previous
                  </Button>
                  <span className="text-sm text-muted-foreground">
                    {currentPage} / {totalPages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={pagination.skip + pagination.limit >= filteredShowcases.length}
                    onClick={() => setPagination((p) => ({ ...p, skip: p.skip + p.limit }))}
                  >
                    Next
                    <ChevronRight className="h-4 w-4 ml-1" />
                  </Button>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </>
  )
}