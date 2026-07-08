"use client"

import { motion } from "framer-motion"

const phones = [
  {
    color: "#6366F1",
    title: "Frontend",
    items: ["Next.js 16", "TypeScript", "Tailwind CSS", "Shadcn UI"],
  },
  {
    color: "#10B981",
    title: "Backend & Database",
    items: ["FastAPI", "Python 3.12", "Prisma ORM", "PostgreSQL", "MongoDB", "Redis"],
  },
  {
    color: "#F59E0B",
    title: "AI & Services",
    items: ["Mistral AI", "Groq", "FastEmbed", "Cloudinary"],
  },
]

function PhoneMockup({ color, title, items }: { color: string; title: string; items: string[] }) {
  return (
    <div className="mx-auto w-full max-w-[260px]">
      <div className="relative rounded-[2.5rem] border-[3px] border-[#2D2D2D] bg-white shadow-lg">
        <div className="mx-auto h-5 w-[110px] rounded-b-xl bg-[#2D2D2D]" />
        <div className="aspect-[9/19] overflow-hidden rounded-b-[2.35rem] bg-gray-50">
          <div className="flex h-full flex-col">
            <div className="px-4 pb-3 pt-6" style={{ backgroundColor: color }}>
              <p className="text-center text-sm font-semibold text-white/90">{title}</p>
            </div>
            <div className="flex flex-1 flex-col justify-center gap-2 px-4">
              {items.map((item) => (
                <div key={item} className="rounded-lg border border-gray-100 bg-white px-3 py-2 text-center">
                  <span className="text-xs font-medium text-gray-700">{item}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

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
          {phones.map((phone, i) => (
            <motion.div
              key={phone.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: 0.1 + i * 0.1 }}
              className="flex-1 max-w-[260px]"
            >
              <PhoneMockup {...phone} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
