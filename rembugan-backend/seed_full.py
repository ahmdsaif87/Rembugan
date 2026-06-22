import asyncio
import random
import json
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.security import hash_password

PASSWORD_HASH = hash_password("00000000")

INTERESTS = [
    "Machine Learning",
    "Web Development",
    "UI/UX Design",
    "Data Science",
    "Mobile Development",
    "Cyber Security",
    "Game Development",
    "Internet of Things",
    "Artificial Intelligence",
    "Digital Marketing",
]

NAMA_USER = [
    "Ahmad Fauzi", "Siti Nurhaliza", "Bambang Supriyadi", "Dewi Sartika",
    "Rudi Hartono", "Ani Rahmawati", "Budi Santoso", "Citra Dewi",
    "Dian Puspita", "Eko Prasetyo", "Fajar Hidayat", "Gita Permata",
    "Hendra Gunawan", "Indah Lestari", "Joko Widodo", "Karin Kusuma",
    "Leo Pratama", "Mega Wati", "Nanda Firmansyah", "Oscar Tampubolon",
    "Putri Ayu", "Qori Ramadhan", "Rina Marlina", "Sandi Firmansyah",
    "Tari Utami", "Umar Zulkarnain", "Vina Violita", "Wahyu Nugroho",
    "Yudi Permana", "Zahra Almira", "Agus Wijaya", "Bella Octavia",
    "Candra Kusuma", "Dinda Kirana", "Eka Pratiwi", "Farhan Kurniawan",
    "Gina Sabrina", "Hafiz Ramadhan", "Intan Permata", "Jefri Kurniawan",
    "Kiki Amalia", "Lukman Hakim", "Mira Soraya", "Nizar Rahman",
    "Olivia Hernanda", "Panji Saputra", "Raka Maulana", "Siska Melina",
    "Titis Widya", "Ujang Permana", "Vera Anatasha", "Winda Sari",
    "Yoga Pratama", "Zidan Alfariz", "Alifia Rahman", "Bima Sakti",
    "Dimas Ardianto", "Elsa Safira", "Fikri Haikal", "Geby Maharani",
]

NAMA_SKILL = [
    "Python", "Java", "JavaScript", "Flutter", "React Native",
    "PHP", "Laravel", "React JS", "Next.js", "Node.js",
    "UI/UX Design", "Figma", "Adobe Illustrator", "Canva", "CorelDRAW",
    "SQL", "PostgreSQL", "MongoDB", "Firebase", "Prisma ORM",
    "FastAPI", "Flask", "Django", "REST API", "GraphQL",
    "Machine Learning", "Deep Learning", "Computer Vision", "NLP", "TensorFlow",
    "Docker", "Kubernetes", "Git", "Linux", "CI/CD",
    "Microsoft Excel", "Akuntansi", "SAP", "MYOB", "Accurate",
    "Manajemen Keuangan", "Analisis Data", "SPSS", "STATA", "R Programming",
    "Keperawatan", "Farmasi", "Kebidanan", "Gizi", "Kesehatan Masyarakat",
    "Teknik Mesin", "AutoCAD", "SolidWorks", "CNC", "PLC",
    "Teknik Elektro", "Arduino", "Raspberry Pi", "IoT", "PCB Design",
    "Perhotelan", "Housekeeping", "Food & Beverage", "Front Office", "Event Management",
    "Digital Marketing", "SEO", "Social Media", "Content Writing", "Copywriting",
    "Public Speaking", "Leadership", "Teamwork", "Problem Solving", "Critical Thinking",
]

