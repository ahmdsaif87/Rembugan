import Link from "next/link"
import { Github } from "lucide-react"

export function Footer() {
  return (
    <footer className="border-t">
      <div className="mx-auto max-w-6xl px-4 py-12">
        <div className="grid gap-8 md:grid-cols-5">
          <div className="md:col-span-2">
            <Link href="/">
              <img src="/logo.png" alt="Rembugan" className="h-8 w-8" />
            </Link>
            <p className="mt-3 max-w-xs text-sm text-muted-foreground">
              Platform kolaborasi proyek buat mahasiswa Universitas Harkat Negeri. Temuin tim, bangun portofolio.
            </p>
          </div>
          {[
            {
              title: "Produk",
              links: [
                { label: "Fitur", href: "#features" },
                { label: "Cara Kerja", href: "#how-it-works" },
                { label: "FAQ", href: "#faq" },
              ],
            },
            {
              title: "Perusahaan",
              links: [
                { label: "GitHub", href: "https://github.com/ahmadsaif/rembugan" },
                { label: "Privasi", href: "#" },
                { label: "Syarat & Ketentuan", href: "#" },
              ],
            },
            {
              title: "Komunitas",
              links: [
                { label: "Dashboard Admin", href: "/login" },
                { label: "Aplikasi Mobile", href: "#" },
              ],
            },
          ].map((group) => (
            <div key={group.title}>
              <h4 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">{group.title}</h4>
              <ul className="mt-3 space-y-2 text-sm">
                {group.links.map((link) => (
                  <li key={link.label}>
                    <Link href={link.href} className="text-muted-foreground transition-colors hover:text-foreground">
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="mt-10 flex flex-col items-center justify-between gap-4 border-t pt-6 text-sm text-muted-foreground md:flex-row">
          <p>&copy; {new Date().getFullYear()} Rembugan. All rights reserved.</p>
          <div className="flex items-center gap-4">
            <a href="https://github.com/ahmadsaif/rembugan" target="_blank" rel="noreferrer" className="transition-colors hover:text-foreground">
              <Github className="h-4 w-4" />
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
