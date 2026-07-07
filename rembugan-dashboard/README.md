# Rembugan Dashboard

Admin dashboard untuk platform Rembugan — Next.js 16 + TypeScript + Shadcn UI.

## Tech Stack

- **Framework:** Next.js 16 (App Router)
- **Language:** TypeScript (strict)
- **UI:** Shadcn UI + Radix Primitives
- **Styling:** Tailwind CSS v4
- **Data Fetching:** TanStack Query
- **Table:** TanStack Table
- **Chart:** Recharts

## Fitur

- Dashboard Statistik (users, projects, showcases, tasks)
- Manajemen Users (CRUD, Import CSV)
- Manajemen Projects + Applications
- Manajemen Showcases
- Manajemen Tasks
- Manajemen Competitions
- Profile QR, Project QR
- Public pages: `/p/:id`, `/s/:id`, `/u/:id`, `/join/:token`

## Setup

```bash
cd rembugan-dashboard
cp .env.example .env.local
# Isi NEXT_PUBLIC_API_BASE_URL dengan URL backend
npm install
npm run dev
```

## Build Production

```bash
npm run build
npm start
```

## Environment Variables

| Variable | Keterangan |
|----------|-----------|
| `NEXT_PUBLIC_API_BASE_URL` | Backend API URL |
| `NEXT_PUBLIC_APP_URL` | Dashboard public URL |