INTEREST_TO_SKILLS = {
    "Machine Learning": [
        "Python", "Machine Learning", "Deep Learning", "Computer Vision", "NLP",
        "TensorFlow", "R Programming", "Analisis Data", "SPSS", "STATA",
    ],
    "Web Development": [
        "JavaScript", "React JS", "Next.js", "Node.js", "PHP", "Laravel",
        "FastAPI", "Flask", "Django", "PostgreSQL", "MongoDB", "Firebase",
        "Prisma ORM", "REST API", "GraphQL", "Git", "CSS",
    ],
    "UI/UX Design": [
        "UI/UX Design", "Figma", "Adobe Illustrator", "Canva", "CorelDRAW",
        "Adobe Photoshop", "Content Writing", "Copywriting",
    ],
    "Data Science": [
        "Python", "Machine Learning", "Analisis Data", "SPSS", "STATA",
        "R Programming", "SQL", "PostgreSQL", "MongoDB", "Microsoft Excel",
    ],
    "Mobile Development": [
        "Flutter", "React Native", "Dart", "JavaScript", "Firebase",
        "REST API", "GraphQL", "Git", "Node.js",
    ],
    "Cyber Security": [
        "Python", "Linux", "Docker", "Kubernetes", "Git",
        "Network Security", "Penetration Testing", "Cryptography",
    ],
    "Game Development": [
        "Python", "Java", "JavaScript", "C++", "Unity",
        "Blender", "3D Modeling", "Game Design",
    ],
    "Internet of Things": [
        "IoT", "Arduino", "Raspberry Pi", "Python", "C++",
        "PCB Design", "Sensor Technology", "Embedded System",
    ],
    "Artificial Intelligence": [
        "Python", "Machine Learning", "Deep Learning", "Computer Vision",
        "NLP", "TensorFlow", "REST API", "Analisis Data",
    ],
    "Digital Marketing": [
        "Digital Marketing", "SEO", "Social Media", "Content Writing",
        "Copywriting", "Public Speaking", "Microsoft Excel",
        "Manajemen Keuangan", "Analisis Data",
    ],
}

SKILLS_BY_INTEREST = {
    "Machine Learning": [
        ["Python", "Machine Learning", "TensorFlow"],
        ["Python", "Analisis Data", "SPSS"],
        ["Machine Learning", "Deep Learning", "NLP"],
        ["Python", "Computer Vision", "TensorFlow"],
    ],
    "Web Development": [
        ["JavaScript", "React JS", "Node.js"],
        ["PHP", "Laravel", "PostgreSQL"],
        ["Python", "FastAPI", "Next.js"],
        ["JavaScript", "React JS", "Firebase"],
    ],
    "UI/UX Design": [
        ["Figma", "Adobe Illustrator", "UI/UX Design"],
        ["Canva", "CorelDRAW", "Branding"],
        ["Adobe Photoshop", "UI/UX Design", "Prototyping"],
    ],
    "Data Science": [
        ["Python", "Analisis Data", "Machine Learning"],
        ["R Programming", "SPSS", "STATA"],
        ["Python", "SQL", "Microsoft Excel"],
    ],
    "Mobile Development": [
        ["Flutter", "Dart", "Firebase"],
        ["React Native", "JavaScript", "Node.js"],
        ["Flutter", "REST API", "Git"],
    ],
    "Cyber Security": [
        ["Python", "Linux", "Network Security"],
        ["Docker", "Kubernetes", "Penetration Testing"],
        ["Linux", "Cryptography", "Network Security"],
    ],
    "Game Development": [
        ["Python", "Game Design", "Unity"],
        ["Java", "C++", "3D Modeling"],
        ["JavaScript", "Game Design", "Blender"],
    ],
    "Internet of Things": [
        ["IoT", "Arduino", "Python"],
        ["Arduino", "Raspberry Pi", "Embedded System"],
        ["IoT", "Sensor Technology", "PCB Design"],
    ],
    "Artificial Intelligence": [
        ["Python", "Machine Learning", "Deep Learning"],
        ["Python", "Computer Vision", "TensorFlow"],
        ["NLP", "Machine Learning", "REST API"],
    ],
    "Digital Marketing": [
        ["Digital Marketing", "SEO", "Social Media"],
        ["Content Writing", "Copywriting", "Public Speaking"],
        ["SEO", "Analisis Data", "Microsoft Excel"],
    ],
}

