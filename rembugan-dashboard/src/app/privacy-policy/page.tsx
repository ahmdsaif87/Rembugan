const PRIVACY_POLICY = `KEBIJAKAN PRIVASI (Privacy Policy)

Terakhir diperbarui: 15 Juli 2026

1. PENDAHULUAN

Rembugan ("kami", "aplikasi", "platform") berkomitmen untuk melindungi privasi pengguna. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi Anda saat menggunakan aplikasi Rembugan.

Dengan mendaftar dan menggunakan aplikasi Rembugan, Anda menyetujui pengumpulan dan penggunaan data sesuai dengan Kebijakan Privasi ini.

2. DATA YANG DIKUMPULKAN

2.1 Data yang Anda berikan secara langsung:
- Nama lengkap
- NIM (Nomor Induk Mahasiswa)
- Alamat email
- Fakultas dan jurusan/program studi
- Password (disimpan dalam bentuk terenkripsi)
- Bio dan foto profil
- Minat (interest) dan skill
- Riwayat pengalaman dan prestasi
- Tautan media sosial (opsional)

2.2 Data yang dikumpulkan secara otomatis:
- Token perangkat untuk notifikasi push
- Data interaksi (like, komentar, koneksi, lamaran proyek)

2.3 Data dari ekstraksi CV (opsional):
Apabila Anda mengunggah CV/Resume, kami mengekstrak data seperti nama, skill, pengalaman, dan foto profil menggunakan teknologi AI. Data CV Anda hanya diproses untuk tujuan pengisian profil otomatis dan tidak disimpan dalam bentuk asli.

3. PENGGUNAAN DATA

Data yang kami kumpulkan digunakan untuk:
- Membuat dan mengelola akun Anda
- Menampilkan profil Anda kepada pengguna lain
- Memberikan rekomendasi proyek, showcase, kompetisi, dan koneksi yang relevan (smart matching)
- Memfasilitasi komunikasi antar pengguna (chat, koneksi)
- Mengirim notifikasi terkait aktivitas di platform
- Meningkatkan dan mengoptimalkan pengalaman pengguna
- Keperluan analitik dan pengembangan fitur

4. PEMBAGIAN DATA

Kami tidak menjual data pribadi Anda kepada pihak ketiga.

Data Anda dapat dibagikan dalam situasi berikut:
- Dengan pengguna lain sebagaimana terlihat di profil publik Anda (nama, foto, skill, pengalaman)
- Dengan penyedia layanan pihak ketiga yang mendukung operasional aplikasi (Cloudinary untuk penyimpanan gambar, Firebase untuk notifikasi)
- Apabila diwajibkan oleh hukum

5. PENYIMPANAN DAN KEAMANAN DATA

Data Anda disimpan di server yang aman dengan lapisan enkripsi. Kami menerapkan langkah-langkah keamanan yang wajar untuk melindungi data Anda dari akses tidak sah, perubahan, pengungkapan, atau penghancuran.

6. HAK ANDA

Anda memiliki hak untuk:
- Mengakses data pribadi Anda
- Memperbarui atau memperbaiki data Anda
- Menghapus akun dan data Anda
- Menarik persetujuan pemrosesan data

Untuk menghapus akun, Anda dapat menggunakan fitur hapus akun di pengaturan aplikasi atau menghubungi tim dukungan.

7. PENYIMPANAN DATA RETENSI

Kami menyimpan data Anda selama akun Anda masih aktif. Apabila Anda menghapus akun, data Anda akan dihapus dalam jangka waktu yang wajar sesuai dengan ketentuan hukum yang berlaku.

8. PERUBAHAN KEBIJAKAN PRIVASI

Kebijakan Privasi ini dapat diperbarui dari waktu ke waktu. Perubahan akan diberitahukan melalui aplikasi atau email. Dengan terus menggunakan aplikasi setelah perubahan, Anda menyetujui kebijakan yang diperbarui.

9. KONTAK

Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini, silakan hubungi kami melalui email: support@rembugan.app`

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Privacy Policy</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Kebijakan Privasi Aplikasi Rembugan
          </p>
        </div>

        <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap font-sans leading-relaxed">
          {PRIVACY_POLICY}
        </div>

        <div className="mt-12 border-t pt-6 text-center text-xs text-muted-foreground">
          &copy; {new Date().getFullYear()} Rembugan. All rights reserved.
        </div>
      </div>
    </div>
  )
}
