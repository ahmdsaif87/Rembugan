# Rembugan Backend

Backend API dibangun dengan **FastAPI**, **Prisma (PostgreSQL)**, dan **Gemini AI**.

## Setup Lokal

1. Buat virtual environment & install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
2. Setup Environment Variables:
   Buat `.env` dan tambahkan credential: `DATABASE_URL`, `CLOUDINARY_*`, `GEMINI_API_KEY`.
   Tambahkan juga file `firebase-admin.json` di root folder backend.
3. Sinkronisasi Database:
   ```bash
   prisma generate
   prisma db push
   ```
4. Jalankan Server:
   ```bash
   uvicorn app.main:app --reload
   ```
   Akses Swagger UI di `http://127.0.0.1:8000/docs`.
