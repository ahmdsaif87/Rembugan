import { Nav } from "@/components/landing/nav"
import { Hero } from "@/components/landing/hero"
import { HowItWorks } from "@/components/landing/how-it-works"
import { Features } from "@/components/landing/features"
import { ProductPreview } from "@/components/landing/product-preview"
import { TechStack } from "@/components/landing/tech-stack"

import { FAQ } from "@/components/landing/faq"
import { CTA } from "@/components/landing/cta"
import { Footer } from "@/components/landing/footer"

export default function LandingPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Nav />
      <main>
        <Hero />
        <HowItWorks />
        <Features />
        <ProductPreview />
        <TechStack />

        <FAQ />
        <CTA />
      </main>
      <Footer />
    </div>
  )
}
