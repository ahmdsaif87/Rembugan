# Rembugan

"LinkedIn for Students" — Platform Kolaborasi, Matchmaking Proyek, dan Portofolio.

## Monorepo Structure

- `rembugan-backend/` — FastAPI API service (Python, Prisma ORM, PostgreSQL + MongoDB).
- `rembugan_frontend/` — Flutter mobile app (GetX state management).
- `rembugan-dashboard/` — Next.js admin dashboard (Shadcn UI, Tailwind CSS).

## Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Python, FastAPI, Prisma (PostgreSQL), MongoDB, Gemini AI, Mistral AI, Groq, Cloudinary, Resend (email/OTP) |
| **Frontend** | Flutter, GetX, Dio, forui, Lottie, flutter_secure_storage |
| **Dashboard** | Next.js 16 (App Router), TypeScript, Shadcn UI, Tailwind CSS v4, TanStack Query, TanStack Table, Recharts, Zod, dnd-kit |

## Features

- AI-powered project-user matchmaking (embedding/cosine similarity)
- Social networking: posts, showcases, connections, chat (DM + group)
- Kanban-style workspace & task management
- OTP email verification, QR code project invites
- Competition scraping & scoring
- Public profile, project & showcase pages
- Admin dashboard (CRUD: users, projects, showcases, tasks, applications)

## Resources

- [Product Vision](PRODUCT.md)
- [Design System](DESIGN.md)
- [Agent Guidelines](AGENTS.md)
- See README inside each folder for specific run instructions.
