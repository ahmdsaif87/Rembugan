"use client"

import * as React from "react"
import { MoreVerticalIcon, EyeIcon, Trash2Icon } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
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

interface RowActionItem {
  icon: React.ReactNode
  label: string
  onClick: () => void
  destructive?: boolean
}

interface RowActionsProps {
  onView?: () => void
  onDelete?: () => void
  deleteLabel?: string
  extraItems?: RowActionItem[]
}

export function RowActions({
  onView,
  onDelete,
  deleteLabel = "this item",
  extraItems,
}: RowActionsProps) {
  const [dialogOpen, setDialogOpen] = React.useState(false)

  return (
    <AlertDialog open={dialogOpen} onOpenChange={setDialogOpen}>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            className="flex size-8 text-muted-foreground hover:text-foreground hover:bg-accent data-[state=open]:bg-accent"
            size="icon"
          >
            <MoreVerticalIcon />
            <span className="sr-only">Open menu</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-32">
          {onView && (
            <DropdownMenuItem onClick={onView}>
              <EyeIcon />
              View Details
            </DropdownMenuItem>
          )}
          {extraItems?.map((item, i) => (
            <DropdownMenuItem
              key={i}
              onClick={item.onClick}
              className={item.destructive ? "text-destructive" : ""}
            >
              {item.icon}
              {item.label}
            </DropdownMenuItem>
          ))}
          {onDelete && (
            <AlertDialogTrigger asChild>
              <DropdownMenuItem className="text-destructive">
                <Trash2Icon />
                Delete
              </DropdownMenuItem>
            </AlertDialogTrigger>
          )}
        </DropdownMenuContent>
      </DropdownMenu>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
          <AlertDialogDescription>
            This will permanently delete {deleteLabel}. This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={onDelete}
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            Delete
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
