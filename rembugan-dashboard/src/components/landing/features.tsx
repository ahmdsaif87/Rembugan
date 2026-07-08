"use client"

import { motion } from "framer-motion"
import { Search, FolderKanban, Sparkles, MessageSquare, Trophy, Bell } from "lucide-react"

const features = [
  {
    icon: Search,
    title: "AI Matchmaking",
    desc: "Algoritma pintar yang nyariin teman satu tim sesuai skill dan minatmu. Bukan asal cocok.",
    span: "md:col-span-1 md:row-span-1",
  },
  {
    icon: FolderKanban,
    title: "Workspace Proyek",
    desc: "Kanban, tugas, file sharing, dan milestone — semua yang tim kamu butuh dalam satu tempat.",
    span: "md:col-span-2 md:row-span-1",
  },
  {
    icon: Sparkles,
    title: "Portofolio Showcase",
    desc: "Publish proyek yang udah selesai dan dapet feedback dari komunitas. Bangun portofolio yang bicara.",
    span: "md:col-span-1 md:row-span-1",
  },
  {
    icon: MessageSquare,
    title: "Chat Real-time",
    desc: "Pesan pribadi dan grup chat pake WebSocket. Share file, kode, dan tetap sinkron.",
    span: "md:col-span-1 md:row-span-1",
  },
  {
    icon: Trophy,
    title: "Kompetisi & Event",
    desc: "Gak bakal ketinggalan hackathon atau kompetisi. Auto-scrape dari berbagai sumber.",
    span: "md:col-span-1 md:row-span-1",
  }
]

export function Features() {
  return (
    <section id="features" className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">Fitur</p>
          <h2 className="mt-3 text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Semua yang kamu butuhkan ada disini
          </h2>
          <p className="mt-3 text-muted-foreground">
            Bukan cuma chat biasa. Platform kolaborasi lengkap buat tim mahasiswa.
          </p>
        </div>
        <div className="mt-12 grid gap-4 md:grid-cols-3">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              initial={{ opacity: 0, y: 12 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.3, delay: i * 0.05 }}
              className={`group rounded-xl border bg-card p-6 transition-all hover:border-[#6366F1]/20 hover:shadow-sm ${f.span}`}
            >
              <div className="flex h-9 w-9 items-center justify-center rounded-lg border text-[#6366F1]">
                <f.icon className="h-4 w-4" />
              </div>
              <h3 className="mt-4 text-sm font-semibold">{f.title}</h3>
              <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
