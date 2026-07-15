"use client"

import { useState, useEffect } from "react"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { Loader2, Save, Eye, Edit3, CheckCircle2 } from "lucide-react"
import { toast } from "sonner"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { fetchPrivacyPolicy, updatePrivacyPolicy } from "@/lib/api"

const DEFAULT_PRIVACY_POLICY = `KEBIJAKAN PRIVASI (Privacy Policy)

Terakhir diperbarui: ${new Date().toLocaleDateString("id-ID", { year: "numeric", month: "long", day: "numeric" })}

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
  const queryClient = useQueryClient()
  const [content, setContent] = useState("")
  const [hasChanges, setHasChanges] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ["privacy-policy"],
    queryFn: async () => {
      const res = await fetchPrivacyPolicy()
      const c = res?.data?.content || ""
      setContent(c || DEFAULT_PRIVACY_POLICY)
      return res
    },
  })

  useEffect(() => {
    if (data?.data?.content) {
      setContent(data.data.content)
    }
  }, [data])

  const updateMutation = useMutation({
    mutationFn: updatePrivacyPolicy,
    onSuccess: (res) => {
      if (res.status === "success") {
        toast.success("Kebijakan privasi berhasil disimpan")
        setHasChanges(false)
        queryClient.invalidateQueries({ queryKey: ["privacy-policy"] })
      } else {
        toast.error(res.detail || "Gagal menyimpan")
      }
    },
    onError: () => {
      toast.error("Gagal menyimpan kebijakan privasi")
    },
  })

  function handleSave() {
    updateMutation.mutate(content)
  }

  function handleReset() {
    setContent(DEFAULT_PRIVACY_POLICY)
    setHasChanges(true)
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Privacy Policy</h1>
          <p className="text-sm text-muted-foreground">
            Kelola kebijakan privasi aplikasi Rembugan
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={handleReset}>
            Reset Default
          </Button>
          <Button onClick={handleSave} disabled={updateMutation.isPending || !hasChanges}>
            {updateMutation.isPending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Menyimpan...
              </>
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                Simpan
              </>
            )}
          </Button>
        </div>
      </div>

      <Tabs defaultValue="edit" className="w-full">
        <TabsList>
          <TabsTrigger value="edit">
            <Edit3 className="mr-2 h-4 w-4" />
            Edit
          </TabsTrigger>
          <TabsTrigger value="preview">
            <Eye className="mr-2 h-4 w-4" />
            Preview
          </TabsTrigger>
        </TabsList>
        <TabsContent value="edit" className="mt-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Edit Konten</CardTitle>
              <CardDescription>
                Gunakan format teks biasa. Setiap perubahan akan terlihat di aplikasi setelah disimpan.
              </CardDescription>
            </CardHeader>
            <CardContent>
              {isLoading ? (
                <div className="flex items-center justify-center py-20">
                  <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
                </div>
              ) : (
                <textarea
                  value={content}
                  onChange={(e) => {
                    setContent(e.target.value)
                    setHasChanges(true)
                  }}
                  className="w-full h-[600px] rounded-md border border-input bg-background p-4 text-sm font-mono leading-relaxed resize-y focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                  placeholder="Tulis kebijakan privasi di sini..."
                />
              )}
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="preview" className="mt-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Pratinjau</CardTitle>
              <CardDescription>
                Tampilan kebijakan privasi seperti yang akan terlihat di aplikasi.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap font-sans leading-relaxed">
                {content || "Belum ada konten kebijakan privasi."}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {hasChanges && (
        <div className="flex items-center gap-2 rounded-lg border border-amber-500/30 bg-amber-500/10 px-4 py-3 text-sm text-amber-600 dark:text-amber-400">
          <CheckCircle2 className="h-4 w-4" />
          Ada perubahan yang belum disimpan. Klik "Simpan" untuk menyimpan perubahan.
        </div>
      )}
    </div>
  )
}
