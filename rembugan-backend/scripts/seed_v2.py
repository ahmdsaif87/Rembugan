#!/usr/bin/env python3
"""Seed v2 — 70 user dummy + showcase + project + semua relasi.
Pakai SQLAlchemy langsung (gak pakai Prisma).

Cara jalanin:
  cd rembugan-backend
  python scripts/seed_v2.py

Env:
  - Baca DATABASE_URL dari .env (bisa Neon / Supabase)
  - Dua user berikut TIDAK ikut dihapus:
      "Ahmad Saifi Khayatu Ulumuddin" & "Dede Fjkgj"
"""

import asyncio
import hashlib
import os
import random
import sys
import uuid
from datetime import datetime, timedelta, timezone

import bcrypt

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from sqlalchemy import text, delete
from app.core.database_sql import async_session_factory, engine as sql_engine, Base
from app.models.user import User
from app.models.skill import Skill, UserSkill, Experience
from app.models.auth import OtpCode
from app.models.collaboration import (Project, ProjectApplication, ProjectMember,
                                      ProjectInvite, SavedItem, Task, TaskAssignee)
from app.models.chat import Message, RoomRead
from app.models.social import (Showcase, ShowcaseLike, ShowcaseComment, ProjectFile,
                               Connection, Notification, DeviceToken)

# ─── CONFIG ───────────────────────────────────────────────────────────────────

PASSWORD_HASH = bcrypt.hashpw(b"uhn2025", bcrypt.gensalt()).decode("utf-8")
NOW = datetime.now(timezone.utc)

FACULTIES_AND_MAJORS = {
    "Sekolah Vokasi": [
        "D-4 Teknik Informatika", "D-4 Akuntansi Sektor Publik", "D-4 Kebidanan",
        "D-3 Akuntansi", "D-3 DKV", "D-3 Farmasi", "D-3 Keperawatan",
        "D-3 Perhotelan", "D-3 Teknik Elektronika", "D-3 Teknik Komputer",
        "D-3 Teknik Mesin", "Profesi Bidan",
    ],
    "Fakultas Sains & Teknologi": [
        "S-1 Teknik Informatika", "S-1 Sistem Informasi", "S-1 Sains Data", "S-1 Teknik Mesin",
    ],
    "Fakultas Sosial Humaniora": [
        "S-1 Akuntansi", "S-1 Hukum", "S-1 Ilmu Komunikasi", "S-1 Manajemen",
    ],
    "Fakultas Psikologi & Pendidikan": [
        "S-1 Psikologi", "S-1 PGSD",
    ],
}

MAJOR_CATEGORY = {
    "D-4 Teknik Informatika": "tech",
    "S-1 Teknik Informatika": "tech",
    "S-1 Sistem Informasi": "tech",
    "S-1 Sains Data": "tech",
    "D-3 Teknik Komputer": "tech",
    "D-3 Teknik Elektronika": "tech",
    "S-1 Teknik Mesin": "engineering",
    "D-3 Teknik Mesin": "engineering",
    "D-4 Akuntansi Sektor Publik": "finance",
    "D-3 Akuntansi": "finance",
    "S-1 Akuntansi": "finance",
    "S-1 Manajemen": "finance",
    "D-4 Kebidanan": "health",
    "D-3 Farmasi": "health",
    "D-3 Keperawatan": "health",
    "Profesi Bidan": "health",
    "D-3 DKV": "design",
    "D-3 Perhotelan": "hospitality",
    "S-1 Hukum": "law",
    "S-1 Ilmu Komunikasi": "communication",
    "S-1 Psikologi": "psychology",
    "S-1 PGSD": "education",
}