BIO_USER = [
    "Mahasiswa aktif yang senang belajar hal baru.",
    "Menyukai tantangan dan selalu ingin berkembang.",
    "Aktif dalam organisasi kampus dan kepanitiaan.",
    "Memiliki minat di bidang teknologi dan inovasi.",
    "Senang berkolaborasi dalam tim untuk menyelesaikan masalah.",
    "Percaya bahwa pendidikan adalah kunci masa depan.",
    "Hobi membaca dan menulis artikel ilmiah.",
    "Aktif mengikuti seminar dan workshop.",
    "Bermimpi menjadi pengusaha sukses di bidang teknologi.",
    "Fokus pada pengembangan diri dan soft skills.",
    "Senang berbagi ilmu dengan teman-teman.",
    "Memiliki pengalaman magang di perusahaan ternama.",
]

JUDUL_PENGALAMAN = [
    "Magang Frontend Developer",
    "Asisten Laboratorium",
    "Ketua Himpunan Mahasiswa",
    "Freelance UI/UX Designer",
    "Anggota Tim Riset",
    "Staff Divisi Acara",
    "Praktek Kerja Lapangan",
    "Research Assistant",
    "Content Creator",
    "Wirausaha Muda",
    "Volunteer Mengajar",
    "Ketua Pelaksana Seminar",
]

PERUSAHAAN = [
    "PT Teknologi Maju",
    "Lab Komputer Universitas",
    "Himpunan Mahasiswa",
    "Studio Desain Kreatif",
    "Pusat Riset Universitas",
    "BEM Universitas",
    "Perusahaan Startup",
    "Pusat Penelitian Kampus",
    "Media Digital Kreatif",
    "Startup Lokal",
    "Yayasan Pendidikan",
    "Universitas Negeri",
]

JUDUL_PROYEK = [
    "Aplikasi Manajemen Tugas Mahasiswa Berbasis Mobile",
    "Sistem Informasi Perpustakaan Digital",
    "Website Marketplace UMKM Desa",
    "Platform E-learning Interaktif",
    "Dashboard Analisis Data Akademik",
    "Aplikasi Reservasi Berbasis Web",
    "Robot Pembersih Lantai Otomatis",
    "Sistem Kontrol Suhu Ruangan IoT",
    "Aplikasi Pengenalan Wajah untuk Absensi",
    "Game Edukasi Pengenalan Hewan",
    "Aplikasi Pemesanan Makanan Online",
    "Sistem Pakar Diagnosis Penyakit",
    "Platform Crowdfunding Untuk Beasiswa",
    "Aplikasi Manajemen Inventaris Laboratorium",
    "Sistem Rekomendasi Pembelajaran",
    "Aplikasi Pembelajaran Bahasa Isyarat",
    "Sistem Informasi Akuntansi UMKM",
    "Platform Telemedicine untuk Klinik",
    "Sistem Manajemen Inventaris Apotek",
    "Aplikasi Pemesanan Obat Online",
    "Sistem Informasi Manajemen Rumah Sakit",
    "Platform Pelatihan Digital Marketing",
    "Aplikasi Manajemen Event",
    "Sistem Informasi Geografis Pariwisata",
    "Dashboard Monitoring Kesehatan Pasien",
    "Aplikasi Deteksi Dini Stunting",
    "Sistem Informasi Geografis Penyebaran Penyakit",
    "Chatbot Layanan Akademik",
    "Aplikasi Donasi Online Berbasis Crowdfunding",
    "Sistem Prediksi Harga Saham Menggunakan Machine Learning",
]

