import asyncio
import random
from datetime import datetime, timedelta
import json
from prisma import Prisma
import bcrypt

PASSWORD_HASH = bcrypt.hashpw("password123".encode(), bcrypt.gensalt()).decode()

INTERESTS = {
    "tech": "Tech Enthusiast",
    "pharmacy": "Pharmacy Enthusiast",
    "accounting": "Accounting Enthusiast",
    "nursing": "Nursing Enthusiast",
    "design": "Design Enthusiast",
    "business": "Business Enthusiast",
    "hospitality": "Hospitality Enthusiast",
    "engineering": "Engineering Enthusiast",
    "midwifery": "Midwifery Enthusiast",
}

USER_NAMES = [
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
    "tech": ["Python", "JavaScript", "Flutter", "React JS", "Next.js", "Node.js",
             "FastAPI", "PostgreSQL", "MongoDB", "Firebase", "Docker", "Git",
             "Machine Learning", "Linux", "REST API"],
    "pharmacy": ["Farmasi", "Kesehatan Masyarakat", "Gizi", "Analisis Data",
                 "Microsoft Excel", "Public Speaking", "Problem Solving"],
    "accounting": ["Akuntansi", "Microsoft Excel", "SAP", "MYOB", "Manajemen Keuangan",
                   "Analisis Data", "SPSS", "Leadership"],
    "nursing": ["Keperawatan", "Kesehatan Masyarakat", "Gizi", "Public Speaking",
                "Teamwork", "Critical Thinking", "Problem Solving"],
    "design": ["UI/UX Design", "Figma", "Adobe Illustrator", "Canva", "CorelDRAW",
               "Content Writing", "Copywriting"],
    "business": ["Manajemen Keuangan", "Digital Marketing", "Public Speaking",
                 "Microsoft Excel", "Leadership", "Analisis Data", "SEO",
                 "Content Writing", "Copywriting"],
    "hospitality": ["Perhotelan", "Housekeeping", "Food & Beverage", "Front Office",
                    "Event Management", "Public Speaking", "Teamwork",
                    "Leadership", "Problem Solving"],
    "engineering": ["Teknik Mesin", "AutoCAD", "SolidWorks", "CNC", "PLC",
                    "Teknik Elektro", "Arduino", "IoT", "Raspberry Pi",
                    "PCB Design", "Problem Solving", "Critical Thinking"],
    "midwifery": ["Kebidanan", "Keperawatan", "Kesehatan Masyarakat", "Gizi",
                  "Public Speaking", "Teamwork"],
}

JUDUL_PROYEK = [
    "Aplikasi Manajemen Tugas Mahasiswa Berbasis Mobile",
    "Sistem Informasi Perpustakaan Digital",
    "Website Marketplace UMKM Desa",
    "Aplikasi Chat Real-time untuk Komunitas Kampus",
    "Sistem Pencatatan Keuangan UKM",
    "Platform E-learning Interaktif",
    "Aplikasi Deteksi Dini Stunting",
    "Sistem Informasi Geografis Penyebaran Penyakit",
    "Dashboard Analisis Data Akademik",
    "Aplikasi Reservasi Hotel Berbasis Web",
    "Robot Pembersih Lantai Otomatis",
    "Sistem Kontrol Suhu Ruangan IoT",
    "Aplikasi Pengenalan Wajah untuk Absensi",
    "Game Edukasi Pengenalan Hewan",
    "Aplikasi Pemesanan Makanan Online",
    "Sistem Pakar Diagnosis Penyakit",
    "Platform Crowdfunding Untuk Beasiswa",
    "Aplikasi Manajemen Inventaris Laboratorium",
    "Sistem Rekomendasi Peminatan Prodi",
    "Aplikasi Pembelajaran Bahasa Isyarat",
    "Sistem Informasi Akuntansi UMKM",
    "Aplikasi Konsultasi Farmasi Online",
    "Platform Telemedicine untuk Klinik",
    "Sistem Manajemen Inventaris Apotek",
    "Aplikasi Pemesanan Obat Online",
    "Sistem Informasi Manajemen Rumah Sakit",
    "Platform Pelatihan Digital Marketing",
    "Aplikasi Manajemen Event",
    "Sistem Informasi Geografis Pariwisata",
    "Dashboard Monitoring Kesehatan Pasien",
]