SKILLS_PER_MAJOR = {
    "tech": ["Python", "JavaScript", "Flutter", "React", "Node.js", "Dart", "TypeScript",
             "PostgreSQL", "Machine Learning", "Firebase", "Docker", "Git", "REST API",
             "Data Analysis", "UI/UX Design"],
    "engineering": ["AutoCAD", "SolidWorks", "Teknik Mesin", "CAD", "Mekatronika",
                    "PLC", "Robotika", "Material Teknik", "Termodinamika", "CNC"],
    "finance": ["Akuntansi", "MYOB", "Excel", "SAP", "Analisis Keuangan", "Pajak",
                "Audit", "Reporting", "Budgeting", "Financial Modeling"],
    "health": ["Keperawatan", "Farmasi", "Kebidanan", "Gizi", "Kesehatan Masyarakat",
               "Promosi Kesehatan", "Stunting", "Imunisasi", "ASI Eksklusif"],
    "design": ["Adobe Illustrator", "Adobe Photoshop", "Figma", "Canva", "Branding",
               "Typography", "Motion Graphic", "Photography", "Video Editing", "CorelDRAW"],
    "hospitality": ["Hotel Management", "Front Office", "Housekeeping", "Tourism",
                    "Event Planning", "Customer Service", "F&B Service", "Travel"],
    "law": ["Hukum Perdata", "Hukum Pidana", "Hukum Tata Negara", "Hukum Internasional",
            "Hukum Bisnis", "Hukum Acara", "Legal Drafting", "Mediasi"],
    "communication": ["Jurnalistik", "Public Relations", "Content Writing", "Copywriting",
                      "Social Media", "Photography", "Videography", "Podcast", "SEO"],
    "psychology": ["Psikologi Klinis", "Psikologi Pendidikan", "Psikometri", "Konseling",
                   "Psikologi Sosial", "Psikologi Perkembangan", "Observasi", "Wawancara"],
    "education": ["Pedagogik", "Kurikulum", "Media Pembelajaran", "Evaluasi Pendidikan",
                  "PPKN", "Matematika SD", "IPA SD", "Bahasa Indonesia", "Seni Budaya"],
}

CATEGORY_IMAGE_SEEDS = {
    "tech": ["code", "laptop", "server", "circuit", "keyboard", "monitor", "robot", "ai", "data", "tech"],
    "engineering": ["engine", "machine", "gear", "factory", "robotarm", "blueprint", "welding", "drill", "turbine", "tool"],
    "finance": ["chart", "money", "calculator", "finance", "accounting", "graph", "ledger", "bank", "coin", "report"],
    "health": ["stethoscope", "hospital", "doctor", "medicine", "health", "nurse", "patient", "clinic", "pill", "bandage"],
    "design": ["palette", "brush", "mockup", "logo", "typography", "grid", "color", "sketch", "illustration", "banner"],
    "hospitality": ["hotel", "restaurant", "travel", "resort", "pool", "suite", "lobby", "kitchen", "catering", "tour"],
    "law": ["justice", "law", "scale", "gavel", "court", "document", "statute", "contract", "rights", "verdict"],
    "communication": ["microphone", "camera", "news", "interview", "broadcast", "podcast", "press", "media", "reporter", "studio"],
    "psychology": ["mind", "brain", "therapy", "counseling", "growth", "mental", "emotion", "support", "session", "mindful"],
    "education": ["book", "classroom", "teacher", "student", "school", "lesson", "library", "reading", "knowledge", "learning"],
}

