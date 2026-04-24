# Rembugan Backend API

Ini adalah repository backend untuk Rembugan, platform kolaborasi proyek yang menghubungkan individu berbakat dengan peluang proyek yang sesuai. API ini dibangun menggunakan **FastAPI**, **Prisma ORM (PostgreSQL)**, dan mengintegrasikan berbagai layanan seperti **Firebase Auth**, **Cloudinary**, dan **Gemini AI**.

## 🚀 Persiapan dan Instalasi

Ikuti langkah-langkah di bawah ini untuk menjalankan project ini di komputer lokal (Local Environment).

### 1. Prasyarat (Prerequisites)

Pastikan kamu sudah menginstal:
- **Python** (versi 3.10 atau lebih baru)
- **Node.js** (hanya dibutuhkan untuk menjalankan CLI Prisma, versi 16+ disarankan)
- **Git**

### 2. Clone Repository

Buka terminal dan clone repository ini ke komputer kamu:

```bash
git clone <URL_REPO_KAMU>
cd rembugan-backend
```

### 3. Setup Virtual Environment

Sangat disarankan menggunakan virtual environment agar dependencies (library) project ini tidak bentrok dengan project Python kamu yang lain.

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 4. Install Dependencies

Setelah virtual environment aktif, install semua library yang dibutuhkan:

```bash
pip install -r requirements.txt
```

*(Catatan: Proses ini mungkin memakan waktu karena menginstal library ML/AI seperti `rapidocr-onnxruntime` dan `pdf2image`)*.

### 5. Konfigurasi Environment Variables

Aplikasi ini membutuhkan beberapa kredensial eksternal (Database, Firebase, Cloudinary, Gemini).

1. Buat file bernama `.env` di root folder (`rembugan-backend/`).
2. Isi file `.env` tersebut dengan format berikut (minta nilai aslinya ke pemilik repo/tim):

```env
# Koneksi Database (Contoh menggunakan Neon DB)
DATABASE_URL='postgresql://<user>:<password>@<host>/<dbname>?sslmode=require'

# Cloudinary (Untuk penyimpanan gambar/foto profil)
CLOUDINARY_CLOUD_NAME="<your_cloud_name>"
CLOUDINARY_API_KEY="<your_api_key>"
CLOUDINARY_API_SECRET="<your_api_secret>"

# Gemini API Key (Untuk ekstraksi CV/Onboarding)
GEMINI_API_KEY="<your_gemini_api_key>"
```

### 6. Setup Firebase Admin SDK

Aplikasi ini menggunakan Firebase untuk verifikasi token autentikasi.

1. Dapatkan file kredensial service account Firebase (biasanya bernama `firebase-admin.json`) dari pemilik project.
2. Letakkan file tersebut di root folder (`rembugan-backend/firebase-admin.json`).

*Penting: File `.env` dan `firebase-admin.json` bersifat rahasia dan sudah diabaikan di `.gitignore`.*

### 7. Setup Prisma & Database

Jalankan perintah berikut untuk men-generate Prisma Client untuk Python dan sinkronisasi schema ke database.

**Generate Prisma Client:**
```bash
prisma generate
```

**Sinkronisasi Schema (Push ke Database):**
```bash
prisma db push
```
*(Perintah ini akan membuat/mengupdate tabel di database berdasarkan `prisma/schema.prisma`)*

### 8. Jalankan Server

Setelah semua setup selesai, kamu bisa menjalankan server FastAPI menggunakan Uvicorn:

```bash
uvicorn app.main:app --reload
```

Server akan berjalan di `http://127.0.0.1:8000`.

### 9. Test API (Swagger UI)

FastAPI secara otomatis membuatkan dokumentasi interaktif. Buka browser dan akses:
- **Swagger UI:** [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc:** [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

---

## 📂 Struktur Project

```text
rembugan-backend/
├── app/
│   ├── api/            # Route endpoints (onboarding, projects, fyp, chat, dll)
│   ├── core/           # Konfigurasi inti (database, security, cloudinary)
│   ├── schemas/        # Pydantic models untuk validasi data input/output
│   ├── services/       # Logic eksternal (AI OCR, Gemini, Matchmaking)
│   └── main.py         # Entry point aplikasi FastAPI
├── prisma/             # Schema database Prisma
├── .env                # (Buat Sendiri) Environment variables
├── firebase-admin.json # (Buat Sendiri) Kredensial Firebase
└── requirements.txt    # Daftar dependencies Python
```