JUDUL_PROYEK_NON_IT = [
    # Farmasi
    "Sistem Pengelolaan Stok Obat Apotek",
    "Platform Edukasi Penggunaan Obat yang Aman",
    "Aplikasi Konsultasi Farmasi Klinik",
    # Akuntansi
    "Sistem Akuntansi Keuangan Masjid",
    "Aplikasi Pembukuan Usaha Mikro",
    "Dashboard Laporan Keuangan BUMDes",
    # Keperawatan
    "Aplikasi Monitoring Tanda Vital Pasien",
    "Sistem Informasi Imunisasi Balita",
    "Platform Perawatan Lansia Berbasis Komunitas",
    # Kebidanan
    "Aplikasi Kalkulator Masa Subur",
    "Sistem Informasi Posyandu Digital",
    "Platform Konsultasi Kesehatan Ibu dan Anak",
    # Perhotelan
    "Sistem Manajemen Operasional Hotel",
    "Aplikasi Room Service Berbasis Mobile",
    "Platform Pemesanan Paket Wisata Lokal",
    # Bisnis
    "Aplikasi Analisis Kelayakan Usaha",
    "Platform Manajemen Koperasi Simpan Pinjam",
    "Sistem Informasi Pemasaran Produk Lokal",
    # Teknik
    "Alat Pengukur Kualitas Udara Portabel",
    "Sistem Irigasi Sawah Otomatis Berbasis IoT",
]

