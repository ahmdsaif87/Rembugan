"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { ChevronDown } from "lucide-react"

const faqs = [
  {
    q: "Apakah Rembugan gratis?",
    a: "Ya, Rembugan gratis buat mahasiswa Universitas Harkat Negeri. Kami percaya tools kolaborasi harus bisa diakses semua orang.",
  },
  {
    q: "Gimana cara kerja matchmaking-nya?",
    a: "AI kami menganalisis skill, minat, dan proyek sebelumnya pake embedding, lalu recommend teman dan proyek yang paling cocok buat kamu.",
  },
  {
    q: "Bisa dipake buat proyek non-akademik?",
    a: "Tentu. Rembugan bisa dipake buat proyek apa aja — hackathon, side project, open source, dan lainnya.",
  },
  {
    q: "Ada aplikasi mobile-nya?",
    a: "Ya, Rembugan dibangun pake Flutter dan tersedia di Android. iOS sedang dalam pengembangan.",
  },
  {
    q: "Bisa showcase proyek yang udah selesai?",
    a: "Bisa banget. Setiap proyek punya halaman showcase publik yang bisa kamu share di portofolio, LinkedIn, atau CV.",
  },
]

function AccordionItem({
  question,
  answer,
  isOpen,
  onToggle,
}: {
  question: string
  answer: string
  isOpen: boolean
  onToggle: () => void
}) {
  return (
    <div className="border-b last:border-b-0">
      <button
        onClick={onToggle}
        className="flex w-full items-center justify-between gap-4 py-4 text-left text-sm font-medium transition-colors hover:text-[#6366F1]"
      >
        {question}
        <ChevronDown
          className={`h-4 w-4 shrink-0 text-muted-foreground transition-transform duration-200 ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>
      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            key="content"
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <p className="pb-4 text-sm leading-relaxed text-muted-foreground">{answer}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

export function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <section id="faq" className="flex min-h-screen items-center justify-center border-b">
      <div className="mx-auto w-full max-w-6xl px-4 py-10">
        <div className="mx-auto max-w-xl text-center">
          <h2 className="text-[clamp(1.75rem,3vw,2.5rem)] font-bold tracking-tight">
            Pertanyaan yang sering diajuin
          </h2>
        </div>
        <div className="mx-auto mt-10 max-w-2xl">
          {faqs.map((faq, i) => (
            <AccordionItem
              key={i}
              question={faq.q}
              answer={faq.a}
              isOpen={openIndex === i}
              onToggle={() => setOpenIndex(openIndex === i ? null : i)}
            />
          ))}
        </div>
      </div>
    </section>
  )
}
