#!/usr/bin/env python3
"""Seed script untuk Universitas Harkat Negeri — 50 mahasiswa + 15 project + 30 showcase"""

import asyncio
import hashlib
import random
from datetime import datetime, timedelta, timezone
import bcrypt

from prisma import Prisma

PASSWORD_HASH = bcrypt.hashpw(b"uhn2025", bcrypt.gensalt()).decode("utf-8")
NOW = datetime.now(timezone.utc)

USERS = [
    # Sekolah Vokasi (17)
    {"nim": "23090101", "full_name": "Ahmad Maulana", "faculty": "Sekolah Vokasi", "major": "D-4 Teknik Informatika"},
    {"nim": "23090102", "full_name": "Siti Nurjanah", "faculty": "Sekolah Vokasi", "major": "D-4 Teknik Informatika"},
    {"nim": "23090103", "full_name": "Rizky Pratama", "faculty": "Sekolah Vokasi", "major": "D-4 Teknik Informatika"},
    {"nim": "23090104", "full_name": "Dinda Permata Sari", "faculty": "Sekolah Vokasi", "major": "D-4 Teknik Informatika"},
    {"nim": "23090105", "full_name": "Fajar Ramadhan", "faculty": "Sekolah Vokasi", "major": "D-4 Teknik Informatika"},
    {"nim": "23110101", "full_name": "Bayu Aji", "faculty": "Sekolah Vokasi", "major": "D-4 Akuntansi Sektor Publik"},
    {"nim": "23110102", "full_name": "Citra Lestari", "faculty": "Sekolah Vokasi", "major": "D-4 Akuntansi Sektor Publik"},
    {"nim": "23110103", "full_name": "Dian Puspita", "faculty": "Sekolah Vokasi", "major": "D-4 Akuntansi Sektor Publik"},
    {"nim": "23120101", "full_name": "Eko Wahyudi", "faculty": "Sekolah Vokasi", "major": "D-4 Kebidanan"},
    {"nim": "23120102", "full_name": "Fitriani", "faculty": "Sekolah Vokasi", "major": "D-4 Kebidanan"},
    {"nim": "23130101", "full_name": "Gilang Saputra", "faculty": "Sekolah Vokasi", "major": "D-3 Akuntansi"},
    {"nim": "23130102", "full_name": "Hana Safira", "faculty": "Sekolah Vokasi", "major": "D-3 Akuntansi"},
    {"nim": "23130103", "full_name": "Indra Kusuma", "faculty": "Sekolah Vokasi", "major": "D-3 Akuntansi"},
    {"nim": "23150101", "full_name": "Joko Susilo", "faculty": "Sekolah Vokasi", "major": "D-3 DKV"},
    {"nim": "23150102", "full_name": "Kartika Sari", "faculty": "Sekolah Vokasi", "major": "D-3 DKV"},
    {"nim": "23170101", "full_name": "Lingga Pratama", "faculty": "Sekolah Vokasi", "major": "D-3 Farmasi"},
    {"nim": "23190101", "full_name": "Mega Wati", "faculty": "Sekolah Vokasi", "major": "D-3 Keperawatan"},
    {"nim": "23210101", "full_name": "Nanda Pramudya", "faculty": "Sekolah Vokasi", "major": "D-3 Perhotelan"},
    {"nim": "23230101", "full_name": "Olivia Rahmawati", "faculty": "Sekolah Vokasi", "major": "D-3 Teknik Elektronika"},
    {"nim": "23290101", "full_name": "Panji Wirawan", "faculty": "Sekolah Vokasi", "major": "D-3 Teknik Komputer"},
    {"nim": "23290102", "full_name": "Qori Amalia", "faculty": "Sekolah Vokasi", "major": "D-3 Teknik Komputer"},
    {"nim": "23270101", "full_name": "Rafi Ahmad", "faculty": "Sekolah Vokasi", "major": "D-3 Teknik Mesin"},
    {"nim": "23070101", "full_name": "Sari Dewanti", "faculty": "Sekolah Vokasi", "major": "Profesi Bidan"},
    {"nim": "23070102", "full_name": "Teguh Santoso", "faculty": "Sekolah Vokasi", "major": "Profesi Bidan"},
    # Fakultas Sains & Teknologi (10)
    {"nim": "23350101", "full_name": "Umi Kalsum", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Teknik Informatika"},
    {"nim": "23350102", "full_name": "Vito Aditya", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Teknik Informatika"},
    {"nim": "23350103", "full_name": "Wulan Sari", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Teknik Informatika"},
    {"nim": "23330101", "full_name": "Xaverius Dhimas", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Sistem Informasi"},
    {"nim": "23330102", "full_name": "Yuni Astuti", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Sistem Informasi"},
    {"nim": "23330103", "full_name": "Zaki Firmansyah", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Sistem Informasi"},
    {"nim": "23410101", "full_name": "Anggi Pratiwi", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Sains Data"},
    {"nim": "23410102", "full_name": "Bambang Hermawan", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Sains Data"},
    {"nim": "23430101", "full_name": "Chandra Wijaya", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Teknik Mesin"},
    {"nim": "23430102", "full_name": "Dewi Lestari", "faculty": "Fakultas Sains & Teknologi", "major": "S-1 Teknik Mesin"},
    # Fakultas Sosial Humaniora (10)
    {"nim": "23450101", "full_name": "Erwin Pratama", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Akuntansi"},
    {"nim": "23450102", "full_name": "Farah Diba", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Akuntansi"},
    {"nim": "23450103", "full_name": "Gunawan", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Akuntansi"},
    {"nim": "23370101", "full_name": "Hesti Purnama", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Hukum"},
    {"nim": "23370102", "full_name": "Irfan Hakim", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Hukum"},
    {"nim": "23370103", "full_name": "Jihan Salsabila", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Hukum"},
    {"nim": "23470101", "full_name": "Kevin Alexander", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Ilmu Komunikasi"},
    {"nim": "23470102", "full_name": "Lina Marlina", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Ilmu Komunikasi"},
    {"nim": "23490101", "full_name": "Miftahul Jannah", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Manajemen"},
    {"nim": "23490102", "full_name": "Noprianto", "faculty": "Fakultas Sosial Humaniora", "major": "S-1 Manajemen"},
    # Fakultas Psikologi & Pendidikan (6)
    {"nim": "23390101", "full_name": "Oka Saputra", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 Psikologi"},
    {"nim": "23390102", "full_name": "Putri Ayu", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 Psikologi"},
    {"nim": "23390103", "full_name": "Qeisya Amara", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 Psikologi"},
    {"nim": "23250101", "full_name": "Ratna Dewi", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 PGSD"},
    {"nim": "23250102", "full_name": "Sandi Maulana", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 PGSD"},
    {"nim": "23250103", "full_name": "Tiara Maharani", "faculty": "Fakultas Psikologi & Pendidikan", "major": "S-1 PGSD"},
]

PROJECTS = [
    {"title": "Aplikasi Absensi QR Kampus", "description": "Membangun sistem absensi digital berbasis QR code untuk lingkup kampus.", "category": "Tech", "interest": "Mobile Development", "total_slots": 4, "owner_idx": 0, "status": "completed", "required_skills": ["Flutter", "Firebase", "Dart"]},
    {"title": "Sistem Informasi Perpustakaan", "description": "Digitalisasi layanan perpustakaan dengan fitur peminjaman dan katalog online.", "category": "Tech", "interest": "Web Development", "total_slots": 3, "owner_idx": 27, "status": "ongoing", "required_skills": ["Laravel", "MySQL", "PHP"]},
    {"title": "Kampanye Sadar Hukum Digital", "description": "Edukasi publik tentang etika dan hukum di dunia digital melalui media sosial.", "category": "Social", "interest": "Hukum", "total_slots": 5, "owner_idx": 36, "status": "open", "required_skills": ["Content Writing", "Social Media", "Canva"]},
    {"title": "Media Pembelajaran Interaktif SD", "description": "Membuat media ajar berbasis game untuk siswa SD kelas 1-3.", "category": "Education", "interest": "Pendidikan", "total_slots": 4, "owner_idx": 47, "status": "ongoing", "required_skills": ["Unity", "C#", "Game Design"]},
    {"title": "Aplikasi Monitoring Posyandu", "description": "Sistem pencatatan tumbuh kembang balita untuk posyandu terintegrasi.", "category": "Health", "interest": "Keperawatan", "total_slots": 3, "owner_idx": 16, "status": "completed", "required_skills": ["Kotlin", "Firebase", "Android"]},
    {"title": "Website E-Commerce Batik Tegal", "description": "Platform penjualan batik khas Tegal dengan fitur katalog dan payment gateway.", "category": "Business", "interest": "Web Development", "total_slots": 4, "owner_idx": 19, "status": "ongoing", "required_skills": ["React", "Node.js", "Tailwind", "MongoDB"]},
    {"title": "Analisis Sentimen UMKM", "description": "Mengolah data review pelanggan UMKM untuk rekomendasi peningkatan layanan.", "category": "Tech", "interest": "Data Science", "total_slots": 5, "owner_idx": 25, "status": "open", "required_skills": ["Python", "Pandas", "Machine Learning", "Jupyter"]},
    {"title": "Branding Wisata Kuliner Tegal", "description": "Kampanye branding digital potensi wisata kuliner di Kabupaten Tegal.", "category": "Design", "interest": "Desain Komunikasi Visual", "total_slots": 4, "owner_idx": 13, "status": "completed", "required_skills": ["Figma", "Adobe Illustrator", "Branding"]},
    {"title": "Aplikasi Reservasi Hotel", "description": "Sistem reservasi hotel berbasis mobile untuk industri perhotelan lokal.", "category": "Tech", "interest": "Mobile Development", "total_slots": 5, "owner_idx": 17, "status": "open", "required_skills": ["Flutter", "Dart", "Firebase"]},
    {"title": "Sistem Pakar Deteksi Stunting", "description": "Aplikasi berbasis aturan untuk deteksi dini risiko stunting pada balita.", "category": "Health", "interest": "Farmasi", "total_slots": 4, "owner_idx": 15, "status": "ongoing", "required_skills": ["Python", "Flask", "PostgreSQL"]},
    {"title": "Dashboard Data Akademik", "description": "Visualisasi data akademik mahasiswa untuk monitoring kinerja prodi.", "category": "Tech", "interest": "Data Science", "total_slots": 5, "owner_idx": 29, "status": "open", "required_skills": ["React", "TypeScript", "Chart.js", "Node.js"]},
    {"title": "Psikotes Online untuk MBKM", "description": "Platform asesmen psikologi online untuk program MBKM dan magang.", "category": "Education", "interest": "Psikologi", "total_slots": 4, "owner_idx": 40, "status": "completed", "required_skills": ["Laravel", "MySQL", "JavaScript"]},
    {"title": "Aplikasi Keuangan Pribadi", "description": "Aplikasi pencatatan keuangan pribadi dengan fitur budgeting dan laporan.", "category": "Business", "interest": "Akuntansi", "total_slots": 5, "owner_idx": 31, "status": "open", "required_skills": ["Flutter", "Dart", "Firebase"]},
    {"title": "E-Learning Bahasa Isyarat", "description": "Platform pembelajaran bahasa isyarat berbasis video interaktif.", "category": "Education", "interest": "Ilmu Komunikasi", "total_slots": 4, "owner_idx": 38, "status": "ongoing", "required_skills": ["React", "TypeScript", "Tailwind", "PostgreSQL"]},
    {"title": "Sistem Antrian Puskesmas Digital", "description": "Aplikasi pengambilan nomor antrian online untuk puskesmas.", "category": "Tech", "interest": "Teknik Mesin", "total_slots": 5, "owner_idx": 34, "status": "open", "required_skills": ["Flutter", "Dart", "Firebase"]},
]

SHOWCASES = [
    # Linked to completed projects (15)
    {"content": "Alhamdulillah, aplikasi absensi QR kampus akhirnya selesai! Fitur scan QR, rekap kehadiran real-time, dan export laporan. Terima kasih tim!", "tags": ["absensi", "mobile", "flutter"], "owner_idx": 0, "linked_project_idx": 0},
    {"content": "Proyek monitoring posyandu udah launching! Sekarang bidan bisa catat tumbuh kembang balita secara digital. Next: integrasi dengan e-Kohort.", "tags": ["posyandu", "healthtech", "mobile"], "owner_idx": 16, "linked_project_idx": 4},
    {"content": "Branding wisata kuliner Tegal — final design kit udah jadi! Logo, mockup booth, dan konten IG. Bangga banget sama hasil tim.", "tags": ["design", "branding", "kuliner"], "owner_idx": 13, "linked_project_idx": 7},
    {"content": "Psikotes Online MBKM — platform udah live dan dipakai oleh 200+ mahasiswa! Fitur asesmen minat, bakat, dan kepribadian.", "tags": ["psikologi", "mbkm", "web"], "owner_idx": 40, "linked_project_idx": 11},
    {"content": "Portfolio project — aplikasi keuangan pribadi. Fitur tracking pemasukan-pengeluaran, kategori otomatis, dan target nabung.", "tags": ["fintech", "mobile", "flutter"], "owner_idx": 31, "linked_project_idx": 12},
    # Linked to ongoing projects (5)
    {"content": "Progress SI Perpustakaan — UI dashboard admin udah selesai. Tinggal integrasi backend untuk fitur peminjaman.", "tags": ["library", "webapp", "ui"], "owner_idx": 27, "linked_project_idx": 1},
    {"content": "Media pembelajaran interaktif — prototype 3 game edukasi untuk SD kelas 1 udah jadi. Ujicoba minggu depan!", "tags": ["education", "game", "interactive"], "owner_idx": 47, "linked_project_idx": 3},
    {"content": "E-Commerce Batik Tegal — progress 60%. Katalog produk, keranjang, dan checkout udal. Next: payment gateway.", "tags": ["ecommerce", "batik", "web"], "owner_idx": 19, "linked_project_idx": 5},
    {"content": "Sistem pakar deteksi stunting — basis pengetahuan dari 3 dokter anak udah siap. Tinggal testing aplikasi.", "tags": ["health", "expert-system", "ai"], "owner_idx": 15, "linked_project_idx": 9},
    {"content": "E-Learning Bahasa Isyarat — 20 video pembelajaran udah diproduksi. Kolaborasi dengan teman-teman dari prodi Ilkom.", "tags": ["education", "signlanguage", "video"], "owner_idx": 38, "linked_project_idx": 13},
    # Standalone showcases (10)
    {"content": "Ikut seminar nasional \"Hukum Digital di Era AI\" kemarin. Banyak insight tentang perlindungan data pribadi.", "tags": ["seminar", "hukum", "digital"], "owner_idx": 36, "linked_project_idx": None},
    {"content": "Alhamdulillah lolos pendanaan PKM 2025! Proposal tentang aplikasi deteksi dini stunting. Gaskeun!", "tags": ["pkm", "dikit", "prestasi"], "owner_idx": 15, "linked_project_idx": None},
    {"content": "Portfolio design untuk UKM batik Tegal — logo, banner, dan konten IG. Coba cek hasilnya di link!", "tags": ["design", "batik", "portfolio"], "owner_idx": 14, "linked_project_idx": None},
    {"content": "Selesai magang di startup edtech selama 3 bulan. Dapet banyak pengalaman tentang product management.", "tags": ["magang", "edtech", "pengalaman"], "owner_idx": 5, "linked_project_idx": None},
    {"content": "Baru aja selesai baca \"Atomic Habits\" — highly recommended buat yang pengen produktif ngerjain tugas akhir!", "tags": ["buku", "selfimprovement", "tugasakhir"], "owner_idx": 41, "linked_project_idx": None},
    {"content": "Ikut lomba karya tulis ilmiah nasional dan dapet juara 3! Topik: Efektivitas game edukasi untuk literasi anak SD.", "tags": ["lomba", "karya-tulis", "prestasi"], "owner_idx": 47, "linked_project_idx": None},
    {"content": "Menjadi fasilitator di workshop UI/UX kampus kemarin. Seru banget liat adik-adik semangat belajar design!", "tags": ["workshop", "uiux", "fasilitator"], "owner_idx": 1, "linked_project_idx": None},
    {"content": "Tim kami juara 2 Gemastik cabang Keamanan Siber! Perjuangan 3 bulan ga sia-sia.", "tags": ["gemastik", "cyber", "juara"], "owner_idx": 2, "linked_project_idx": None},
    {"content": "Buka kelas gratis desain grafis untuk adik-adik pesantren. Seru banget bagi ilmu!", "tags": ["volunteer", "design", "pesantren"], "owner_idx": 14, "linked_project_idx": None},
    {"content": "Akhirnya sidang TA lancar! Topik: Sistem prediksi kelulusan mahasiswa menggunakan machine learning.", "tags": ["ta", "sidang", "machinelearning"], "owner_idx": 25, "linked_project_idx": None},
]

COMMENTS_DATA = {
    # Format: showcase_idx -> [(user_idx, content, parent_idx)]
    0: [(1, "Mantap bang! Keren banget hasilnya 🎉", None), (2, "Kapan bisa dipake buat kampus kita?", None)],
    3: [(41, "Platformnya keren banget! Udah dipake berapa mahasiswa?", None)],
    4: [(32, "Fitur budgetingnya lengkap juga?", None), (31, "Iya, ada tracking per kategori dan target nabung", 2)],
    7: [(1, "Designnya aesthetic banget! Pas buat anak muda", None)],
    9: [(22, "Semoga dilanjut developnya ya!", None)],
    12: [(3, "Wah mantap! Study case UI/UX nih", None)],
    14: [(15, "Hasilnya keren! UKM batiknya pake belum?", None)],
    16: [(2, "Wah saingan nih pas lomba 😄", None)],
    17: [(5, "Mantap, kampus kita berbakat semua!", None)],
    18: [(13, "Kereen. Bikin bangga kampus!", None)],
    19: [(27, "Selamat! Harus dirayain nih 🎊", None)],
}

LIKES_DATA = {
    0: [1, 2, 3, 25],
    1: [16, 17],
    2: [4, 14, 19],
    3: [41, 42, 38],
    4: [32, 33, 35],
    5: [20, 21, 27],
    6: [28, 29],
    7: [1, 2, 3],
    8: [13, 14],
    9: [22, 23],
    10: [36, 37],
    11: [15, 16, 17, 40],
    12: [3, 4, 5],
    13: [22, 23, 38],
    14: [29, 30, 34],
    15: [2, 5, 1],
    16: [1, 3, 4, 47],
    17: [5, 6, 22],
    18: [13, 14, 19],
    19: [25, 27, 29],
}


async def seed():
    db = Prisma()
    await db.connect()

    print("🧹 Membersihkan data lama...")
    await db.projectfile.delete_many()
    await db.projectinvite.delete_many()
    await db.saveditem.delete_many()
    await db.showcasecomment.delete_many()
    await db.showcaselike.delete_many()
    await db.showcase.delete_many()
    await db.message.delete_many()
    await db.notification.delete_many()
    await db.connection.delete_many()
    await db.task.delete_many()
    await db.projectapplication.delete_many()
    await db.projectmember.delete_many()
    await db.project.delete_many()
    await db.experience.delete_many()
    await db.userskill.delete_many()
    await db.skill.delete_many()
    await db.otpcode.delete_many()
    await db.user.delete_many()

    print("👤 Membuat 50 mahasiswa...")
    created_users = {}
    for u in USERS:
        user = await db.user.create(data={
            "nim": u["nim"],
            "full_name": u["full_name"],
            "faculty": u["faculty"],
            "major": u["major"],
            "password": PASSWORD_HASH,
            "email_verified": True,
            "is_onboarded": True,
        })
        created_users[u["nim"]] = user
        print(f"  ✓ {user.nim} - {user.full_name}")

    print("👑 Membuat Admin User...")
    admin_pw = bcrypt.hashpw(b"katasandi98", bcrypt.gensalt()).decode("utf-8")
    await db.user.create(data={
        "email": "admin@rembugan.com",
        "email_verified": True,
        "password": admin_pw,
        "full_name": "Admin Rembugan",
        "is_admin": True,
        "is_onboarded": True,
    })

    user_list = list(created_users.values())

    print("📁 Membuat 15 project & anggota...")
    created_projects = []
    for i, p in enumerate(PROJECTS):
        owner = user_list[p["owner_idx"]]
        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": p["title"],
            "description": p["description"],
            "required_skills": p["required_skills"],
            "status": p["status"],
            "category": p["category"],
            "total_slots": p["total_slots"],
        })
        created_projects.append(project)

        # Add owner as Ketua
        await db.projectmember.create(data={
            "project_id": project.id,
            "user_id": owner.id,
            "role": "Ketua",
        })

        # Add 3-6 tasks
        num_tasks = random.randint(3, 6)
        task_statuses = ["todo", "doing", "done"]
        for t in range(num_tasks):
            assignee = owner
            status = random.choice(task_statuses)
            task = await db.task.create(data={
                "project_id": project.id,
                "title": f"Task {t+1} - {p['title'][:20]}",
                "status": status,
                "deadline": (NOW + timedelta(days=random.randint(1, 30))),
            })
            await db.taskassignee.create(data={
                "task_id": task.id,
                "user_id": assignee.id,
            })

        # Add applications for open projects
        if p["status"] == "open":
            potential_candidates = [u for u in user_list if u.id != owner.id]
            for _ in range(random.randint(1, 2)):
                if not potential_candidates:
                    break
                applicant = random.choice(potential_candidates)
                existing = await db.projectapplication.find_first(where={
                    "project_id": project.id,
                    "applicant_id": applicant.id,
                })
                if not existing:
                    await db.projectapplication.create(data={
                        "project_id": project.id,
                        "applicant_id": applicant.id,
                    })

        print(f"  ✓ {project.title} ({p['status']})")

    print("📸 Membuat 30 showcase...")
    created_showcases = []
    for i, s in enumerate(SHOWCASES):
        author = user_list[s["owner_idx"]]
        linked_project = created_projects[s["linked_project_idx"]] if s["linked_project_idx"] is not None else None

        showcase_id = hashlib.md5(f"showcase-{i}".encode()).hexdigest()[:12]
        picsum_seed = f"showcase{i}"

        showcase = await db.showcase.create(data={
            "id": showcase_id,
            "author_id": author.id,
            "content": s["content"],
            "media_urls": [
                f"https://picsum.photos/seed/{picsum_seed}/400/300",
                f"https://picsum.photos/seed/{picsum_seed}b/400/300",
            ],
            "tags": s["tags"],
            "linked_project_id": linked_project.id if linked_project else None,
        })
        created_showcases.append(showcase)

    print("❤️ Menambahkan likes ke showcase...")
    for showcase_idx, user_indices in LIKES_DATA.items():
        if showcase_idx < len(created_showcases):
            for ui in user_indices:
                if ui < len(user_list):
                    try:
                        await db.showcaselike.create(data={
                            "showcase_id": created_showcases[showcase_idx].id,
                            "user_id": user_list[ui].id,
                        })
                    except Exception:
                        pass

    print("💬 Menambahkan komentar ke showcase...")
    for showcase_idx, comments in COMMENTS_DATA.items():
        if showcase_idx < len(created_showcases):
            for comment in comments:
                user_idx, content, parent_idx = comment
                if user_idx < len(user_list):
                    parent_id = None
                    if parent_idx is not None and parent_idx < len(comments):
                        # Karena parent comment belum di-create, skip dulu nested
                        pass
                    try:
                        await db.showcasecomment.create(data={
                            "showcase_id": created_showcases[showcase_idx].id,
                            "user_id": user_list[user_idx].id,
                            "content": content,
                        })
                    except Exception:
                        pass

    print("🔗 Membuat beberapa koneksi antar mahasiswa...")
    connection_pairs = [
        (0, 1), (0, 2), (0, 3), (0, 4), (1, 25), (2, 25), (3, 27),
        (24, 25), (24, 27), (24, 29), (25, 27), (25, 29),
        (35, 36), (35, 37), (36, 37),
        (40, 41), (40, 42), (41, 42),
        (46, 47), (46, 49), (47, 49),
        (13, 14), (19, 20), (31, 32),
        (0, 13), (1, 14), (2, 24), (13, 24), (17, 26),
    ]
    for sender_idx, receiver_idx in connection_pairs:
        if sender_idx < len(user_list) and receiver_idx < len(user_list):
            try:
                await db.connection.create(data={
                    "sender_id": user_list[sender_idx].id,
                    "receiver_id": user_list[receiver_idx].id,
                    "status": "accepted",
                })
            except Exception:
                pass

    await db.disconnect()
    print("\n✅ Seed selesai! 50 user + 15 project + 30 showcase berhasil dibuat.")
    print(f"   Password default semua akun: uhn2025")
    print(f"   Login bisa pakai NIM (contoh: 23090101) atau email (setelah di-set)")


if __name__ == "__main__":
    asyncio.run(seed())
