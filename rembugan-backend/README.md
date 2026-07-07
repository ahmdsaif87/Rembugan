# Rembugan Backend

Backend API untuk platform Rembugan — FastAPI + Prisma (PostgreSQL) + MongoDB + AI Services.

## Tech Stack

- **Framework:** FastAPI
- **ORM:** Prisma (PostgreSQL)
- **NoSQL:** MongoDB (competitions)
- **AI:** Mistral AI, Groq, FastEmbed (BGE-small)
- **Storage:** Cloudinary
- **Email:** Resend
- **Cache:** Redis (fallback MemoryCache)
- **Auth:** JWT + bcrypt

## API Endpoints

| Prefix | Fitur |
|--------|-------|
| `/auth` | Register, Login, OTP, Admin Login |
| `/onboarding` | Scan CV, Save Profile |
| `/profile` | Settings, Recommended Users, Search |
| `/projects` | CRUD, Explore (Match Score), Suggestions |
| `/showcase` | CRUD, Like, Comment, Feed |
| `/collaboration` | Apply, Accept/Reject Application |
| `/workspace` | Tasks, Kanban, Files, Members |
| `/chat` | WebSocket Chat, DM, Group, History |
| `/notifications` | List, Mark Read |
| `/connections` | Send, Accept, Reject, List |
| `/competitions` | All, Relevant, Stats |
| `/posts` | Create, Share |
| `/admin` | Stats, Users, Projects, Showcases, Tasks |
| `/qr` | Profile QR, Project Invite, Join |
| `/upload` | Image Upload to Cloudinary |

## Local Development (tanpa Docker)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Isi .env
prisma generate
prisma db push
python scripts/seed_campus.py
python seed_projects.py
uvicorn app.main:app --reload
```

## Environment Variables

| Variable | Keterangan |
|----------|-----------|
| `DATABASE_URL` | PostgreSQL (Neon) |
| `JWT_SECRET_KEY` | `openssl rand -hex 32` |
| `CLOUDINARY_*` | Cloudinary credentials |
| `RESEND_API_KEY` | Email OTP |
| `MISTRAL_API_KEY` | AI OCR / NLP |
| `GROQ_API_KEY` | AI resume processing |
| `MONGO_URI` | MongoDB Atlas |
| `REDIS_URL` | Optional (fallback MemoryCache) |
| `ALLOWED_ORIGINS` | CORS whitelist (comma separated) |
| `APP_URL` | Public URL untuk QR code & share link |
