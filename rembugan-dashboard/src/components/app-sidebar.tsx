"use client"

import * as React from "react"
import { usePathname } from "next/navigation"
import Link from "next/link"
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

import { NavUser } from "@/components/nav-user"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarGroup,
  SidebarGroupLabel,
} from "@/components/ui/sidebar"

const navItems = [
  { title: "Overview", url: "/", icon: BarChart3 },
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

  return (
    <Sidebar
      className="h-screen"
      {...props}
    >
      {/* Brand */}
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild className="mt-12">
              <Link href="/">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-rose-900 text-white">
                  <MessageSquare className="size-4" />
                </div>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-bold tracking-tight">Rembugan</span>
                  <span className="truncate text-xs text-muted-foreground">Admin Dashboard</span>
                </div>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      {/* Navigation */}
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
          <SidebarMenu>
            {navItems.map((item) => {
              const isActive =
                item.url === "/"
                  ? pathname === "/"
                  : pathname.startsWith(item.url)

              return (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild isActive={isActive} tooltip={item.title}>
                    <Link href={item.url}>
                      <item.icon />
                      <span>{item.title}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              )
            })}
          </SidebarMenu>
        </SidebarGroup>
      </SidebarContent>

      {/* Footer user */}
      <SidebarFooter className="mb-2">
        <NavUser user={adminUser} />
      </SidebarFooter>
    </Sidebar>
  )
}