SHOWCASE_TEMPLATES = {
    "tech": [
        "Selesai ngerjain project aplikasi prediksi cuaca pake machine learning. Akurasi model mencapai 88%! Next: deploy ke production.",
        "Fullstack web app untuk manajemen inventaris laboratorium. Stack: React + Node.js + PostgreSQL. Repo udah di GitHub.",
        "Ikut hackathon 48 jam dan berhasil bikin platform donor darah darurat. Tim solid banget!",
        "Progress TA: sistem rekomendasi pemilihan jurusan berdasarkan minat dan bakat pake Collaborative Filtering.",
        "Baru selesai workshop Docker & Kubernetes. Bener-bener game changer buat deployment aplikasi!",
        "Project freelance: company profile website untuk UMKM dengan fitur CMS. NextJS + Tailwind + Sanity.",
        "Alhamdulillah sertifikasi Google Associate Cloud Engineer udah lulus!",
        "Belajar Computer Vision: bikin face recognition attendance system. Akurasi 92% dalam berbagai kondisi pencahayaan.",
        "Nemenin adik kelas belajar ngoding Flutter. Seru liat mereka mulai paham konsep state management.",
        "Menyelesaikan proyek dashboard monitoring kualitas udara real-time pake IoT + MQTT + Grafana.",
    ],
    "engineering": [
        "Praktikum perancangan mesin bubut CNC minggu ini. Hasil potongan udah mulai presisi. Puas!",
        "Desain ulang bracket komponen mesin pake SolidWorks. Optimasi berat turun 30% tanpa mengurangi strength.",
        "Kunjungan industri ke pabrik manufaktur. Banyak insight tentang penerapan lean manufacturing.",
        "Proyek akhir: alat pemilah sampah otomatis berbasis sensor. Masuk tahap uji coba.",
        "Belajar PLC (Programmable Logic Controller) untuk otomatisasi industri.",
        "Lomba robotik tingkat nasional — tim kami masuk 10 besar! Tahun depan target juara.",
        "Workshop pengelasan dan fabrikasi logam. Skill baru buat bekal industri.",
    ],
    "finance": [
        "Selesai analisis laporan keuangan perusahaan manufaktur. Rasio likuiditas dan solvabilitas dalam batas aman.",
        "Membuat aplikasi budgeting pribadi pake Excel + VBA. Fitur tracking pemasukan/pengeluaran otomatis.",
        "Magang di kantor akuntan publik. Dapet pengalaman ngurus SPT Tahunan perusahaan.",
        "Studi kasus: audit internal perusahaan ritel. Temuan: inefisiensi di supply chain sebesar 15%.",
        "Belajar financial modeling: DCF valuation untuk startup teknologi. Menarik banget!",
        "Ikut seminar perpajakan terbaru. Update UU HPP dan implikasinya buat wajib pajak.",
        "PKL di bagian keuangan pemerintahan daerah. Belajar sistem akuntansi sektor publik.",
    ],
    "health": [
        "Praktek klinik kebidanan: mendampingi 5 ibu hamil trimester 3. Alhamdulillah semua sehat.",
        "Sosialisasi stunting di desa binaan. Edukasi pentingnya 1000 HPK ke ibu-ibu.",
        "Magang di Puskesmas: belajar manajemen obat dan pelayanan farmasi komunitas.",
        "Workshop ASI Eksklusif dan MPASI. Ilmu yang sangat berguna buat bekal jadi tenaga kesehatan.",
        "Ikut program imunisasi nasional di 3 sekolah dasar. Target capaian 95%.",
        "Pelatihan kegawatdaruratan ibu hamil. Skill penting buat bidan dalam menangani komplikasi.",
        "Studi kasus: manajemen pasien DM tipe 2 dengan komplikasi. Evaluasi terapi dan outcome.",
    ],
    "design": [
        "Portfolio branding UMKM batik: logo, stationery set, dan konten Instagram. Client puas!",
        "Redesign aplikasi mobile kampus. Fokus pada improve user experience dan navigasi.",
        "Project freelance: desain kemasan produk makanan ringan. Packaging yang menarik naikin penjualan.",
        "Ikut kompetisi desain poster nasional. Tema: keberlanjutan lingkungan.",
        "Belajar motion graphic dengan After Effects. Bikin animasi explainer untuk startup.",
        "Workshop tipografi: exploration type hierarchy dan legibility. Fundamental yang sering disepelekan.",
        "Design system untuk perusahaan rintisan. Mulai dari color palette, grid, sampai komponen UI.",
    ],
    "hospitality": [
        "Praktik front office di hotel bintang 4. Belajar handling check-in/out dan guest complaint.",
        "Event planning: sukses mengkoordinasi gathering perusahaan untuk 200 peserta.",
        "Magang departemen housekeeping. Standar kebersihan hotel internasional itu detail banget!",
        "Studi banding ke resort di Bali. Belajar service excellence ala hospitality industri.",
        "Workshop F&B service: table setting, wine pairing, dan fine dining etiquette.",
        "Menyusun paket tour wisata lokal. Promosi destinasi hidden gem di daerah.",
        "Pelatihan bahasa asing untuk staff hotel (English & Japanese for hospitality).",
    ],
    "law": [
        "PKL di kantor hukum: membantu penyusunan kontrak bisnis dan legal opinion.",
        "Diskusi panel tentang UU ITE dan kebebasan berpendapat di era digital.",
        "Mengikuti moot court competition tingkat nasional. Kasus: sengketa tanah.",
        "Magang di pengadilan negeri. Melihat langsung proses persidangan pidana.",
        "Menulis artikel hukum tentang perlindungan data pribadi di Indonesia.",
        "Studi kasus: analisis putusan Mahkamah Konstitusi tentang UU Cipta Kerja.",
        "Seminar hukum: aspek legal fintech dan cryptocurrency di Indonesia.",
    ],
    "communication": [
        "Podcast episode baru: diskusi tentang literasi digital bareng dosen komunikasi. Udah di Spotify!",
        "Liputan acara Dies Natalis kampus. Wawancara rektor dan dokumentasi foto/video.",
        "Magang di radio daerah: jadi penyiar program pagi. Seru interaksi sama pendengar!",
        "Project video dokumenter: tradisi lokal yang mulai punah. Tayang di YouTube kampus.",
        "Nulis artikel feature untuk majalah kampus. Topik: fenomena FOMO di kalangan mahasiswa.",
        "Public speaking workshop buat adik-adik OSIS. Materi: teknik presentasi dan pitching.",
        "Social media campaign untuk gerakan sosial: #BersihkanPantai. Reach 50k dalam seminggu.",
    ],
    "psychology": [
        "Praktek asesmen psikologi: administrasi dan skoring tes IQ, EPPS, dan SSCT.",
        "Konseling individu: menangani klien dengan kecemasan akademik. Pendekatan CBT.",
        "Psikoedukasi kesehatan mental di SMA: stress management dan growth mindset.",
        "Observasi perkembangan anak usia dini di PAUD. Tahap perkembangan sesuai milestone.",
        "Ikut seminar nasional psikologi positif: karakter strength dan well-being.",
        "Praktikum psikometri: analisis validitas dan reliabilitas alat ukur.",
        "Menjadi asisten dosen mata kuliah psikologi sosial. Seru diskusi sama adik tingkat!",
    ],
    "education": [
        "Praktik mengajar di SD: menyampaikan materi IPA dengan metode eksperimen sederhana.",
        "Membuat media pembelajaran interaktif berbasis game untuk kelas 3 SD.",
        "Program kampus mengajar: 4 bulan di SD 3T. Pengalaman berharga banget!",
        "Workshop pembuatan soal HOTS (Higher Order Thinking Skills) buat guru SD.",
        "Observasi pembelajaran: menganalisis gaya belajar siswa kelas 1 SD.",
        "PKL di Sekolah Dasar: mendampingi siswa ABK (Anak Berkebutuhan Khusus).",
        "Seminar pendidikan: kurikulum merdeka dan implementasinya di sekolah dasar.",
    ],
}

