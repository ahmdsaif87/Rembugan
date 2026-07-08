"use client"

import { motion } from "framer-motion"

const categories = [
  {
    label: "Frontend",
    items: ["Next.js 16", "TypeScript", "Tailwind CSS", "Shadcn UI"],
  },
  {
    label: "Backend",
    items: ["FastAPI", "Python 3.12", "Prisma ORM", "REST API"],
  },
  {
    label: "Database & Cache",
    items: ["PostgreSQL (Neon)", "MongoDB", "Redis", "pgvector"],
  },
  {
    label: "AI & Services",
    items: ["Mistral AI", "Groq", "FastEmbed", "Cloudinary"],
  },
]

export function TechStack() {
  return (
    <section className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <h2 className="text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Dibangun pake teknologi modern
          </h2>
          <p className="mt-3 text-muted-foreground">
            Dari frontend sampai deployment — teknologi yang bikin Rembugan reliable.
          </p>
        </div>
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.4 }}
          className="mt-12"
        >
          <div className="mx-auto grid max-w-3xl gap-6 sm:grid-cols-2">
            {categories.map((cat) => (
              <div key={cat.label} className="rounded-xl border bg-card p-5">
                <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">{cat.label}</p>
                <div className="mt-3 flex flex-wrap gap-2">
                  {cat.items.map((item) => (
                    <span
                      key={item}
                      className="rounded-md border bg-background px-2.5 py-1 text-xs font-medium text-foreground"
                    >
                      {item}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  )
}
