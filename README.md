# Rembugan

"LinkedIn for Students" — Collaboration, Project Matchmaking, and Portfolio Platform.

Rembugan is an integrated platform designed to help students and young professionals discover projects, build connections, and manage their portfolios through an AI-based matchmaking system.

## Repository Structure

This project uses a monorepo structure consisting of three main parts:

- [**`rembugan-backend/`**](./rembugan-backend/README.md) — FastAPI API service (Python, Prisma ORM, PostgreSQL + MongoDB).
- [**`rembugan_frontend/`**](./rembugan_frontend/README.md) — Flutter-based mobile app (GetX State Management).
- [**`rembugan-dashboard/`**](./rembugan-dashboard/README.md) — Next.js admin dashboard (Shadcn UI, Tailwind CSS).

## Main Technologies

| Layer | Technology |
|-------|-----------|
| **Backend** | Python, FastAPI, Prisma (PostgreSQL), MongoDB, Gemini AI, Mistral AI, Groq, Cloudinary, Resend |
| **Frontend** | Flutter, GetX, Dio, forui, Lottie, flutter_secure_storage |
| **Dashboard** | Next.js 16 (App Router), TypeScript, Shadcn UI, Tailwind CSS v4, TanStack Query, Recharts |

## Key Features

- **AI Matchmaking:** User-project recommendations using embedding/cosine similarity.
- **Social Networking:** Posts, portfolio showcases, connections, and chat (DM & group).
- **Project Management:** Kanban-style workspace & task management.
- **Security & Verification:** OTP email verification, QR code project invitations.
- **Competition Exploration:** Scraping and scoring competition data (Lomba).
- **Admin Dashboard:** CRUD management (users, projects, showcases, tasks, applications).

## Documentation & Rules

- [Product Vision](PRODUCT.md)
- [Design System](DESIGN.md)
- [Agent Guidelines](AGENTS.md)

Please see the `README.md` inside each directory for specific installation guides and instructions on running the services locally.
