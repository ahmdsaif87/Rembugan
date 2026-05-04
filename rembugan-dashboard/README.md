# Rembugan Dashboard

Admin dashboard dibangun menggunakan **Next.js (App Router)**, **TypeScript**, dan **Shadcn UI**.

## Setup Lokal

1. Install dependencies:
   ```bash
   npm install
   ```
2. Setup Environment Variables:
   Buat file `.env.local` dan masukkan kredensial:
   ```env
   NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
   NEXT_PUBLIC_ADMIN_USERNAME=admin
   NEXT_PUBLIC_ADMIN_PASSWORD=admin123
   ```
3. Jalankan Development Server:
   ```bash
   npm run dev
   ```
   Akses dashboard di `http://localhost:3000`. Root akan otomatis redirect ke `/login` jika belum autentikasi.