PHOTO_URLS = [
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

BIO_USER = [
    "Passionate about technology and innovation. Always eager to learn new things.",
    "Enthusiast in healthcare and community service. Love helping others.",
    "Creative thinker with a passion for design and visual arts.",
    "Detail-oriented professional with strong analytical skills.",
    "Team player who thrives in collaborative environments.",
    "Committed to making a positive impact through technology.",
    "Lifelong learner with a growth mindset.",
    "Passionate about bridging the gap between technology and healthcare.",
    "Experienced in project management and team leadership.",
    "Dedicated to creating user-friendly digital experiences.",
]


async def main():
    db = Prisma()
    await db.connect()

    print("Membersihkan database...")
    tables = [
        "Notification", "Connection", "ShowcaseComment", "ShowcaseLike",
        "Showcase", "Message", "Task", "ProjectMember",
        "ProjectApplication", "Project", "Experience",
        "UserSkill", "Skill", "User",
    ]
    for t in tables:
        await db.execute_raw(f'DELETE FROM "{t}" CASCADE')

    print("1. Membuat Skills...")
    skill_records = []
    for nama in NAMA_SKILL:
        s = await db.skill.create(data={"name": nama})
        skill_records.append(s)
    skill_map = {s.name: s.id for s in skill_records}
    print(f"   {len(skill_records)} skills created")

    print("2. Membuat Users...")
    user_records = []
    interest_keys = list(INTERESTS.keys())
    for i, name in enumerate(USER_NAMES):
        interest_key = random.choice(interest_keys)
        interest_label = INTERESTS[interest_key]
        email = f"{name.lower().replace(' ', '.')}{i}@rembugan.app"
        user = await db.user.create(data={
            "email": email,
            "email_verified": True,
            "password": PASSWORD_HASH,
            "full_name": name,
            "interest": interest_label,
            "bio": random.choice(BIO_USER),
            "photo_url": PHOTO_URLS[i % len(PHOTO_URLS)],
            "social_links": json.dumps({
                "instagram": f"https://instagram.com/{name.lower().replace(' ', '')}",
                "linkedin": f"https://linkedin.com/in/{name.lower().replace(' ', '')}",
                "github": f"https://github.com/{name.lower().replace(' ', '')}",
            }),
            "is_onboarded": True,
        })
        user_records.append(user)
    print(f"   {len(user_records)} users created")

    print("3. Membuat UserSkill...")
    for user in user_records:
        interest_label = user.interest
        interest_key = None
        for k, v in INTERESTS.items():
            if v == interest_label:
                interest_key = k
                break
        skills_for_interest = INTEREST_TO_SKILLS.get(interest_key, [])
        if skills_for_interest:
            selected = random.sample(skills_for_interest, min(random.randint(3, 5), len(skills_for_interest)))
            for skill_name in selected:
                skill_id = skill_map.get(skill_name)
                if skill_id:
                    await db.userskill.create(data={
                        "user_id": user.id,
                        "skill_id": skill_id,
                    })
    print(f"   UserSkill created for all users")

    print("4. Membuat Projects...")
    project_records = []
    all_titles = JUDUL_PROYEK + JUDUL_PROYEK_NON_IT
    selected_indices = random.sample(range(len(all_titles)), min(35, len(all_titles)))
    for order, idx in enumerate(selected_indices):
        judul = all_titles[idx]
        owner = random.choice(user_records)

        # Map interest based on title index
        if idx < len(JUDUL_PROYEK):
            interest_key = random.choice(interest_keys)
        else:
            non_it_idx = idx - len(JUDUL_PROYEK)
            non_it_keys = ["pharmacy", "accounting", "nursing", "midwifery", "hospitality", "business", "engineering"]
            interest_key = non_it_keys[non_it_idx % len(non_it_keys)]

        interest_label = INTERESTS[interest_key]

        # Pick skills relevant to the interest
        interest_skills = INTEREST_TO_SKILLS.get(interest_key, NAMA_SKILL)
        skill_pool = [s for s in NAMA_SKILL if s in interest_skills] or NAMA_SKILL

        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": judul,
            "description": (
                f"Proyek {judul.lower()} bertujuan untuk mengembangkan solusi yang inovatif "
                f"dan bermanfaat bagi masyarakat. "
                f"Dibangun dengan pendekatan profesional oleh tim yang solid."
            ),
            "required_skills": random.sample(skill_pool, min(random.randint(2, 4), len(skill_pool))),
            "interest": interest_label,
            "total_slots": random.randint(4, 6),
            "status": "open" if order < 20 else ("ongoing" if order < 28 else "completed"),
        })
        project_records.append(project)
    print(f"   {len(project_records)} projects created")

    print("5. Membuat ProjectMember...")
    for project in project_records:
        await db.projectmember.create(data={
            "project_id": project.id,
            "user_id": project.owner_id,
            "role": "Ketua",
        })
        potential = [u for u in user_records if u.id != project.owner_id]
        selected_members = random.sample(potential, min(random.randint(2, 3), len(potential)))
        for m in selected_members:
            await db.projectmember.create(data={
                "project_id": project.id,
                "user_id": m.id,
                "role": "Anggota",
            })
    print(f"   ProjectMember created")

    print("6. Membuat ProjectApplication...")
    for _ in range(20):
        open_projects = [p for p in project_records if p.status == "open"]
        if not open_projects:
            break
        project = random.choice(open_projects)
        applicant = random.choice(user_records)
        if applicant.id != project.owner_id:
            existing = await db.projectapplication.find_first(
                where={"project_id": project.id, "applicant_id": applicant.id}
            )
            if not existing:
                status = random.choices(
                    ["pending", "accepted", "rejected"],
                    weights=[0.5, 0.3, 0.2]
                )[0]
                await db.projectapplication.create(data={
                    "project_id": project.id,
                    "applicant_id": applicant.id,
                    "status": status,
                })
    print(f"   ProjectApplication created")

    print("7. Membuat Tasks...")
    for project in project_records:
        members = await db.projectmember.find_many(
            where={"project_id": project.id}
        )
        member_ids = [m.user_id for m in members]
        for _ in range(random.randint(3, 5)):
            task_title = random.choice([
                "Membuat halaman login",
                "Merancang database",
                "Membuat API endpoint",
                "Desain UI prototype",
                "Testing dan debugging",
                "Menulis dokumentasi",
                "Integrasi frontend-backend",
                "Deploy ke server",
                "Membuat laporan proyek",
                "Presentasi progress",
            ])
            status = random.choices(
                ["todo", "doing", "done"],
                weights=[0.3, 0.3, 0.4]
            )[0]
            assignee = random.choice(member_ids) if member_ids else None
            deadline = datetime.now() + timedelta(days=random.randint(1, 30)) if status != "done" else None
            await db.task.create(data={
                "project_id": project.id,
                "assignee_id": assignee,
                "title": task_title,
                "status": status,
                "deadline": deadline,
            })
    print(f"   Tasks created")

    await db.disconnect()
    print("\n✅ SEED DATA BERHASIL DIISI!")
    print(f"   Users: {len(user_records)}")
    print(f"   Skills: {len(skill_records)}")
    print(f"   Projects: {len(project_records)}")


if __name__ == "__main__":
    asyncio.run(main())
