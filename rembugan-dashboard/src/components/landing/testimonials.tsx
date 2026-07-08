"use client"

import { motion } from "framer-motion"

const testimonials = [
  {
    name: "Rafi Ahmad",
    role: "Mahasiswa Informatika, Universitas Harkat Negeri",
    text: "Dulu susah banget nyari temen satu tim buat proyek. Matchmaking Rembugan nemuin tim dalam sehari. Kami akhirnya menang dua kompetisi.",
  },
  {
    name: "Sarah Putri",
    role: "Lead Desain, Universitas Harkat Negeri",
    text: "Workspace bawaan Rembugan ngegantiin Trello, Slack, sama Google Drive buat proyek kampus. Semua jadi satu tempat.",
  },
  {
    name: "Dimas Nugraha",
    role: "Ketua UKM Teknologi, Universitas Harkat Negeri",
    text: "Kami recommend Rembugan ke semua mahasiswa baru. Bikin pembentukan tim jadi jauh lebih gampang dan orang nemu proyek yang sesuai skill mereka.",
  },
]

export function Testimonials() {
  return (
    <section className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <h2 className="text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Disukai mahasiswa
          </h2>
          <p className="mt-3 text-muted-foreground">
            Ini kata mahasiswa Universitas Harkat Negeri tentang Rembugan.
          </p>
        </div>
        <div className="mt-12 grid gap-4 md:grid-cols-3">
          {testimonials.map((t, i) => (
            <motion.div
              key={t.name}
              initial={{ opacity: 0, y: 12 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.3, delay: i * 0.1 }}
              className="rounded-xl border bg-card p-6"
            >
              <div className="flex items-center gap-1 text-[#6366F1]">
                {[...Array(5)].map((_, i) => (
                  <svg key={i} className="h-3.5 w-3.5 fill-current" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                ))}
              </div>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                &ldquo;{t.text}&rdquo;
              </p>
              <div className="mt-4 border-t pt-4">
                <p className="text-sm font-medium">{t.name}</p>
                <p className="text-xs text-muted-foreground">{t.role}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
