# Rembugan

"LinkedIn for Students" — Platform Kolaborasi, Matchmaking Proyek, dan Portofolio.

## Repository Structure

```
rembugan/
├── rembugan-backend/       # FastAPI backend (Python, Prisma, PostgreSQL, MongoDB)
├── rembugan_frontend/      # Flutter mobile app (GetX State Management)
├── rembugan-dashboard/     # Next.js admin dashboard (Shadcn UI, Tailwind CSS)
├── docker-compose.yml      # One-command setup for local development
├── SETUP.md                # Panduan setup lokal (Wajib baca!)
└── README.md
```

## Quick Start

```bash
# 1. Clone & masuk direktori
git clone <url-repo> && cd rembugan

# 2. Setup env files
cp rembugan-backend/.env.example rembugan-backend/.env
cp rembugan-dashboard/.env.example rembugan-dashboard/.env.local

# 3. Isi .env dengan credentials (Neon, Cloudinary, dll)
# 4. Jalankan semua service
docker compose up
```

- Backend API: http://localhost:8000
- Dashboard Admin: http://localhost:3000
- Docs API: http://localhost:8000/docs

> **Pertama kali?** Baca [SETUP.md](./SETUP.md) untuk panduan lengkap dari instalasi Docker sampai isi API keys.

## Teknologi

| Layer | Teknologi |
|-------|-----------|
| **Backend** | Python, FastAPI, Prisma (PostgreSQL), MongoDB, Mistral AI, Groq, Cloudinary, Resend |
| **Mobile** | Flutter, GetX, Dio, Lottie, flutter_secure_storage |
| **Dashboard** | Next.js 16 (App Router), TypeScript, Shadcn UI, Tailwind CSS v4, TanStack Query |

## Fitur Utama

- **AI Matchmaking:** Rekomendasi user-project berdasarkan embedding/cosine similarity
- **Social Networking:** Posts, showcase portofolio, koneksi, dan chat (DM & grup)
- **Project Management:** Workspace Kanban & task management
- **QR Code:** Undangan proyek via QR, scan profile
- **Admin Dashboard:** CRUD users, projects, showcases, tasks, applications

## Dokumentasi

- [Panduan Setup Lokal](SETUP.md)
- [Product Vision](PRODUCT.md)
- [Design System](DESIGN.md)
