# AGENT.md - Panduan Kerja Agen

## Aturan Utama
1. **Scope:** Jaga scope perubahan tetap kecil dan hanya edit file yang relevan. Jangan format file yang tidak terkait.
2. **Secrets:** JANGAN PERNAH commit secret, `.env`, `firebase-admin.json`, token, atau kredensial.
3. **Validasi:** Selalu jalankan command lint/test atau build setelah mengedit untuk memastikan aplikasi tidak rusak.
4. **Struktur:**
   - `rembugan-backend/`: FastAPI & Python. Update Prisma schema & Pydantic schema jika API berubah.
   - `rembugan_frontend/`: Flutter & Dart. Hindari logic berat di View.
   - `rembugan-dashboard/`: Next.js (App Router). Gunakan Shadcn UI & TypeScript.
5. **Konteks:** Perhatikan dependensi lokal, baca README di masing-masing folder sebelum menjalankan service.
