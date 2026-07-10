"use client"

import { motion } from "framer-motion"

function PhoneMockup({ src, alt }: { src: string; alt: string }) {
  return (
    <div className="mx-auto w-full max-w-[260px]">
      <div className="relative rounded-[2.5rem] border-[3px] border-[#2D2D2D] bg-white shadow-lg">
        <div className="mx-auto h-5 w-[110px] rounded-b-xl bg-[#2D2D2D]" />
        <div className="aspect-[9/19] overflow-hidden rounded-b-[2.35rem]">
          <img src={src} alt={alt} className="h-full w-full object-cover" />
        </div>
      </div>
    </div>
  )
}

const works = [
  { src: "/work1.png", alt: "Workspace 1" },
  { src: "/work2.png", alt: "Workspace 2" },
  { src: "/work3.png", alt: "Workspace 3" },
]

export function ProductPreview() {
  return (
    <section className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <p className="text-xs font-medium uppercase tracking-widest text-muted-foreground">Product</p>
          <h2 className="mt-3 text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Workspace yang adaptif sama timmu
          </h2>
          <p className="mt-3 text-muted-foreground">
            Dari kanban sampai chat real-time — semua didesain biar tim kamu terus bergerak.
          </p>
        </div>
        <div className="mt-12 flex items-end justify-center gap-6">
          {works.map((w, i) => (
            <motion.div
              key={w.src}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: 0.1 + i * 0.1 }}
              className="flex-1 max-w-[260px]"
            >
              <PhoneMockup src={w.src} alt={w.alt} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