KONTEN_SHOWCASE = [
    "Alhamdulillah, proyek aplikasi manajemen tugas akhirnya selesai! Dibangun dengan Flutter dan FastAPI.",
    "Baru selesai mengikuti workshop UI/UX Design selama 2 minggu. Banyak banget ilmu baru!",
    "Presentasi proyek IoT hari ini berjalan lancar. Alat monitoring suhu ruangan berhasil real-time.",
    "Bangga banget bisa berkontribusi dalam proyek sistem informasi perpustakaan digital untuk kampus.",
    "Baru aja menyelesaikan desain ulang website UKM binaan. Tampilan jadi lebih modern dan responsif!",
    "Ikut kompetisi machine learning tingkat nasional dan berhasil masuk 10 besar. Pengalaman yang luar biasa!",
    "Hasil penelitian tentang deteksi dini stunting menggunakan machine learning sudah dipublikasikan.",
    "Seru banget ngikutin bootcamp fullstack developer selama 3 bulan. Sekarang bisa bikin fullstack apps sendiri!",
    "Proyek analisis sentimen media sosial tentang pemilu berhasil mencapai akurasi 92%.",
    "Senang bisa berkontribusi sebagai volunteer pengajar di daerah terpencil. Berbagi ilmu itu indah.",
    "Tim kami berhasil membuat aplikasi pemesanan makanan untuk kantin kampus. DAU sudah 200+!",
    "Desain poster untuk acara seminar nasional sudah jadi. Feedback dari panitia sangat memuaskan!",
    "Alat deteksi kebocoran gas berbasis IoT berhasil diuji coba. Mendeteksi dalam waktu kurang dari 5 detik.",
    "Pengalaman magang di startup edtech bikin paham gimana cara kerja industri teknologi di Indonesia.",
    "Hari ini sidang proposal skripsi. Alhamdulillah lancar! Dosen penguji kasih banyak masukan berharga.",
]

TAGS_SHOWCASE = [
    ["flutter", "fastapi", "mobile", "project"],
    ["uiux", "design", "workshop"],
    ["iot", "monitoring", "suhu", "arduino"],
    ["library", "web", "information-system"],
    ["redesign", "website", "ukm", "responsive"],
    ["machine-learning", "kompetisi", "nasional"],
    ["machine-learning", "stunting", "penelitian"],
    ["fullstack", "bootcamp", "webdev"],
    ["analisis", "sentimen", "nlp", "python"],
    ["volunteer", "mengajar", "sosial"],
    ["mobile", "food", "kampus"],
    ["design", "poster", "seminar"],
    ["iot", "gas", "detector", "safety"],
    ["magang", "edtech", "pengalaman"],
    ["skripsi", "proposal", "sidang"],
]

KOMENTAR = [
    "Keren banget! boleh sharing dong ilmunya.",
    "Mantap! Lanjutkan karyanya.",
    "Wah keren, pakai stack apa aja?",
    "Salut! Semoga sukses selalu.",
    "Boleh minta saran? Aku juga lagi belajar ini.",
    "Karya yang bagus banget! Inspiratif!",
    "Good job! Semoga makin sukses.",
    "Jadi termotivasi nih, makasih sharingnya!",
    "Boleh join tim? Pengen belajar juga.",
    "Hebat! Pertahankan prestasinya.",
    "Kereen, next project apa nih?",
    "Mantap jiwa! Lanjutkan perjuangannya!",
    "Wah menginspirasi banget!",
    "Sama-sama belajar, semoga makin jago!",
    "Kapan-kapan cuy ngoding bareng yuk!",
]

TIPE_NOTIF = ["like", "comment", "connection_request", "connection_accepted", "chat"]
JUDUL_NOTIF = [
    "Menyukai showcase Anda",
    "Memberi komentar pada showcase Anda",
    "Mengirimkan permintaan koneksi",
    "Menerima permintaan koneksi Anda",
    "Mengirimkan pesan baru",
]
ISI_NOTIF = [
    " menyukai postingan showcase Anda.",
    " berkomentar pada postingan Anda.",
    " ingin terhubung dengan Anda.",
    " telah menerima permintaan koneksi Anda.",
    " mengirimkan pesan baru untuk Anda.",
]


