"use client"

import Link from "next/link"
import { motion } from "framer-motion"
import { ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"

function PhoneMockup() {
  return (
    <div className="relative mx-auto w-[280px]">
      <div className="relative rounded-[2.5rem] border-[3px] border-[#2D2D2D] bg-white shadow-xl">
        <div className="mx-auto h-5 w-[120px] rounded-b-xl bg-[#2D2D2D]" />
        <div className="aspect-[9/19] overflow-hidden rounded-b-[2.35rem]">
          <img src="/Hero.png" alt="Rembugan App" className="h-full w-full object-cover" />
        </div>
      </div>
    </div>
  )
}

export function Hero() {
  return (
    <section className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="flex flex-col items-center gap-12 md:flex-row md:gap-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="flex-1 text-center md:text-left"
          >
            <div className="mb-5 inline-flex items-center gap-1.5 rounded-full border bg-secondary px-3 py-1 text-xs font-medium text-muted-foreground">
              Khusus Mahasiswa Universitas Harkat Negeri
            </div>
            <h1 className="text-[clamp(2rem,4vw,3.5rem)] font-bold leading-[1.1] tracking-tight">
              Bangun Proyek,
              <br />
              <span className="text-[#6366F1]">Temukan Tim Impianmu</span>
            </h1>
            <p className="mx-auto mt-4 max-w-md text-base leading-relaxed text-muted-foreground md:mx-0">
              Rembugan bantu kamu nemuin teman satu tim, Kolaborasi di proyek nyata,
              dan bangun portofolio yang bikin kamu standout.
            </p>
            <div className="mt-6 flex flex-wrap items-center gap-3 md:justify-start">
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
          </motion.div>
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="shrink-0"
          >
            <PhoneMockup />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
