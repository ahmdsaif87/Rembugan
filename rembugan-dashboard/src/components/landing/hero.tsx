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
        <div className="aspect-[9/19] overflow-hidden rounded-b-[2.35rem] bg-gray-50">
          <div className="flex h-full flex-col">
            <div className="flex items-center justify-between bg-[#6366F1] px-4 pb-3 pt-6">
              <div className="flex items-center gap-2">
                <div className="flex h-6 w-6 items-center justify-center rounded-md bg-white/20 text-white">
                  <svg className="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
                  </svg>
                </div>
                <p className="text-xs font-medium text-white/90">Rembugan</p>
              </div>
              <div className="flex h-6 w-6 items-center justify-center">
                <svg className="h-4 w-4 text-white/80" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                </svg>
              </div>
            </div>
            <div className="flex-1 p-3">
              <div className="mb-3 flex items-center justify-between">
                <p className="text-[10px] font-semibold uppercase tracking-wider text-gray-400">Proyek</p>
                <div className="rounded-md bg-[#6366F1]/10 px-2 py-0.5 text-[9px] font-medium text-[#6366F1]">
                  + Baru
                </div>
              </div>
              {[
                { name: "UX Research", members: 4, color: "#6366F1" },
                { name: "AI Study Buddy", members: 3, color: "#10B981" },
                { name: "Campus Market", members: 5, color: "#F59E0B" },
              ].map((p) => (
                <div key={p.name} className="mb-1.5 rounded-lg border border-gray-100 bg-white p-2.5">
                  <div className="flex items-center gap-2">
                    <div className="h-2 w-2 rounded-full" style={{ backgroundColor: p.color }} />
                    <span className="text-[10px] font-medium text-gray-700">{p.name}</span>
                  </div>
                  <div className="mt-1 flex items-center gap-2 text-[8px] text-gray-400">
                    <span>{p.members} anggota</span>
                  </div>
                </div>
              ))}
            </div>
            <div className="border-t border-gray-100 p-3">
              <div className="flex items-center gap-2 rounded-lg bg-[#6366F1] px-3 py-2 text-center">
                <span className="w-full text-[10px] font-medium text-white">+ Gabung Proyek</span>
              </div>
            </div>
          </div>
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