PROJECT_TEMPLATES = [
    {"title": "Aplikasi Donor Darah Darurat", "category": "Tech", "interest": "Mobile Development",
     "description": "Platform darurat untuk mencari pendonor darah terdekat. Fitur real-time tracking dan notifikasi.", "skills": ["Flutter", "Firebase", "Dart"], "cat": "tech"},
    {"title": "Sistem Informasi BUMDes", "category": "Tech", "interest": "Web Development",
     "description": "Digitalisasi administrasi dan laporan keuangan Badan Usaha Milik Desa.", "skills": ["React", "Node.js", "PostgreSQL"], "cat": "tech"},
    {"title": "Dashboard Monitoring IoT", "category": "Tech", "interest": "Data Science",
     "description": "Dashboard real-time untuk monitoring sensor lingkungan berbasis IoT.", "skills": ["Python", "Grafana", "MQTT", "Docker"], "cat": "tech"},
    {"title": "Aplikasi Koperasi Digital", "category": "Business", "interest": "Akuntansi",
     "description": "Manajemen simpan pinjam koperasi dengan laporan keuangan otomatis.", "skills": ["Flutter", "Dart", "Firebase", "Accounting"], "cat": "finance"},
    {"title": "Platform Crowdfunding UMKM", "category": "Business", "interest": "Manajemen",
     "description": "Crowdfunding untuk UMKM lokal dengan sistem reward-based funding.", "skills": ["React", "TypeScript", "Stripe", "Node.js"], "cat": "finance"},
    {"title": "Aplikasi Antrian Puskesmas", "category": "Health", "interest": "Keperawatan",
     "description": "Sistem antrian online untuk puskesmas dengan estimasi waktu tunggu.", "skills": ["Flutter", "Kotlin", "Firebase"], "cat": "health"},
    {"title": "Edukasi Stunting Interaktif", "category": "Health", "interest": "Kebidanan",
     "description": "Aplikasi edukasi gizi dan pencegahan stunting untuk ibu hamil.", "skills": ["Flutter", "Firebase", "UI/UX"], "cat": "health"},
    {"title": "Branding Wisata Desa", "category": "Design", "interest": "Desain Grafis",
     "description": "Branding kit dan media promosi untuk desa wisata.", "skills": ["Figma", "Adobe Illustrator", "Branding", "Photography"], "cat": "design"},
    {"title": "Company Profile Multimedia", "category": "Design", "interest": "Multimedia",
     "description": "Company profile interaktif untuk perusahaan rintisan. Video + microsite.", "skills": ["Premiere Pro", "After Effects", "Figma", "Webflow"], "cat": "design"},
    {"title": "Sistem Reservasi Hotel", "category": "Tech", "interest": "Perhotelan",
     "description": "Platform booking kamar hotel dengan manajemen inventory.", "skills": ["React", "Django", "PostgreSQL"], "cat": "hospitality"},
    {"title": "E-Learning Bahasa Isyarat", "category": "Education", "interest": "Pendidikan",
     "description": "Platform belajar bahasa isyarat dengan video interaktif dan kuis.", "skills": ["React", "TypeScript", "Tailwind", "Node.js"], "cat": "education"},
    {"title": "Game Edukasi Literasi SD", "category": "Education", "interest": "Pendidikan",
     "description": "Game pembelajaran membaca dan menulis untuk siswa kelas 1-3 SD.", "skills": ["Unity", "C#", "Game Design"], "cat": "education"},
    {"title": "Kampanye Sadar Hukum Digital", "category": "Social", "interest": "Hukum",
     "description": "Edukasi publik tentang etika dan hukum di dunia digital melalui media sosial.", "skills": ["Content Writing", "Canva", "Social Media"], "cat": "law"},
    {"title": "Aplikasi Konseling Psikologi", "category": "Health", "interest": "Psikologi",
     "description": "Platform konseling online dengan fitur jadwal dan chat.", "skills": ["Flutter", "Node.js", "Firebase", "MongoDB"], "cat": "psychology"},
    {"title": "Media Sosial Kampanye Lingkungan", "category": "Social", "interest": "Ilmu Komunikasi",
     "description": "Kampanye #BersihPantai via Instagram, TikTok, dan podcast.", "skills": ["Copywriting", "Videography", "Public Speaking"], "cat": "communication"},
    {"title": "Sistem Pakar Diagnosa Tanaman", "category": "Tech", "interest": "Data Science",
     "description": "Deteksi penyakit tanaman padi dari gambar daun menggunakan CNN.", "skills": ["Python", "TensorFlow", "Computer Vision", "Flask"], "cat": "tech"},
    {"title": "Dashboard Keuangan Daerah", "category": "Business", "interest": "Akuntansi",
     "description": "Visualisasi APBD untuk transparansi publik.", "skills": ["React", "Chart.js", "Python", "Node.js"], "cat": "finance"},
    {"title": "Rancang Bangun Mesin Pencacah", "category": "Engineering", "interest": "Teknik Mesin",
     "description": "Perancangan dan pembuatan mesin pencacah sampah organik skala rumah tangga.", "skills": ["AutoCAD", "SolidWorks", "Teknik Mesin"], "cat": "engineering"},
    {"title": "Aplikasi Psikotes Online", "category": "Education", "interest": "Psikologi",
     "description": "Platform asesmen psikologi untuk seleksi dan penjurusan.", "skills": ["Laravel", "MySQL", "JavaScript"], "cat": "psychology"},
    {"title": "Sistem Informasi Desa", "category": "Tech", "interest": "Web Development",
     "description": "Aplikasi pelayanan administrasi desa berbasis web.", "skills": ["PHP", "Laravel", "PostgreSQL"], "cat": "tech"},
]

