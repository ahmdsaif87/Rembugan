import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { LucideIcon } from "lucide-react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MoreVerticalIcon } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

interface RecentItemsProps {
  title: string
  description: string
  icon: LucideIcon
  items: any[]
  renderRow: (item: any) => React.ReactNode
  columns: { label: string }[]
  onAction: (item: any) => void
}

export function RecentItems({ 
  title, 
  description, 
  icon: Icon, 
  items, 
  renderRow, 
  columns,
  onAction
}: RecentItemsProps) {
  return (
    <Card className="rounded-2xl border border-border/50 shadow-sm overflow-hidden">
      <CardHeader className="flex flex-row items-center gap-4 pb-4">
        <div className="rounded-lg bg-muted p-2">
          <Icon className="h-5 w-5 text-muted-foreground" />
        </div>
        <div className="space-y-1">
          <CardTitle className="text-base font-semibold tracking-tight">{title}</CardTitle>
          <CardDescription className="text-xs">{description}</CardDescription>
        </div>
      </CardHeader>
      <CardContent className="p-0">
        <Table>
          <TableHeader className="bg-muted/50">
            <TableRow className="hover:bg-transparent border-b border-border/50">
              {columns.map((col, idx) => (
                <TableHead key={idx} className="text-xs font-medium text-muted-foreground py-3">
                  {col.label}
                </TableHead>
              ))}
              <TableHead className="text-right py-3">
                <div className="text-xs font-medium text-muted-foreground">Actions</div>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {items.length > 0 ? (
              items.map((item, idx) => (
                <TableRow key={idx} className="border-b border-border/30 last:border-0 transition-colors hover:bg-muted/30">
                  {renderRow(item)}
                  <TableCell className="text-right">
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon" className="size-8 text-muted-foreground hover:text-foreground">
                          <MoreVerticalIcon className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="w-40">
                        <DropdownMenuItem onClick={() => onAction(item)}>
                          View Details
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length + 1} className="h-32 text-center text-sm text-muted-foreground">
                  No data available
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}
