"use client"

import * as React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  BarChart3,
  Users,
  FolderKanban,
  Sparkles,
  ListChecks,
  FileText,
  MessageSquare,
  Trophy,
} from "lucide-react"

import { NavMain } from "@/components/nav-main"
import { NavUser } from "@/components/nav-user"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"

const navItems = [
  { title: "Overview", url: "/dashboard", icon: BarChart3 },
  { title: "Competitions", url: "/competitions", icon: Trophy },
  { title: "Users", url: "/users", icon: Users },
  { title: "Projects", url: "/projects", icon: FolderKanban },
  { title: "Showcases", url: "/showcases", icon: Sparkles },
  { title: "Tasks", url: "/tasks", icon: ListChecks },
  { title: "Applications", url: "/applications", icon: FileText },
]

const adminUser = {
  name: "Admin",
  email: "admin@rembugan.com",
  avatar: "/avatars/admin.jpg",
}

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const pathname = usePathname()

  const mainItems = navItems.map((item) => ({
    ...item,
    isActive: item.url === "/dashboard" ? pathname === "/dashboard" : pathname.startsWith(item.url),
  }))

  return (
    <Sidebar collapsible="none" className="h-full w-full border-r bg-sidebar" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              asChild
              className="data-[slot=sidebar-menu-button]:!p-1.5"
            >
              <Link href="/dashboard">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground shadow-sm">
                  <MessageSquare className="h-5 w-5" />
                </div>
                <span className="text-base font-semibold">Rembugan</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={mainItems} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={adminUser} />
      </SidebarFooter>
    </Sidebar>
  )
}
