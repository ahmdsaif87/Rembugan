"use client";

import * as React from "react";
import { AppSidebar } from "@/components/app-sidebar";
import { SiteHeader } from "@/components/site-header";
import { SidebarProvider } from "@/components/ui/sidebar";
import { useRouter } from "next/navigation";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const router = useRouter();
  const [isAuthenticated, setIsAuthenticated] = React.useState<boolean | null>(null);
  const [sidebarOpen, setSidebarOpen] = React.useState(true);

  React.useEffect(() => {
    const token = localStorage.getItem("admin_token");
    if (!token) {
      router.push("/login");
    } else {
      setIsAuthenticated(true);
    }
    const saved = localStorage.getItem("sidebar_state");
    if (saved !== null) setSidebarOpen(saved === "true");
  }, [router]);

  const toggleSidebar = React.useCallback(() => {
    setSidebarOpen((prev) => {
      const next = !prev;
      localStorage.setItem("sidebar_state", String(next));
      return next;
    });
  }, []);

  if (!isAuthenticated) return null;

  return (
    <SidebarProvider
      defaultOpen={sidebarOpen}
      open={sidebarOpen}
      onOpenChange={(open) => {
        setSidebarOpen(open);
        localStorage.setItem("sidebar_state", String(open));
      }}
    >
      {/* Outer flex container: sidebar + main side by side */}
      <div
        style={{
          display: "flex",
          minHeight: "100svh",
          width: "100%",
        }}
      >
        {/* Sidebar — tidak fixed, ikut flow */}
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

        {/* Main content — melebar mengisi sisa ruang */}
        <div
          style={{
            flex: 1,
            minWidth: 0,
            display: "flex",
            flexDirection: "column",
          }}
        >
          <SiteHeader onToggleSidebar={toggleSidebar} />
          <div style={{ flex: 1, display: "flex", flexDirection: "column" }}>
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
