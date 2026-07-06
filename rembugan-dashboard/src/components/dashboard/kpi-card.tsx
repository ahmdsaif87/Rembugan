import { Card, CardContent } from "@/components/ui/card"
import { LucideIcon } from "lucide-react"

interface KPICardProps {
  label: string
  value: string | number
  icon: LucideIcon
  description?: string
}

export function KPICard({ label, value, icon: Icon, description }: KPICardProps) {
  return (
    <Card className="rounded-2xl border border-border/50 shadow-sm transition-all hover:shadow-md">
      <CardContent className="flex items-start justify-between p-6">
        <div className="space-y-1">
          <p className="text-sm font-medium text-muted-foreground">{label}</p>
          <p className="text-3xl font-bold tracking-tight">{value}</p>
          {description && <p className="text-xs text-muted-foreground">{description}</p>}
        </div>
        <div className="rounded-xl bg-muted p-2.5">
          <Icon className="h-5 w-5 text-muted-foreground" />
        </div>
      </CardContent>
    </Card>
  )
}
