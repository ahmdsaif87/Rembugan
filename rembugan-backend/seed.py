import asyncio
import random
from datetime import datetime, timedelta
import json
from prisma import Prisma
from prisma.models import User, Skill, UserSkill, Experience, Project, ProjectApplication, ProjectMember, Task, Message, Showcase, ShowcaseLike, ShowcaseComment, Connection, Notification
from prisma.types import UserCreateInput
import bcrypt

PASSWORD_HASH = bcrypt.hashpw("password123".encode(), bcrypt.gensalt()).decode()

MAJORS = {
    "01": "D3 Akuntansi",
    "02": "D3 Keperawatan",
    "03": "D3 Teknik Mesin",
    "04": "D3 Teknik Komputer",
    "05": "D3 Teknik Elektronika",
    "06": "D3 DKV",
    "07": "D3 Perhotelan",
    "08": "D3 Farmasi",
    "09": "D4 Teknik Informatika",
    "10": "D4 Akuntansi Sektor Publik",
    "11": "D4 Kebidanan",
    "21": "S1 Teknik Mesin",
    "22": "S1 Manajemen",
}

NAMA_PER_PRODI = {
    "01": ["Ahmad Fauzi", "Siti Nurhaliza", "Bambang Supriyadi", "Dewi Sartika", "Rudi Hartono"],
    "02": ["Ani Rahmawati", "Budi Santoso", "Citra Dewi", "Dian Puspita", "Eko Prasetyo"],
    "03": ["Fajar Hidayat", "Gita Permata", "Hendra Gunawan", "Indah Lestari", "Joko Widodo"],
    "04": ["Karin Kusuma", "Leo Pratama", "Mega Wati", "Nanda Firmansyah", "Oscar Tampubolon"],
    "05": ["Putri Ayu", "Qori Ramadhan", "Rina Marlina", "Sandi Firmansyah", "Tari Utami"],
    "06": ["Umar Zulkarnain", "Vina Violita", "Wahyu Nugroho", "Xena Marisa", "Yudi Permana"],
    "07": ["Zahra Almira", "Agus Wijaya", "Bella Octavia", "Candra Kusuma", "Dinda Kirana"],
    "08": ["Eka Pratiwi", "Farhan Kurniawan", "Gina Sabrina", "Hafiz Ramadhan", "Intan Permata"],
    "09": ["Jefri Kurniawan", "Kiki Amalia", "Lukman Hakim", "Mira Soraya", "Nizar Rahman"],
    "10": ["Olivia Hernanda", "Panji Saputra", "Queen Auryn", "Raka Maulana", "Siska Melina"],
    "11": ["Titis Widya", "Ujang Permana", "Vera Anatasha", "Winda Sari", "Xavier Tama"],
    "21": ["Yoga Pratama", "Zidan Alfariz", "Alifia Rahman", "Bima Sakti", "Cinta Laura"],
    "22": ["Dimas Ardianto", "Elsa Safira", "Fikri Haikal", "Geby Maharani", "Haris Munandar"],
}

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
]

SKILL_PER_PRODI = {
    "01": ["Microsoft Excel", "Akuntansi", "MYOB", "SAP", "Accurate"],
    "02": ["Keperawatan", "Kesehatan Masyarakat", "Gizi"],
    "03": ["Teknik Mesin", "AutoCAD", "SolidWorks", "CNC", "PLC"],
    "04": ["Python", "Java", "JavaScript", "PHP", "Laravel", "React JS", "Node.js", "SQL", "Git"],
    "05": ["Teknik Elektro", "Arduino", "Raspberry Pi", "IoT", "PCB Design"],
    "06": ["UI/UX Design", "Figma", "Adobe Illustrator", "Canva", "CorelDRAW"],
    "07": ["Perhotelan", "Housekeeping", "Food & Beverage", "Front Office", "Event Management"],
    "08": ["Farmasi", "Kesehatan Masyarakat"],
    "09": ["Python", "JavaScript", "Flutter", "React JS", "Next.js", "Node.js",
           "React Native", "FastAPI", "PostgreSQL", "MongoDB", "Firebase",
           "Prisma ORM", "Docker", "Git", "Linux", "Machine Learning"],
    "10": ["Akuntansi", "Microsoft Excel", "SAP", "MYOB", "Manajemen Keuangan"],
    "11": ["Kebidanan", "Keperawatan", "Kesehatan Masyarakat", "Gizi"],
    "21": ["Teknik Mesin", "AutoCAD", "SolidWorks", "PLC"],
    "22": ["Manajemen Keuangan", "Digital Marketing", "Public Speaking",
           "Microsoft Excel", "Leadership", "Analisis Data"],
}

PRODI_TO_SKILL_IDS = {}

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

SHOWCASE_MEDIA = [
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
    "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600",
    "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=600",
]

BIO_MAHASISWA = [
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
    "Anggota Tim Robotik",
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
    "Tim Robotik Universitas",
    "BEM Universitas",
    "Rumah Sakit Umum Daerah",
    "Pusat Penelitian Kampus",
    "Media Digital Kreatif",
    "Startup Lokal",
    "Yayasan Pendidikan",
    "Universitas Negeri",
]

