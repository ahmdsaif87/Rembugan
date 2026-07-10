"use client"

import { motion } from "framer-motion"

const steps = [
  { step: "01", title: "Buat Profil", desc: "Isi profil dengan skill, minat, dan portofoliomu. Tunjukkan apa yang bisa kamu bawa ke tim." },
  { step: "02", title: "Cari Proyek", desc: "Jelajahi proyek yang lagi cari anggota. AI matchmaker kami kasih rekomendasi yang paling cocok buat kamu." },
  { step: "03", title: "Gabung Tim", desc: "Daftar atau diundang. Diskusi, rencanain, dan mulai kolaborasi secara real-time." },
  { step: "04", title: "Bangun Bareng", desc: "Pakai workspace bawaan: kanban, file sharing, chat, dan milestone. Semua dalam satu tempat." },
]

export function HowItWorks() {
  return (
    <section id="how-it-works" className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">Cara Kerja</p>
          <h2 className="mt-3 text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Dari ide sampai jadi, dalam empat langkah
          </h2>
        </div>
        <div className="mt-12 grid gap-4 md:grid-cols-4">
          {steps.map((s, i) => (
            <motion.div
              key={s.step}
              initial={{ opacity: 0, y: 12 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.3, delay: i * 0.1 }}
              className="rounded-xl border bg-card p-6 transition-all hover:border-[#6366F1]/20 hover:shadow-sm"
            >
              <div className="flex h-10 w-10 items-center justify-center rounded-lg border text-sm font-bold text-[#6366F1]">
                {s.step}
              </div>
              <h3 className="mt-4 font-semibold">{s.title}</h3>
              <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">{s.desc}</p>
            </motion.div>
          ))}
        </div>

      </div>
    </section>
  )
}
