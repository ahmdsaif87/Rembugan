"use client";

import * as React from "react";
import { useRouter } from "next/navigation";
import { AppSidebar } from "@/components/app-sidebar";
import { SiteHeader } from "@/components/site-header";
import { SidebarProvider } from "@/components/ui/sidebar";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const router = useRouter();
  const [mounted, setMounted] = React.useState(false);
  const [sidebarOpen, setSidebarOpen] = React.useState(true);

  React.useEffect(() => {
    const token = sessionStorage.getItem("admin_token");
    if (!token) {
      router.replace("/login");
      return;
    }
    setMounted(true);
    const saved = localStorage.getItem("sidebar_state");
    if (saved !== null) setSidebarOpen(saved === "true");
  }, [router]);

  if (!mounted) return null;

  const toggleSidebar = React.useCallback(() => {
    setSidebarOpen((prev) => {
      const next = !prev;
      localStorage.setItem("sidebar_state", String(next));
      return next;
    });
  }, []);

  return (
    <SidebarProvider
      defaultOpen={sidebarOpen}
      open={sidebarOpen}
      onOpenChange={(open) => {
        setSidebarOpen(open);
        localStorage.setItem("sidebar_state", String(open));
      }}
    >
      <div className="flex min-h-screen w-full">
        <div
          style={{
            width: sidebarOpen ? "16rem" : "0px",
            minWidth: sidebarOpen ? "16rem" : "0px",
            overflow: "hidden",
            transition: "width 0.2s ease, min-width 0.2s ease",
            flexShrink: 0,
            position: "sticky",
            top: 0,
            height: "100svh",
          }}
        >
          <AppSidebar />
        </div>

        <div className="flex flex-1 min-w-0 flex-col">
          <SiteHeader onToggleSidebar={toggleSidebar} />
          <div className="flex-1 flex flex-col">
            <div className="@container/main flex flex-1 flex-col gap-2">
              <div className="flex flex-col gap-4 px-4 py-4 md:gap-6 md:px-6 md:py-6">
                {children}
              </div>
            </div>
          </div>
        </div>
      </div>
    </SidebarProvider>
  );
}