KONTEN_SHOWCASE = [
    "Alhamdulillah, proyek aplikasi manajemen tugas akhirnya selesai! Dibangun dengan Flutter dan FastAPI. Cek repositori saya untuk detailnya.",
    "Baru selesai mengikuti workshop UI/UX Design selama 2 minggu. Banyak banget ilmu baru yang bisa diterapkan di proyek selanjutnya!",
    "Presentasi proyek IoT hari ini berjalan lancar. Alat monitoring suhu ruangan berhasil mendeteksi perubahan suhu secara real-time.",
    "Bangga banget bisa berkontribusi dalam proyek sistem informasi perpustakaan digital untuk kampus. Semoga bermanfaat buat adik-adik tingkat.",
    "Baru aja menyelesaikan desain ulang website UKM binaan. Tampilan jadi lebih modern dan responsif!",
    "Ikut kompetisi robotik tingkat nasional dan berhasil masuk 10 besar. Pengalaman yang luar biasa!",
    "Hasil penelitian tentang deteksi dini stunting menggunakan machine learning sudah dipublikasikan. Terima kasih tim!",
    "Seru banget ngikutin bootcamp fullstack developer selama 3 bulan. Sekarang bisa bikin fullstack apps sendiri!",
    "Proyek analisis sentimen media sosial tentang pemilu berhasil mencapai akurasi 92%. Masih bisa ditingkatkan lagi!",
    "Senang bisa berkontribusi sebagai volunteer pengajar di daerah terpencil. Berbagi ilmu itu indah.",
    "Tim kami berhasil membuat aplikasi pemesanan makanan untuk kantin kampus. Daily active user sudah 200+!",
    "Desain poster untuk acara seminar nasional sudah jadi. Feedback dari panitia sangat memuaskan!",
    "Alat deteksi kebocoran gas berbasis IoT berhasil diuji coba. Mendeteksi kebocoran dalam waktu kurang dari 5 detik.",
    "Pengalaman magang di startup edtech bikin paham gimana cara kerja industri teknologi di Indonesia.",
    "Hari ini sidang proposal skripsi. Alhamdulillah lancar! Dosen penguji kasih banyak masukan berharga.",
]

