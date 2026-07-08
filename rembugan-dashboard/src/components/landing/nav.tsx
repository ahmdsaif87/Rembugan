"use client"

import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ThemeToggle } from "@/components/theme-toggle"

export function Nav() {
  return (
    <header className="sticky top-0 z-50 border-b bg-background/80 backdrop-blur-md">
      <div className="mx-auto flex h-14 w-full max-w-6xl items-center justify-between px-4">
        <button onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })} className="cursor-pointer">
          <img src="/logo.png" alt="Rembugan" className="h-8 w-8" />
        </button>
        <nav className="hidden items-center gap-6 text-sm text-muted-foreground md:flex">
          <a href="#features" className="transition-colors hover:text-foreground">Fitur</a>
          <a href="#how-it-works" className="transition-colors hover:text-foreground">Cara Kerja</a>
          <a href="#faq" className="transition-colors hover:text-foreground">FAQ</a>
        </nav>
        <div className="flex items-center gap-2">
          <ThemeToggle />
          <Link href="/login">
            <Button size="sm" className="h-8 bg-[#6366F1] text-white hover:bg-[#6366F1]/90">
              Dashboard Admin
            </Button>
          </Link>
        </div>
      </div>
    </header>
  )
}
