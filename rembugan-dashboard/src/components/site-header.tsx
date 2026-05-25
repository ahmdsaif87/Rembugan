"use client"

import { usePathname } from "next/navigation"
import { PanelLeft } from "lucide-react"
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import { Separator } from "@/components/ui/separator"
import { Button } from "@/components/ui/button"

const routeLabels: Record<string, string> = {
  "/": "Overview",
  "/users": "Users",
  "/projects": "Projects",
  "/showcases": "Showcases",
  "/tasks": "Tasks",
  "/applications": "Applications",
  "/competitions": "Competitions",
}

interface SiteHeaderProps {
  onToggleSidebar?: () => void
}

export function SiteHeader({ onToggleSidebar }: SiteHeaderProps) {
  const pathname = usePathname()
  const pageLabel = routeLabels[pathname] || "Dashboard"

  return (
    <header className="flex h-12 shrink-0 items-center gap-2 border-b bg-background">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          onClick={onToggleSidebar}
          aria-label="Toggle Sidebar"
        >
          <PanelLeft className="h-4 w-4" />
        </Button>
        <Separator
          orientation="vertical"
          className="mx-2 data-[orientation=vertical]:h-4"
        />
        <Breadcrumb>
          <BreadcrumbList>
            <BreadcrumbItem>
              <BreadcrumbLink href="/">Rembugan</BreadcrumbLink>
            </BreadcrumbItem>
            {pathname !== "/" && (
              <>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                  <BreadcrumbPage>{pageLabel}</BreadcrumbPage>
                </BreadcrumbItem>
              </>
            )}
          </BreadcrumbList>
        </Breadcrumb>
      </div>
    </header>
  )
}
