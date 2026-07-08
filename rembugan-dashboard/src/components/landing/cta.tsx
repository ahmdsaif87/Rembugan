"use client"

import Link from "next/link"
import { ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"

export function CTA() {
  return (
    <section className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Siap bangun sesuatu yang keren?
          </h2>
          <p className="mt-3 text-muted-foreground">
            Gabung mahasiswa Universitas Harkat Negeri yang udah kolaborasi, ngerjain proyek,
            dan bangun portofolio di Rembugan.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <Link
              href="https://play.google.com/store/apps/details?id=com.rembugan.app"
              target="_blank"
              rel="noreferrer"
            >
              <Button size="lg" className="gap-2 bg-[#6366F1] text-white shadow-sm hover:bg-[#6366F1]/90">
                Mulai Sekarang <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
          </div>
        </div>
      </div>
    </section>
  )
}