TAGS_SHOWCASE = [
    ["flutter", "fastapi", "mobile", "project"],
    ["uiux", "design", "workshop"],
    ["iot", "monitoring", "suhu", "arduino"],
    ["library", "web", "information-system"],
    ["redesign", "website", "ukm", "responsive"],
    ["robotik", "kompetisi", "nasional"],
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

TIPE_NOTIF = [
    "like", "comment", "connection_request", "connection_accepted", "chat",
]

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
    for i, nama in enumerate(NAMA_SKILL, start=1):
        s = await db.skill.create(data={"name": nama})
        skill_records.append(s)
    skill_map = {s.name: s.id for s in skill_records}
    print(f"   {len(skill_records)} skills created")

    print("2. Membuat Users (65 mahasiswa angkatan 28)...")
    user_records = []
    nim_to_user = {}
    photo_idx = 0
    for kode, major in sorted(MAJORS.items()):
        names = NAMA_PER_PRODI[kode]
        for i in range(5):
            nim = f"28{kode}{i+1:04d}"
            user = await db.user.create(data={
                "nim": nim,
                "password": PASSWORD_HASH,
                "full_name": names[i],
                "major": major,
                "bio": random.choice(BIO_MAHASISWA),
                "photo_url": PHOTO_URLS[photo_idx % len(PHOTO_URLS)],
                "social_links": json.dumps({
                    "instagram": f"https://instagram.com/{names[i].lower().replace(' ', '')}",
                    "linkedin": f"https://linkedin.com/in/{names[i].lower().replace(' ', '')}",
                    "github": f"https://github.com/{names[i].lower().replace(' ', '')}",
                }),
                "is_onboarded": True,
            })
            user_records.append(user)
            nim_to_user[nim] = user
            photo_idx += 1
    print(f"   {len(user_records)} users created")

    print("3. Membuat UserSkill...")
    for user in user_records:
        kode = user.nim[2:4]
        skills_for_prodi = SKILL_PER_PRODI.get(kode, [])
        selected = random.sample(skills_for_prodi, min(random.randint(3, 5), len(skills_for_prodi)))
        for skill_name in selected:
            skill_id = skill_map.get(skill_name)
            if skill_id:
                await db.userskill.create(data={
                    "user_id": user.id,
                    "skill_id": skill_id,
                })
    print(f"   UserSkill created for all users")

    print("4. Membuat Experience...")
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
    print(f"   Experience created")

    print("5. Membuat Projects...")
    project_records = []
    selected_projects = random.sample(JUDUL_PROYEK, 10)
    for i, judul in enumerate(selected_projects):
        owner = random.choice(user_records)
        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": judul,
            "description": (
                f"Proyek {judul.lower()} bertujuan untuk mengembangkan solusi digital "
                f"yang dapat membantu mahasiswa dan dosen dalam kegiatan perkuliahan. "
                f"Dibangun menggunakan teknologi terkini dengan tim yang solid."
            ),
            "required_skills": random.sample(NAMA_SKILL, random.randint(2, 4)),
            "status": "open" if i < 6 else ("ongoing" if i < 9 else "completed"),
        })
        project_records.append(project)
    print(f"   {len(project_records)} projects created")

    print("6. Membuat ProjectMember...")
    admin_role = ["Ketua", "Ketua"]
    member_role = ["Anggota", "Anggota", "Anggota"]
    for project in project_records:
        members_in_project = set()
        members_in_project.add(project.owner_id)
        await db.projectmember.create(data={
            "project_id": project.id,
            "user_id": project.owner_id,
            "role": "Ketua",
        })
        potential = [u for u in user_records if u.id != project.owner_id]
        selected_members = random.sample(potential, min(random.randint(2, 4), len(potential)))
        for m in selected_members:
            if m.id not in members_in_project:
                members_in_project.add(m.id)
                await db.projectmember.create(data={
                    "project_id": project.id,
                    "user_id": m.id,
                    "role": "Anggota",
                })
    print(f"   ProjectMember created")

    print("7. Membuat ProjectApplication...")
    for _ in range(20):
        project = random.choice([p for p in project_records if p.status == "open"])
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

    print("8. Membuat Tasks...")
    for project in project_records:
        members = await db.projectmember.find_many(
            where={"project_id": project.id}
        )
        member_ids = [m.user_id for m in members]
        for j in range(random.randint(3, 6)):
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
                "Membuat mockup aplikasi",
                "Optimasi performa",
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

    print("9. Membuat Messages...")
    for _ in range(30):
        sender = random.choice(user_records)
        receiver = random.choice([u for u in user_records if u.id != sender.id])
        await db.message.create(data={
            "content": random.choice([
                "Halo, apa kabar?",
                "Bagaimana progress tugasnya?",
                "Ayo kita diskusikan proyeknya nanti siang.",
                "Sudah lihat desain terbaru?",
                "Ada kendala di bagian backend?",
                "Mantap! Lanjutkan!",
                "Saya sudah push code terbaru.",
                "Tolong review PR saya ya.",
                "Besok ada meeting jam 10 pagi.",
                "File-nya sudah saya upload di drive.",
                "Terima kasih bantuannya!",
                "Sama-sama, senang bisa membantu.",
                "Kapan deadline tugas ini?",
                "Kita harus selesaikan minggu ini.",
                "Apakah ada yang bisa saya bantu?",
            ]),
            "sender_id": sender.id,
            "receiver_id": receiver.id,
        })
    await db.disconnect()
    print(f"   Messages created")

    await db.connect()

    print("10. Membuat Showcase...")
    showcase_records = []
    for _ in range(20):
        author = random.choice(user_records)
        content = random.choice(KONTEN_SHOWCASE)
        media = random.sample(SHOWCASE_MEDIA, random.randint(1, 3))
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
    print(f"   {len(showcase_records)} showcases created")

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
    print(f"   ShowcaseLike created")

    print("12. Membuat ShowcaseComment...")
    for showcase in showcase_records:
        num_comments = random.randint(1, 4)
        for _ in range(num_comments):
            commenter = random.choice(user_records)
            await db.showcasecomment.create(data={
                "showcase_id": showcase.id,
                "user_id": commenter.id,
                "content": random.choice(KOMENTAR),
            })
    print(f"   ShowcaseComment created")

    print("13. Membuat Connection...")
    pairs = set()
    for _ in range(40):
        sender = random.choice(user_records)
        receiver = random.choice([u for u in user_records if u.id != sender.id])
        pair = tuple(sorted((sender.id, receiver.id)))
        if pair not in pairs:
            pairs.add(pair)
            status = random.choices(
                ["pending", "accepted", "rejected"],
                weights=[0.3, 0.6, 0.1]
            )[0]
            await db.connection.create(data={
                "sender_id": sender.id,
                "receiver_id": receiver.id,
                "status": status,
            })
    print(f"   {len(pairs)} connections created")

    print("14. Membuat Notification...")
    for _ in range(30):
        user = random.choice(user_records)
        actor = random.choice([u for u in user_records if u.id != user.id])
        tipe = random.choice(TIPE_NOTIF)
        notif = await db.notification.create(data={
            "user_id": user.id,
            "type": tipe,
            "title": actor.full_name + " " + random.choice(JUDUL_NOTIF),
            "content": actor.full_name + random.choice(ISI_NOTIF),
            "is_read": random.random() > 0.5,
            "link": f"/showcase/{random.choice(showcase_records).id}" if tipe in ["like", "comment"] else "/profile",
        })
    print(f"   Notifications created")

    print("\n✅ SEMUA DUMMY DATA BERHASIL DIISI!")
    print(f"   Users: {len(user_records)}")
    print(f"   Skills: {len(skill_records)}")
    print(f"   Projects: {len(project_records)}")
    print(f"   Showcases: {len(showcase_records)}")

    await db.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
