export default function DeleteAccountPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white dark:from-slate-950 dark:to-slate-900">
      <div className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="text-center">
          <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-red-50 shadow-sm dark:bg-red-950/40">
            <svg className="h-8 w-8 text-red-500" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
            </svg>
          </div>
          <h1 className="text-4xl font-bold tracking-tight text-slate-900 dark:text-white">
            Hapus Akun
          </h1>
          <p className="mt-3 text-base text-slate-500 dark:text-slate-400">
            Rembugan — Panduan penghapusan akun dan data
          </p>
        </div>

        <div className="mt-12 space-y-8">
          <section className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-800 dark:bg-slate-950">
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">
              Cara Menghapus Akun
            </h2>
            <div className="mt-6 space-y-4 text-sm leading-relaxed text-slate-600 dark:text-slate-400">
              <p>Anda dapat menghapus akun dengan dua cara:</p>

              <div className="rounded-xl border border-slate-200 p-5 dark:border-slate-800">
                <h3 className="font-semibold text-slate-800 dark:text-slate-200">Cara 1: Hapus melalui Aplikasi (Direkomendasikan)</h3>
                <ol className="mt-3 list-inside list-decimal space-y-2">
                  <li>Buka aplikasi Rembugan</li>
                  <li>Masuk ke menu <strong>Profil</strong> atau <strong>Settings</strong></li>
                  <li>Pilih <strong>Hapus Akun</strong> atau <strong>Delete Account</strong></li>
                  <li>Konfirmasi penghapusan akun Anda</li>
                </ol>
              </div>

              <div className="rounded-xl border border-slate-200 p-5 dark:border-slate-800">
                <h3 className="font-semibold text-slate-800 dark:text-slate-200">Cara 2: Permintaan melalui Email</h3>
                <p className="mt-2">
                  Kirim permintaan penghapusan akun ke alamat email di bawah dengan subjek &quot;Permintaan Hapus Akun&quot; serta menyertakan NIM atau email yang terdaftar.
                </p>
              </div>
            </div>
          </section>

          <section className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-800 dark:bg-slate-950">
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">
              Data yang Dihapus
            </h2>
            <div className="mt-6">
              <p className="text-sm text-slate-600 dark:text-slate-400">
                Saat akun dihapus, data berikut akan dihapus secara permanen:
              </p>
              <ul className="mt-4 space-y-2 text-sm text-slate-600 dark:text-slate-400">
                {[
                  "Profil dan foto profil",
                  "Data diri (nama, NIM, email, bio, minat)",
                  "Skill dan pengalaman",
                  "Riwayat chat dan notifikasi",
                  "Koneksi dan pertemanan",
                  "Postingan showcase",
                  "Token perangkat (push notification)",
                ].map((item) => (
                  <li key={item} className="flex items-start gap-3">
                    <svg className="mt-0.5 h-4 w-4 shrink-0 text-red-400" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          </section>

          <section className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm dark:border-slate-800 dark:bg-slate-950">
            <h2 className="text-xl font-bold text-slate-900 dark:text-white">
              Data yang Tidak Dihapus
            </h2>
            <div className="mt-6">
              <p className="text-sm text-slate-600 dark:text-slate-400">
                Data berikut <strong>tidak dapat dihapus</strong> dan tetap disimpan untuk kepentingan hukum dan operasional:
              </p>
              <ul className="mt-4 space-y-2 text-sm text-slate-600 dark:text-slate-400">
                {[
                  "Data anonim/agregat untuk keperluan analitik",
                  "Riwayat log aktivitas yang diperlukan untuk kepatuhan hukum",
                ].map((item) => (
                  <li key={item} className="flex items-start gap-3">
                    <svg className="mt-0.5 h-4 w-4 shrink-0 text-amber-400" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
                    </svg>
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          </section>

          <section className="rounded-2xl border border-amber-200 bg-amber-50 p-8 dark:border-amber-900/40 dark:bg-amber-950/40">
            <h2 className="text-xl font-bold text-amber-800 dark:text-amber-200">
              Periode Retensi
            </h2>
            <p className="mt-3 text-sm text-amber-700 dark:text-amber-300">
              Proses penghapusan akun diproses dalam waktu maksimal 30 hari setelah permintaan dikonfirmasi. Beberapa data mungkin tetap tersimpan dalam backup sistem selama periode tertentu sebelum dihapus sepenuhnya.
            </p>
          </section>

          <div className="text-center">
            <a
              href="mailto:support@rembugan.app?subject=Permintaan%20Hapus%20Akun"
              className="inline-flex items-center gap-2 rounded-xl bg-primary px-6 py-3 text-sm font-medium text-white shadow-sm transition-all hover:bg-primary/90"
            >
              <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
              </svg>
              Kirim Permintaan via Email
            </a>
          </div>
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
