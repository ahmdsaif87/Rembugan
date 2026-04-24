# 🚀 Rembugan

> "LinkedIn for Students" — Platform Kolaborasi, Matchmaking Proyek, dan Portofolio untuk Mahasiswa.

**Rembugan** adalah sebuah aplikasi mobile yang dirancang khusus untuk ekosistem kampus. Aplikasi ini membantu mahasiswa mencari rekan satu tim untuk lomba, riset, atau tugas akhir (Capstone) berdasarkan kecocokan *skill* (AI Matchmaking), serta menyediakan ruang (*Showcase*) untuk memamerkan portofolio proyek.

Proyek ini dikembangkan sebagai bagian dari Capstone Project Mahasiswa D4 Teknik Informatika, Universitas Harkat Negeri.

---

## ✨ Fitur Utama

- 🧠 **AI Smart Onboarding:** Ekstraksi data CV/Resume secara otomatis menggunakan OCR & Google Gemini AI untuk mengisi profil pengguna.
- 🎯 **Skill-Based Matchmaking:** Algoritma yang menghitung *Match Score* antara keahlian (*skills*) mahasiswa dengan kebutuhan sebuah proyek/lowongan.
- 📱 **Showcase Feed:** *Timeline* sosial ala profesional untuk membagikan progres proyek, dokumentasi, atau mencari kolaborator baru.
- 🔒 **Secure Authentication:** Sistem login dan keamanan token berstandar industri menggunakan Firebase Authentication.

---

## 🛠️ Tech Stack

**Backend (AI & API Service)**
- **Framework:** Python 3.12 + [FastAPI](https://fastapi.tiangolo.com/)
- **Database & ORM:** PostgreSQL (Neon Serverless) + [Prisma ORM](https://prisma-client-py.readthedocs.io/)
- **AI & NLP:** Google Gemini Flash API, RapidOCR, dan fitz
- **Auth:** Firebase Admin SDK

**Frontend (Mobile App)**
- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** GetX 
- **API Client:** HTTP

---

## 📂 Struktur Direktori (Monorepo)

```text
rembugan/
├── rembugan-backend/    # Kode sumber FastAPI, AI NLP, dan Prisma Schema
├── rembugan-frontend/   # Kode sumber UI Flutter mobile app
├── .gitignore           # Aturan tracking Git
└── README.md            # Dokumentasi proyek (File ini)
