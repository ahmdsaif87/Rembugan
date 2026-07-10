"use client"

import { useState, useMemo } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { ColumnDef } from "@tanstack/react-table"
import {
  ImageOff,
} from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { DataTableGeneric } from "@/components/ui/data-table-generic"
import { RowActions } from "@/components/ui/row-actions"
import { DetailSheet } from "@/components/ui/detail-sheet"
import { fetchShowcases, deleteShowcase } from "@/lib/api"
import { toast } from "sonner"

interface Showcase {
  id: string
  content: string
  tags: string[]
  media_urls: string[]
  created_at: string
  author?: { full_name: string }
  likes?: Array<any>
  comments?: Array<any>
}

export default function ShowcasesPage() {
  const queryClient = useQueryClient()
  const [detailShowcase, setDetailShowcase] = useState<Showcase | null>(null)
  const [detailOpen, setDetailOpen] = useState(false)

  const { data: showcases = [], isLoading: loading } = useQuery({
    queryKey: ['showcases'],
    queryFn: async () => {
      const res = await fetchShowcases(0, 200)
      return (res.status === 'success' ? res.data : []) as Showcase[]
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteShowcase,
    onSuccess: (response, id) => {
      if (response.status === 'success') {
        queryClient.setQueryData<Showcase[]>(['showcases'], (old) =>
          old?.filter(s => s.id !== id) ?? []
        )
      }
    },
  })

  const columns = useMemo((): ColumnDef<Showcase>[] => [
    {
      accessorKey: "id",
      header: "ID",
      cell: ({ row }) => (
        <span className="font-mono text-xs text-muted-foreground">
          {row.original.id.slice(-8)}
        </span>
      ),
    },
    {
      accessorKey: "author",
      header: "Author",
      cell: ({ row }) => (
        <span className="table-primary">
          {row.original.author?.full_name || "—"}
        </span>
      ),
    },
    {
      accessorKey: "content",
      header: "Content",
      cell: ({ row }) => (
        <span className="line-clamp-2 max-w-xs text-sm table-secondary">
          {row.original.content}
        </span>
      ),
    },
    {
      accessorKey: "tags",
      header: "Tags",
      cell: ({ row }) => {
        const tags = row.original.tags
        return (
          <div className="flex flex-wrap gap-1">
            {tags.slice(0, 2).map((tag, idx) => (
              <Badge key={idx} variant="secondary" className="text-xs">
                {tag}
              </Badge>
            ))}
            {tags.length > 2 && (
              <Badge variant="secondary" className="text-xs">
                +{tags.length - 2}
              </Badge>
            )}
          </div>
        )
      },
    },
    {
      accessorKey: "media_urls",
      header: "Media",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.media_urls?.length || 0}</span>
      ),
    },
    {
      accessorKey: "likes",
      header: "Likes",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.likes?.length || 0}</span>
      ),
    },
    {
      accessorKey: "comments",
      header: "Comments",
      cell: ({ row }) => (
        <span className="text-muted-foreground">{row.original.comments?.length || 0}</span>
      ),
    },
    {
      accessorKey: "created_at",
      header: "Created",
      cell: ({ row }) => (
        <span className="text-muted-foreground">
          {new Date(row.original.created_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      id: "actions",
      cell: ({ row }) => {
        const showcase = row.original
        return (
          <RowActions
            onView={() => { setDetailShowcase(showcase); setDetailOpen(true) }}
            onDelete={() => deleteMutation.mutate(showcase.id)}
            deleteLabel="this showcase"
          />
        )
      },
    },
  ], [deleteMutation])

  return (
    <div className="flex flex-col gap-4">
      <div>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Showcases</h1>
          <p className="text-sm text-muted-foreground">
            Portfolio showcases posted by users
          </p>
        </div>
      </div>

      <DataTableGeneric
        columns={columns}
        data={showcases}
        searchKey="content"
        searchPlaceholder="Search showcases..."
        loading={loading}
        totalLabel={`${showcases.length} total`}
        emptyMessage="No showcases found"
        emptyIcon={<ImageOff className="h-8 w-8 opacity-30" />}
      />

      <DetailSheet
        open={detailOpen}
        onOpenChange={setDetailOpen}
        title="Showcase Details"
        fields={[
          { label: "Author", value: detailShowcase?.author?.full_name },
          { label: "Content", value: detailShowcase?.content, variant: "bio" },
          { label: "Tags", value: detailShowcase?.tags?.join(", "), variant: "badge" },
          { label: "Media", value: detailShowcase?.media_urls?.join(", "), variant: "badge" },
          { label: "Likes", value: String(detailShowcase?.likes?.length ?? 0) },
          { label: "Comments", value: String(detailShowcase?.comments?.length ?? 0) },
          { label: "Created", value: detailShowcase?.created_at ? new Date(detailShowcase.created_at).toLocaleDateString() : "—" },
        ]}
      />
    </div>
  )
}