async def main():
    db = Prisma()
    await db.connect()

    # ── 0. Keep known users by email ──
    print("0. Menyimpan user yang dipertahankan...")
    keep_emails = {"saifi@example.com", "dede@example.com"}
    keep_ids = set()
    for e in keep_emails:
        u = await db.user.find_first(where={"email": e})
        if u:
            keep_ids.add(u.id)
            print(f"   → {u.full_name} ({u.id})")

    # ── 1. Hapus semua data kecuali user yang dipertahankan ──
    print("\n1. Membersihkan database (kecuali user yang dipertahankan)...")
    tables = [
        "Notification", "Connection", "ShowcaseComment", "ShowcaseLike",
        "Showcase", "Message", "Task", "ProjectMember",
        "ProjectApplication", "Project", "Experience",
        "UserSkill", "Skill",
    ]
    for t in tables:
        await db.execute_raw(f'DELETE FROM "{t}" CASCADE')
    if keep_ids:
        ids_str = ", ".join(f"'{i}'" for i in keep_ids)
        await db.execute_raw(f'DELETE FROM "User" WHERE id NOT IN ({ids_str})')
    else:
        await db.execute_raw('DELETE FROM "User" CASCADE')
    print("   Database bersih.\n")

    # ── 2. Skills ──
    print("2. Membuat Skills...")
    skill_records = []
    for nama in NAMA_SKILL:
        s = await db.skill.create(data={"name": nama})
        skill_records.append(s)
    skill_map = {s.name: s.id for s in skill_records}
    print(f"   {len(skill_records)} skills created\n")

    # ── 3. Users – 60 user dengan email dan interest ──
    print("3. Membuat 60 Users (email user1@example.com s/d user60@example.com)...")
    user_records = []
    photo_idx = 0
    all_cover_urls = [
        "https://images.unsplash.com/photo-1557683316-973673baf926?w=800",
        "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=800",
        "https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=800",
        "https://images.unsplash.com/photo-1557682224-5b8590cd9ec5?w=800",
        "https://images.unsplash.com/photo-1557682260-96773eb01377?w=800",
        "https://images.unsplash.com/photo-1523437113738-bbd3cc89fb19?w=800",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800",
        "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800",
        "https://images.unsplash.com/photo-1557682269-e1675a34b1d8?w=800",
    ]
    all_photo_urls = [
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
        "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200",
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200",
        "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200",
        "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200",
        "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200",
    ]

    for i in range(60):
        name = NAMA_USER[i % len(NAMA_USER)]
        email = f"user{i + 1}@example.com"
        interest = random.choice(INTERESTS)
        handle = name.lower().replace(" ", "") + str(i + 1)
        user = await db.user.create(data={
            "email": email,
            "password": PASSWORD_HASH,
            "full_name": name,
            "handle": handle,
            "interest": interest,
            "bio": random.choice(BIO_USER),
            "photo_url": all_photo_urls[photo_idx % len(all_photo_urls)],
            "cover_url": random.choice(all_cover_urls),
            "social_links": json.dumps({
                "instagram": f"https://instagram.com/{handle}",
                "linkedin": f"https://linkedin.com/in/{handle}",
                "github": f"https://github.com/{handle}",
            }),
            "is_onboarded": True,
            "email_verified": True,
        })
        user_records.append(user)
        photo_idx += 1

    # Re-add kept users if they were deleted
    if "saifi@example.com" in keep_emails:
        existing = await db.user.find_first(where={"email": "saifi@example.com"})
        if not existing:
            s = await db.user.create(data={
                "email": "saifi@example.com",
                "password": PASSWORD_HASH,
                "full_name": "Ahmad Saifi Khayatu Ulumuddin",
                "handle": "ahmadsaifi",
                "interest": "Web Development",
                "bio": "Mahasiswa yang suka ngoding.",
                "photo_url": all_photo_urls[0],
                "cover_url": random.choice(all_cover_urls),
                "social_links": json.dumps({
                    "instagram": "https://instagram.com/ahmadsaifi",
                    "linkedin": "https://linkedin.com/in/ahmadsaifi",
                    "github": "https://github.com/ahmadsaifi",
                }),
                "is_onboarded": True,
                "email_verified": True,
            })
            user_records.append(s)
            print("   → Ahmad Saifi dibuat ulang")
        else:
            user_records.append(existing)
            print("   → Ahmad Saifi dipertahankan")
    if "dede@example.com" in keep_emails:
        existing = await db.user.find_first(where={"email": "dede@example.com"})
        if not existing:
            d = await db.user.create(data={
                "email": "dede@example.com",
                "password": PASSWORD_HASH,
                "full_name": "Dede Fernanda",
                "handle": "dedefernanda",
                "interest": "Web Development",
                "bio": "Mahasiswa yang suka ngoding.",
                "photo_url": all_photo_urls[1],
                "cover_url": random.choice(all_cover_urls),
                "social_links": json.dumps({
                    "instagram": "https://instagram.com/dedefernanda",
                    "linkedin": "https://linkedin.com/in/dedefernanda",
                    "github": "https://github.com/dedefernanda",
                }),
                "is_onboarded": True,
                "email_verified": True,
            })
            user_records.append(d)
            print("   → Dede Fernanda dibuat ulang")
        else:
            user_records.append(existing)
            print("   → Dede Fernanda dipertahankan")

    print(f"   {len(user_records)} users total\n")

    # ── 4. UserSkill ──
    print("4. Membuat UserSkill...")
    for user in user_records:
        interest = user.interest
        skills_for_interest = INTEREST_TO_SKILLS.get(interest, [])
        if skills_for_interest:
            selected = random.sample(skills_for_interest, min(random.randint(3, 5), len(skills_for_interest)))
            for skill_name in selected:
                skill_id = skill_map.get(skill_name)
                if skill_id:
                    await db.userskill.create(data={"user_id": user.id, "skill_id": skill_id})
    print(f"   UserSkill created\n")

    # ── 5. Experience ──
    print("5. Membuat Experience...")
    for user in user_records:
        num_exp = random.randint(1, 2)
        for _ in range(num_exp):
            idx = random.randint(0, len(JUDUL_PENGALAMAN) - 1)
            start = datetime.now() - timedelta(days=random.randint(180, 730))
            end = start + timedelta(days=random.randint(60, 365)) if random.random() > 0.4 else None
            await db.experience.create(data={
                "user_id": user.id,
                "title": JUDUL_PENGALAMAN[idx],
                "company": PERUSAHAAN[idx],
                "description": f"Bertanggung jawab dalam mengerjakan tugas-tugas terkait {JUDUL_PENGALAMAN[idx].lower()} selama {random.randint(2, 6)} bulan.",
                "start_date": start,
                "end_date": end,
            })
    print(f"   Experience created\n")

    # ── 6. Projects (30) ──
    print("6. Membuat 30 Projects...")

    project_records = []
    selected_titles = random.sample(JUDUL_PROYEK, min(30, len(JUDUL_PROYEK)))
    for title in selected_titles:
        owner = random.choice(user_records)
        interest = random.choice(INTERESTS)
        total_slots = random.randint(3, 5)
        deadline = datetime.now() + timedelta(days=random.randint(7, 90))

        interest_skills = SKILLS_BY_INTEREST.get(interest, [["Python", "JavaScript", "Git"]])
        skills = random.choice(interest_skills)

        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": title,
            "description": (
                f"Proyek {title.lower()} bertujuan untuk mengembangkan solusi digital "
                f"yang inovatif dan bermanfaat bagi masyarakat. "
                f"Dibangun dengan pendekatan kolaboratif menggunakan teknologi terkini."
            ),
            "required_skills": skills,
            "interest": interest,
            "status": "open",
            "deadline": deadline,
            "total_slots": total_slots,
        })

        await db.projectmember.create(data={
            "project_id": project.id,
            "user_id": owner.id,
            "role": "Ketua",
        })

        potential = [u for u in user_records if u.id != owner.id]
        num_members = random.randint(1, min(2, total_slots - 2))
        if num_members > 0 and potential:
            selected = random.sample(potential, min(num_members, len(potential)))
            for m in selected:
                await db.projectmember.create(data={
                    "project_id": project.id,
                    "user_id": m.id,
                    "role": "Anggota",
                })

        project_records.append(project)

    print(f"   {len(project_records)} projects created\n")

    # ── 7. ProjectApplication ──
    print("7. Membuat ProjectApplication...")
    for _ in range(30):
        project = random.choice(project_records)
        applicant = random.choice(user_records)
        if applicant.id != project.owner_id:
            existing = await db.projectapplication.find_first(
                where={"project_id": project.id, "applicant_id": applicant.id}
            )
            if not existing:
                status = random.choices(["pending", "accepted", "rejected"], weights=[0.5, 0.3, 0.2])[0]
                await db.projectapplication.create(data={
                    "project_id": project.id,
                    "applicant_id": applicant.id,
                    "status": status,
                })
    print(f"   ProjectApplication created\n")

    # ── 8. Tasks ──
    print("8. Membuat Tasks...")
    for project in project_records:
        members = await db.projectmember.find_many(where={"project_id": project.id})
        member_ids = [m.user_id for m in members]
        for _ in range(random.randint(3, 6)):
            task_title = random.choice([
                "Membuat halaman login", "Merancang database", "Membuat API endpoint",
                "Desain UI prototype", "Testing dan debugging", "Menulis dokumentasi",
                "Integrasi frontend-backend", "Deploy ke server", "Membuat laporan proyek",
                "Presentasi progress", "Membuat mockup aplikasi", "Optimasi performa",
            ])
            status = random.choices(["todo", "doing", "done"], weights=[0.3, 0.3, 0.4])[0]
            assignee = random.choice(member_ids) if member_ids else None
            deadline = datetime.now() + timedelta(days=random.randint(1, 30)) if status != "done" else None
            await db.task.create(data={
                "project_id": project.id,
                "assignee_id": assignee,
                "title": task_title,
                "status": status,
                "deadline": deadline,
            })
    print(f"   Tasks created\n")

    # ── 9. Messages ──
    print("9. Membuat Messages...")
    for _ in range(40):
        sender = random.choice(user_records)
        receiver = random.choice([u for u in user_records if u.id != sender.id])
        await db.message.create(data={
            "content": random.choice([
                "Halo, apa kabar?", "Bagaimana progress tugasnya?",
                "Ayo kita diskusikan proyeknya nanti siang.", "Sudah lihat desain terbaru?",
                "Ada kendala di bagian backend?", "Mantap! Lanjutkan!",
                "Saya sudah push code terbaru.", "Tolong review PR saya ya.",
                "Besok ada meeting jam 10 pagi.", "File-nya sudah saya upload di drive.",
                "Terima kasih bantuannya!", "Sama-sama, senang bisa membantu.",
                "Kapan deadline tugas ini?", "Kita harus selesaikan minggu ini.",
                "Apakah ada yang bisa saya bantu?",
            ]),
            "sender_id": sender.id,
            "receiver_id": receiver.id,
        })
    print(f"   Messages created\n")

    # ── 10. Showcase ──
    print("10. Membuat Showcase...")
    showcase_records = []
    for _ in range(25):
        author = random.choice(user_records)
        content = random.choice(KONTEN_SHOWCASE)
        media = random.sample([
            "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600",
            "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600",
            "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600",
            "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600",
            "https://images.unsplash.com/photo-1504639725590-34d0984388bd?w=600",
            "https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=600",
            "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=600",
            "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600",
            "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=600",
            "https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=600",
        ], random.randint(1, 3))
        tags = random.choice(TAGS_SHOWCASE)
        linked_project = random.choice(project_records) if random.random() > 0.6 else None
        showcase = await db.showcase.create(data={
            "author_id": author.id,
            "content": content,
            "media_urls": media,
            "tags": tags,
            "linked_project_id": linked_project.id if linked_project else None,
        })
        showcase_records.append(showcase)
    print(f"   {len(showcase_records)} showcases created\n")

    # ── 11. ShowcaseLike ──
    print("11. Membuat ShowcaseLike...")
    for showcase in showcase_records:
        likers = random.sample(user_records, min(random.randint(2, 8), len(user_records)))
        for liker in likers:
            existing = await db.showcaselike.find_first(
                where={"showcase_id": showcase.id, "user_id": liker.id}
            )
            if not existing:
                await db.showcaselike.create(data={
                    "showcase_id": showcase.id,
                    "user_id": liker.id,
                })
    print(f"   ShowcaseLike created\n")

    # ── 12. ShowcaseComment ──
    print("12. Membuat ShowcaseComment...")
    for showcase in showcase_records:
        for _ in range(random.randint(1, 4)):
            commenter = random.choice(user_records)
            await db.showcasecomment.create(data={
                "showcase_id": showcase.id,
                "user_id": commenter.id,
                "content": random.choice(KOMENTAR),
            })
    print(f"   ShowcaseComment created\n")

    # ── 13. Connection ──
    print("13. Membuat Connection...")
    pairs = set()
    for _ in range(50):
        sender = random.choice(user_records)
        receiver = random.choice([u for u in user_records if u.id != sender.id])
        pair = tuple(sorted((sender.id, receiver.id)))
        if pair not in pairs:
            pairs.add(pair)
            status = random.choices(["pending", "accepted", "rejected"], weights=[0.3, 0.6, 0.1])[0]
            await db.connection.create(data={
                "sender_id": sender.id,
                "receiver_id": receiver.id,
                "status": status,
            })
    print(f"   {len(pairs)} connections created\n")

    # ── 14. Notification ──
    print("14. Membuat Notification...")
    for _ in range(40):
        user = random.choice(user_records)
        actor = random.choice([u for u in user_records if u.id != user.id])
        tipe = random.choice(TIPE_NOTIF)
        await db.notification.create(data={
            "user_id": user.id,
            "type": tipe,
            "title": actor.full_name + " " + random.choice(JUDUL_NOTIF),
            "content": actor.full_name + random.choice(ISI_NOTIF),
            "is_read": random.random() > 0.5,
            "link": f"/showcase/{random.choice(showcase_records).id}" if tipe in ["like", "comment"] else "/profile",
        })
    print(f"   Notifications created\n")

    # ── 15. Auto-close penuh ──
    print("15. Auto-close proyek yang sudah penuh...")
    fixed = 0
    for p in await db.project.find_many(where={"status": "open"}, include={"members": True}):
        filled = len(p.members) if p.members else 0
        if p.total_slots is not None and filled >= p.total_slots:
            await db.project.update(where={"id": p.id}, data={"status": "ongoing"})
            print(f"   → #{p.id} {p.title}: {filled}/{p.total_slots} → ongoing")
            fixed += 1
    print(f"   {fixed} proyek auto-closed\n")

    total_open = await db.project.count(where={"status": "open"})
    total_users = await db.user.count()
    print("✅ SELESAI!")
    print(f"   Users: {total_users}")
    print(f"   Skills: {len(skill_records)}")
    print(f"   Projects: {len(project_records)} (open: {total_open})")
    print(f"   Showcases: {len(showcase_records)}")

    await db.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