FIRST_NAMES = [
    "Ahmad", "Rizky", "Fajar", "Bayu", "Dian", "Eko", "Gilang", "Hendra",
    "Indra", "Joko", "Kevin", "Lingga", "Miftah", "Nanda", "Oka", "Panji",
    "Rafi", "Sandi", "Teguh", "Vito", "Wahyu", "Xaverius", "Yogi", "Zaki",
    "Siti", "Dinda", "Citra", "Fitri", "Hana", "Kartika", "Mega", "Olivia",
    "Putri", "Qeisya", "Ratna", "Sari", "Tiara", "Umi", "Wulan", "Yuni",
    "Anggi", "Bunga", "Dewi", "Farah", "Gita", "Hesti", "Intan", "Jihan",
    "Kiki", "Lina", "Nurul", "Cahya", "Restu", "Doni", "Agus", "Ilham",
    "Dimas", "Adit", "Rangga", "Arif",
]

LAST_NAMES = [
    "Pratama", "Maulana", "Wijaya", "Saputra", "Ramadhan", "Kusuma",
    "Hermawan", "Sudirman", "Santoso", "Siregar", "Nugraha", "Purnama",
    "Lestari", "Pertiwi", "Utami", "Wulandari", "Hidayat", "Firmansyah",
    "Setiawan", "Susilo", "Amalia", "Rahmawati", "Hakim", "Syahputra",
    "Gunawan", "Wahyuni", "Marlina", "Salsabila", "Mandala", "Chandra",
]


