"use client"

import * as React from "react"
import { useState } from "react"
import { Sheet, SheetContent, SheetHeader, SheetTitle } from "@/components/ui/sheet"
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
} from "@/components/ui/drawer"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { cn } from "@/lib/utils"
import { useMediaQuery } from "@/hooks/use-media-query"

interface DetailField {
  label: string
  value: React.ReactNode
  variant?: "text" | "badge" | "bio"
}

interface DetailSheetProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  fields: DetailField[]
  identity?: {
    name: string
    subtitle?: string
    avatar?: string | null
  }
  actions?: React.ReactNode
}

export function DetailSheet(props: DetailSheetProps) {
  const isDesktop = useMediaQuery("(min-width: 640px)")

  if (isDesktop) {
    return <DetailSheetDesktop {...props} />
  }

  return <DetailSheetMobile {...props} />
}

function DetailSheetDesktop({
  open,
  onOpenChange,
  title,
  fields,
  identity,
  actions,
}: DetailSheetProps) {
  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full overflow-y-auto sm:max-w-lg">
        <div className="sr-only" aria-live="polite">
          {title}
        </div>
        <DetailSheetContent
          title={title}
          fields={fields}
          identity={identity}
          actions={actions}
          TitleEl={SheetTitle}
          HeaderEl={SheetHeader}
        />
      </SheetContent>
    </Sheet>
  )
}

function DetailSheetMobile({
  open,
  onOpenChange,
  title,
  fields,
  identity,
  actions,
}: DetailSheetProps) {
  return (
    <Drawer open={open} onOpenChange={onOpenChange}>
      <DrawerContent className="max-h-[85vh] overflow-y-auto">
        <div className="p-4 pt-2">
          <DetailSheetContent
            title={title}
            fields={fields}
            identity={identity}
            actions={actions}
            TitleEl={DrawerTitle}
            HeaderEl={DrawerHeader}
          />
        </div>
      </DrawerContent>
    </Drawer>
  )
}

function DetailSheetContent({
  title,
  fields,
  identity,
  actions,
  TitleEl,
  HeaderEl,
}: Omit<DetailSheetProps, "open" | "onOpenChange"> & {
  TitleEl: React.ElementType
  HeaderEl: React.ElementType
}) {
  return (
    <>
      {identity ? (
        <div className="flex items-start gap-4 pb-5 border-b border-border/50 mb-5">
          <TitleEl className="sr-only">{title}</TitleEl>
          <Avatar className="h-14 w-14 ring-2 ring-primary/10">
            <AvatarImage src={identity.avatar || undefined} alt={identity.name} />
            <AvatarFallback className="text-base font-semibold">
              {identity.name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2)}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <h2 className="text-lg font-semibold leading-tight truncate">
              {identity.name}
            </h2>
            {identity.subtitle && (
              <p className="text-sm text-muted-foreground mt-0.5">
                {identity.subtitle}
              </p>
            )}
          </div>
        </div>
      ) : (
        <HeaderEl className="pb-5 border-b border-border/50 mb-5">
          <TitleEl>{title}</TitleEl>
        </HeaderEl>
      )}

      <div className="space-y-4">
        {fields.map((field, i) => (
          <FieldRow key={i} field={field} />
        ))}
      </div>

      {actions && (
        <div className="mt-8 pt-5 border-t border-border/50 space-y-2">
          {actions}
        </div>
      )}
    </>
  )
}

function FieldRow({ field }: { field: DetailField }) {
  switch (field.variant) {
    case "badge":
      return <BadgeRow label={field.label} value={field.value} />
    case "bio":
      return <BioRow label={field.label} value={field.value} />
    default:
      return <TextRow label={field.label} value={field.value} />
  }
}

function TextRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground/60 mb-1">
        {label}
      </p>
      <div className="text-[15px] font-medium leading-snug">
        {value || <span className="text-muted-foreground/50 italic">—</span>}
      </div>
    </div>
  )
}

function BadgeRow({ label, value }: { label: string; value: React.ReactNode }) {
  const badges = React.useMemo(() => {
    if (value == null || React.isValidElement(value)) return null
    if (typeof value === "string") {
      return value.split(",").map((s) => s.trim()).filter(Boolean)
    }
    if (Array.isArray(value)) {
      return value as string[]
    }
    return null
  }, [value])

  if (!badges || badges.length === 0) {
    return (
      <div>
        <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground/60 mb-1">
          {label}
        </p>
        <span className="text-[15px] font-medium text-muted-foreground/50 italic">—</span>
      </div>
    )
  }

  const visible = badges.slice(0, 4)
  const remaining = badges.length - visible.length

  return (
    <div>
      <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground/60 mb-1.5">
        {label}
      </p>
      <div className="flex flex-wrap gap-1.5">
        {visible.map((badge, i) => (
          <Badge key={i} variant="secondary" className="text-xs font-normal">
            {badge}
          </Badge>
        ))}
        {remaining > 0 && (
          <Badge variant="secondary" className="text-xs font-normal text-muted-foreground">
            +{remaining} lainnya
          </Badge>
        )}
      </div>
    </div>
  )
}

function BioRow({ label, value }: { label: string; value: React.ReactNode }) {
  const [expanded, setExpanded] = useState(false)
  const text = typeof value === "string" ? value : ""

  if (!text) {
    return (
      <div>
        <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground/60 mb-1">
          {label}
        </p>
        <span className="text-[15px] font-medium text-muted-foreground/50 italic">—</span>
      </div>
    )
  }

  return (
    <div>
      <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground/60 mb-1">
        {label}
      </p>
      <div
        className={cn(
          "text-[15px] font-medium leading-relaxed text-muted-foreground/90",
          !expanded && "line-clamp-3"
        )}
      >
        {text}
      </div>
      {text.length > 150 && (
        <button
          onClick={() => setExpanded(!expanded)}
          className="text-xs font-medium text-primary mt-1 hover:underline"
        >
          {expanded ? "Show less" : "Read more"}
        </button>
      )}
    </div>
  )
}
