"use client"

import * as React from "react"
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet"

interface DetailField {
  label: string
  value: React.ReactNode
}

interface DetailSheetProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  fields: DetailField[]
}

export function DetailSheet({ open, onOpenChange, title, fields }: DetailSheetProps) {
  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full overflow-y-auto sm:max-w-lg">
        <SheetHeader>
          <SheetTitle>{title}</SheetTitle>
        </SheetHeader>
        <div className="mt-6 space-y-4">
          {fields.map((field, i) => (
            <div key={i} className="border-b border-border pb-3 last:border-0">
              <p className="mb-1 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                {field.label}
              </p>
              <div className="text-sm">{field.value || <span className="text-muted-foreground italic">—</span>}</div>
            </div>
          ))}
        </div>
      </SheetContent>
    </Sheet>
  )
}
