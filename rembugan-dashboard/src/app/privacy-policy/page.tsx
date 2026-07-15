export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-950 dark:to-slate-900">
      <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="text-center">
          <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 shadow-sm">
            <svg className="h-8 w-8 text-primary" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
            </svg>
          </div>
          <h1 className="text-4xl font-bold tracking-tight text-slate-900 dark:text-white">
            Kebijakan Privasi
          </h1>
          <p className="mt-3 text-base text-slate-500 dark:text-slate-400">
            Aplikasi Rembugan — Terakhir diperbarui: 15 Juli 2026
          </p>
        </div>

        <div className="mt-12 space-y-10">
          <Section number="1" title="Pendahuluan">
            <p>
              Rembugan (&quot;kami&quot;, &quot;aplikasi&quot;, &quot;platform&quot;) berkomitmen untuk melindungi privasi pengguna. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda saat menggunakan aplikasi Rembugan.
            </p>
            <p>
              Dengan mendaftar dan menggunakan aplikasi Rembugan, Anda menyetujui pengumpulan dan penggunaan data sesuai dengan Kebijakan Privasi ini.
            </p>
          </Section>

          <Section number="2" title="Data Yang Dikumpulkan">
            <h4 className="mb-3 font-semibold text-slate-700 dark:text-slate-300">2.1 Data yang Anda berikan secara langsung:</h4>
            <ul>
              <li>Nama lengkap</li>
              <li>NIM (Nomor Induk Mahasiswa)</li>
              <li>Alamat email</li>
              <li>Fakultas dan jurusan / program studi</li>
              <li>Password (disimpan dalam bentuk terenkripsi)</li>
              <li>Bio dan foto profil</li>
              <li>Minat (<em>interest</em>) dan <em>skill</em></li>
              <li>Riwayat pengalaman dan prestasi</li>
              <li>Tautan media sosial (opsional)</li>
            </ul>

            <h4 className="mb-3 mt-6 font-semibold text-slate-700 dark:text-slate-300">2.2 Data yang dikumpulkan secara otomatis:</h4>
            <ul>
              <li>Token perangkat untuk notifikasi <em>push</em></li>
              <li>Data interaksi (<em>like</em>, komentar, koneksi, lamaran proyek)</li>
            </ul>

            <h4 className="mb-3 mt-6 font-semibold text-slate-700 dark:text-slate-300">2.3 Data dari ekstraksi CV (opsional):</h4>
            <p>
              Apabila Anda mengunggah CV / Resume, kami mengekstrak data seperti nama, <em>skill</em>, pengalaman, dan foto profil menggunakan teknologi AI. Data CV Anda hanya diproses untuk tujuan pengisian profil otomatis dan tidak disimpan dalam bentuk asli.
            </p>
          </Section>

          <Section number="3" title="Penggunaan Data">
            <p>Data yang kami kumpulkan digunakan untuk:</p>
            <ul>
              <li>Membuat dan mengelola akun Anda</li>
              <li>Menampilkan profil Anda kepada pengguna lain</li>
              <li>Memberikan rekomendasi proyek, <em>showcase</em>, kompetisi, dan koneksi yang relevan (<em>smart matching</em>)</li>
              <li>Memfasilitasi komunikasi antar pengguna (<em>chat</em>, koneksi)</li>
              <li>Mengirim notifikasi terkait aktivitas di platform</li>
              <li>Meningkatkan dan mengoptimalkan pengalaman pengguna</li>
              <li>Keperluan analitik dan pengembangan fitur</li>
            </ul>
          </Section>

          <Section number="4" title="Pembagian Data">
            <div className="mb-4 rounded-xl border border-emerald-200 bg-emerald-50 px-5 py-4 dark:border-emerald-900/40 dark:bg-emerald-950/40">
              <p className="flex items-center gap-2 text-sm font-medium text-emerald-700 dark:text-emerald-300">
                <svg className="h-5 w-5 shrink-0" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Kami tidak menjual data pribadi Anda kepada pihak ketiga.
              </p>
            </div>
            <p className="mb-3">Data Anda dapat dibagikan dalam situasi berikut:</p>
            <ul>
              <li>Dengan pengguna lain sebagaimana terlihat di profil publik Anda (nama, foto, <em>skill</em>, pengalaman)</li>
              <li>Dengan penyedia layanan pihak ketiga yang mendukung operasional aplikasi (Cloudinary untuk penyimpanan gambar, Firebase untuk notifikasi)</li>
              <li>Apabila diwajibkan oleh hukum</li>
            </ul>
          </Section>

          <Section number="5" title="Penyimpanan Dan Keamanan Data">
            <p>
              Data Anda disimpan di server yang aman dengan lapisan enkripsi. Kami menerapkan langkah-langkah keamanan yang wajar untuk melindungi data Anda dari akses tidak sah, perubahan, pengungkapan, atau penghancuran.
            </p>
          </Section>

          <Section number="6" title="Hak Anda">
            <p>Anda memiliki hak untuk:</p>
            <ul>
              <li>Mengakses data pribadi Anda</li>
              <li>Memperbarui atau memperbaiki data Anda</li>
              <li>Menghapus akun dan data Anda</li>
              <li>Menarik persetujuan pemrosesan data</li>
            </ul>
            <p className="mt-3">
              Untuk menghapus akun, Anda dapat menggunakan fitur hapus akun di pengaturan aplikasi atau menghubungi tim dukungan.
            </p>
          </Section>

          <Section number="7" title="Penyimpanan Data Retensi">
            <p>
              Kami menyimpan data Anda selama akun Anda masih aktif. Apabila Anda menghapus akun, data Anda akan dihapus dalam jangka waktu yang wajar sesuai dengan ketentuan hukum yang berlaku.
            </p>
          </Section>

          <Section number="8" title="Perubahan Kebijakan Privasi">
            <p>
              Kebijakan Privasi ini dapat diperbarui dari waktu ke waktu. Perubahan akan diberitahukan melalui aplikasi atau email. Dengan terus menggunakan aplikasi setelah perubahan, Anda menyetujui kebijakan yang diperbarui.
            </p>
          </Section>

          <Section number="9" title="Kontak">
            <div className="rounded-xl border border-slate-200 bg-white px-6 py-5 shadow-sm dark:border-slate-800 dark:bg-slate-900">
              <p className="text-sm text-slate-600 dark:text-slate-400">
                Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini, silakan hubungi kami melalui:
              </p>
              <a
                href="mailto:support@rembugan.app"
                className="mt-2 inline-flex items-center gap-2 text-sm font-medium text-primary hover:text-primary/80 hover:underline"
              >
                <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
                </svg>
                
              </a>
            </div>
          </Section>
        </div>

        <div className="mt-16 rounded-2xl border border-slate-200 bg-white/50 px-8 py-6 text-center dark:border-slate-800 dark:bg-slate-900/50">
          <p className="text-xs text-slate-400 dark:text-slate-500">
            &copy; {new Date().getFullYear()} Rembugan. Seluruh hak cipta dilindungi undang-undang.
          </p>
        </div>
      </div>
    </div>
  )
}

function Section({ number, title, children }: { number: string; title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm transition-shadow hover:shadow-md dark:border-slate-800 dark:bg-slate-950">
      <div className="mb-6 flex items-center gap-4">
        <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white shadow-sm">
          {number}
        </span>
        <h2 className="text-xl font-bold tracking-tight text-slate-900 dark:text-white">
          {title}
        </h2>
      </div>
      <div className="space-y-3 text-sm leading-relaxed text-slate-600 dark:text-slate-400">
        {children}
      </div>
    </section>
  )
}