# ─── GENERATORS ───────────────────────────────────────────────────────────────

FIRST_NAME_IDX = 0
LAST_NAME_IDX = 0


def _next_name() -> tuple[str, str]:
    global FIRST_NAME_IDX, LAST_NAME_IDX
    fn = FIRST_NAMES[FIRST_NAME_IDX % len(FIRST_NAMES)]
    ln = LAST_NAMES[LAST_NAME_IDX % len(LAST_NAMES)]
    FIRST_NAME_IDX += 1
    LAST_NAME_IDX += 1
    return fn, ln


def generate_users() -> list[dict]:
    name_pool = FIRST_NAMES + LAST_NAMES  # fallback
    users = []
    nim = 24010101

    distribution = [
        ("Sekolah Vokasi", [
            ("D-4 Teknik Informatika", 4), ("D-4 Akuntansi Sektor Publik", 3),
            ("D-4 Kebidanan", 2), ("D-3 Akuntansi", 3), ("D-3 DKV", 2),
            ("D-3 Farmasi", 2), ("D-3 Keperawatan", 2), ("D-3 Perhotelan", 2),
            ("D-3 Teknik Elektronika", 2), ("D-3 Teknik Komputer", 2),
            ("D-3 Teknik Mesin", 2), ("Profesi Bidan", 2),
        ]),
        ("Fakultas Sains & Teknologi", [
            ("S-1 Teknik Informatika", 4), ("S-1 Sistem Informasi", 4),
            ("S-1 Sains Data", 3), ("S-1 Teknik Mesin", 3),
        ]),
        ("Fakultas Sosial Humaniora", [
            ("S-1 Akuntansi", 4), ("S-1 Hukum", 4),
            ("S-1 Ilmu Komunikasi", 3), ("S-1 Manajemen", 3),
        ]),
        ("Fakultas Psikologi & Pendidikan", [
            ("S-1 Psikologi", 7), ("S-1 PGSD", 7),
        ]),
    ]

    for faculty, majors in distribution:
        for major, count in majors:
            for _ in range(count):
                fn, ln = _next_name()
                full_name = f"{fn} {ln}"
                users.append({
                    "nim": str(nim),
                    "full_name": full_name,
                    "faculty": faculty,
                    "major": major,
                    "category": MAJOR_CATEGORY.get(major, "tech"),
                })
                nim += 1

    random.shuffle(users)
    return users


def pick_image(category: str, index: int) -> list[str]:
    seeds = CATEGORY_IMAGE_SEEDS.get(category, CATEGORY_IMAGE_SEEDS["tech"])
    s = seeds[index % len(seeds)]
    return [
        f"https://picsum.photos/seed/{s}{index}/400/300",
        f"https://picsum.photos/seed/{s}{index}b/400/300",
    ]


# ─── SEED ──────────────────────────────────────────────────────────────────────

async def seed():
    async with async_session_factory() as session:
        # 0. Pastikan tabel ada (untuk DB fresh / Supabase)
        try:
            async with sql_engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
        except Exception as e:
            print(f"  ℹ️  create_all: {e}")

        # 1. Cari user yang dilindungi
        print("🔍 Mencari user yang dilindungi...")
        result = await session.execute(
            text('SELECT id, full_name FROM "User" WHERE full_name IN (:n1, :n2)'),
            {"n1": "Ahmad Saifi Khayatu Ulumuddin", "n2": "Dede Fjkgj"},
        )
        protected = {row.full_name: row.id for row in result.fetchall()}

        if not protected:
            print("  ⚠️  User dilindungi tidak ditemukan — akan lanjut seed tanpa melindungi siapa pun.")
        else:
            for name, uid in protected.items():
                print(f"  ✓ {name} — id={uid}")

        # 2. Hapus semua data kecuali user dilindungi
        print("🧹 Menghapus data lama (kecuali user dilindungi)...")
        if protected:
            tables = [
                "TaskAssignee", "Task", "ProjectFile", "ProjectInvite", "SavedItem",
                "ShowcaseComment", "ShowcaseLike", "Showcase", "Connection",
                "Notification", "Message", "RoomRead",
                "ProjectApplication", "ProjectMember", "Project",
                "Experience", "UserSkill", "Skill", "OtpCode",
            ]
            for tbl in tables:
                try:
                    await session.execute(text(f'DELETE FROM "{tbl}"'))
                except Exception as e:
                    if "does not exist" in str(e):
                        continue
                    raise e

            protected_ids = list(protected.values())
            placeholders = ", ".join(f"'{uid}'" for uid in protected_ids)
            await session.execute(text(f'DELETE FROM "User" WHERE id NOT IN ({placeholders})'))
            await session.commit()
            print("  ✓ Semua data lama berhasil dibersihkan.")
        else:
            print("  ⚠️  User dilindungi tidak ditemukan — database kosong, lewati delete.")

        # 3. Generate & create 70 users
        print("👤 Membuat 70 user dummy...")
        users_data = generate_users()
        created_users = []
        photo_urls = []

        for u in users_data:
            uid = str(uuid.uuid4())
            user = User(
                id=uid,
                nim=u["nim"],
                full_name=u["full_name"],
                faculty=u["faculty"],
                major=u["major"],
                password=PASSWORD_HASH,
                email_verified=True,
                is_onboarded=True,
                photo_url=f"https://i.pravatar.cc/150?u={u['nim']}",
                cover_url=f"https://picsum.photos/seed/cover{u['nim']}/1200/400",
                created_at=NOW,
                updated_at=NOW,
            )
            session.add(user)
            created_users.append({**u, "id": uid})

        await session.commit()
        print(f"  ✓ {len(created_users)} user berhasil dibuat.")

        # 3b. Admin user
        admin_pw = bcrypt.hashpw(b"katasandi98", bcrypt.gensalt()).decode("utf-8")
        admin = User(
            id=str(uuid.uuid4()),
            email="admin@rembugan.com",
            full_name="Admin Rembugan",
            password=admin_pw,
            email_verified=True,
            is_onboarded=True,
            is_admin=True,
            created_at=NOW,
            updated_at=NOW,
        )
        session.add(admin)
        await session.commit()
        print("  👑 Admin: admin@rembugan.com / katasandi98")

        # 4. Skills
        print("🏷️  Membuat skills...")
        all_skill_names = set()
        for cat, skills in SKILLS_PER_MAJOR.items():
            for s in skills:
                all_skill_names.add(s)

        skill_records = {}
        for sname in sorted(all_skill_names):
            existing = await session.execute(
                text('SELECT id FROM "Skill" WHERE name = :n'), {"n": sname}
            )
            row = existing.fetchone()
            if row:
                skill_records[sname] = row[0]
            else:
                skill = Skill(name=sname)
                session.add(skill)
                await session.flush()
                skill_records[sname] = skill.id

        await session.commit()

        # 5. Assign skills ke user based on major category
        print("🔗 Assign skills ke user...")
        for u in created_users:
            cat = u["category"]
            pool = SKILLS_PER_MAJOR.get(cat, SKILLS_PER_MAJOR["tech"])
            chosen = random.sample(pool, min(4, len(pool)))
            for sname in chosen:
                session.add(UserSkill(
                    user_id=u["id"],
                    skill_id=skill_records[sname],
                ))

        await session.commit()

        # 6. Create projects
        print("📁 Membuat project...")
        project_records = []
        project_owner_map = {}  # project_index -> user

        for i, pt in enumerate(PROJECT_TEMPLATES):
            cat = pt["cat"]
            candidates = [u for u in created_users if u["category"] == cat]
            if not candidates:
                candidates = created_users
            owner = random.choice(candidates)

            project = Project(
                owner_id=owner["id"],
                title=pt["title"],
                description=pt["description"],
                required_skills=pt["skills"],
                status=random.choice(["open", "ongoing", "completed"]),
                category=pt["category"],
                    total_slots=random.randint(3, 6),
                deadline=NOW + timedelta(days=random.randint(14, 60)),
                created_at=NOW - timedelta(days=random.randint(1, 30)),
            )
            session.add(project)
            await session.flush()
            project_records.append(project)
            project_owner_map[i] = owner

        await session.commit()
        print(f"  ✓ {len(project_records)} project berhasil dibuat.")

        # 7. Project members (+ tasks)
        print("👥 Menambahkan anggota & tasks ke project...")
        for i, project in enumerate(project_records):
            owner = project_owner_map[i]

            session.add(ProjectMember(project_id=project.id, user_id=owner["id"], role="Ketua"))

            candidates = [u for u in created_users if u["id"] != owner["id"]]
            members = random.sample(candidates, min(random.randint(1, 3), len(candidates)))
            for m in members:
                session.add(ProjectMember(project_id=project.id, user_id=m["id"], role="Anggota"))

            for t in range(random.randint(3, 5)):
                task = Task(
                    project_id=project.id,
                    title=f"Task {t+1}: {random.choice(['Desain', 'Backend', 'Frontend', 'Testing', 'Deploy', 'Dokumentasi'])}",
                    status=random.choice(["todo", "doing", "done"]),
                    deadline=NOW + timedelta(days=random.randint(1, 30)),
                    created_at=NOW - timedelta(days=random.randint(1, 15)),
                )
                session.add(task)
                await session.flush()

                assignee = random.choice(members + [owner])
                session.add(TaskAssignee(task_id=task.id, user_id=assignee["id"]))

        await session.commit()

        # 8. Showcases
        print("📸 Membuat showcase...")
        showcase_records = []

        for i, u in enumerate(created_users):
            cat = u["category"]
            templates = SHOWCASE_TEMPLATES.get(cat, SHOWCASE_TEMPLATES["tech"])
            num_showcases = random.choices([1, 2, 3], weights=[5, 3, 1])[0]

            for j in range(num_showcases):
                content = random.choice(templates)
                tags = content.lower().split()[:3]
                tags = [t.strip(".,!?") for t in tags if len(t) > 3][:3]

                img_idx = (i * 3 + j) * 2
                images = pick_image(cat, img_idx)

                sid = hashlib.md5(f"showcase-v2-{i}-{j}".encode()).hexdigest()[:12]

                linked_project = None
                if random.random() < 0.3 and project_records:
                    linked_project = random.choice(project_records)

                showcase = Showcase(
                    id=sid,
                    author_id=u["id"],
                    content=content,
                    media_urls=images,
                    tags=tags,
                    linked_project_id=linked_project.id if linked_project else None,
                    created_at=NOW - timedelta(days=random.randint(0, 60)),
                )
                session.add(showcase)
                showcase_records.append(showcase)

        await session.commit()
        print(f"  ✓ {len(showcase_records)} showcase berhasil dibuat.")

        # 9. Likes
        print("❤️ Menambahkan likes...")
        all_user_ids = [u["id"] for u in created_users]
        for showcase in showcase_records:
            likers = random.sample(all_user_ids, min(random.randint(2, 6), len(all_user_ids)))
            for liker_id in likers:
                if liker_id != showcase.author_id:
                    session.add(ShowcaseLike(showcase_id=showcase.id, user_id=liker_id))

        await session.commit()

        # 10. Comments
        print("💬 Menambahkan komentar...")
        comment_templates = [
            "Keren banget hasilnya! 🎉", "Mantap, lanjutkan!",
            "Boleh minta source code-nya kak?", "Semoga sukses terus!",
            "Inspiratif banget!", "Wah kapan-kapan sharing dong!",
            "Ditunggu project selanjutnya!", "Kelas banget ini! 💪",
            "Salut sama dedikasinya!", "Boleh join tim? 😄",
        ]
        for showcase in showcase_records:
            num_comments = random.randint(0, 3)
            for _ in range(num_comments):
                commenter = random.choice(all_user_ids)
                cm = ShowcaseComment(
                    showcase_id=showcase.id,
                    user_id=commenter,
                    content=random.choice(comment_templates),
                    created_at=NOW - timedelta(days=random.randint(0, 10)),
                )
                session.add(cm)

        await session.commit()

        # 11. Connections
        print("🔗 Membuat koneksi antar user...")
        num_connections = min(80, len(all_user_ids) * 2)
        made = set()
        attempts = 0
        while len(made) < num_connections and attempts < 200:
            a = random.choice(all_user_ids)
            b = random.choice(all_user_ids)
            if a == b:
                attempts += 1
                continue
            key = tuple(sorted((a, b)))
            if key in made:
                attempts += 1
                continue
            session.add(Connection(sender_id=a, receiver_id=b, status="accepted"))
            made.add(key)
            attempts = 0

        await session.commit()
        print(f"  ✓ {len(made)} koneksi berhasil dibuat.")

        print("\n✅ Seed selesai!")
        print(f"   - {len(created_users)} user dummy + {len(protected)} user dilindungi")
        print(f"   - {len(project_records)} project")
        print(f"   - {len(showcase_records)} showcase")
        print(f"   - Password: uhn2025")
        print(f"   - Login pakai NIM")


if __name__ == "__main__":
    asyncio.run(seed())
