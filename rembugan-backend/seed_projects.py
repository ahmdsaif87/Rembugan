import asyncio
import random
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.constants import PJ_OPEN, PJ_ONGOING


PROJECT_TITLES = [
    "Aplikasi Monitoring Kinerja Karyawan",
    "Sistem Informasi Desa Digital",
    "Platform Donasi Online untuk Yayasan",
    "Aplikasi Mobile Tracking Kesehatan",
    "Website Manajemen Event Kampus",
    "Sistem Antrian Online Rumah Sakit",
    "Aplikasi Pencatatan Keuangan Pribadi",
    "Platform Belajar Online Interaktif",
    "Sistem Informasi Akademik Berbasis Web",
    "Aplikasi Mobile Pemesanan Tiket",
    "Dashboard Monitoring Cuaca IoT",
    "Sistem Pendukung Keputusan Pemilihan Prodi",
    "Aplikasi Manajemen Inventaris Gudang",
    "Platform Jual Beli Barang Bekas Mahasiswa",
    "Sistem Rekomendasi Tempat Wisata",
    "Aplikasi Mobile Pembelajaran Bahasa Inggris",
    "Website Portfolio Dosen",
    "Sistem Informasi Lowongan Magang",
    "Aplikasi Catatan Kehamilan Digital",
    "Platform Konsultasi Dokter Online",
    "Sistem Manajemen Aset Laboratorium",
    "Aplikasi Mobile Absensi Berbasis QR Code",
    "Website Katalog Produk UMKM",
    "Sistem Informasi Beasiswa Mahasiswa",
    "Aplikasi Pembelajaran Coding untuk Pemula",
    "Platform Diskusi Tugas Akhir",
    "Sistem Monitoring Proyek Tugas Akhir",
    "Aplikasi Mobile Pencari Kost",
    "Website Galeri Karya Mahasiswa",
    "Sistem Informasi Jadwal Perkuliahan",
]

DESCRIPTIONS = [
    "Mengembangkan solusi berbasis teknologi untuk mempermudah proses bisnis di era digital.",
    "Proyek kolaboratif untuk menciptakan produk digital yang bermanfaat bagi masyarakat luas.",
    "Membangun platform yang dapat membantu mahasiswa dalam kegiatan akademik dan non-akademik.",
    "Solusi inovatif berbasis mobile dan web untuk menjawab tantangan di lingkungan kampus.",
    "Proyek pengembangan sistem informasi yang terintegrasi dan user-friendly.",
]

REQUIRED_SKILL_SETS = [
    ["Flutter", "Dart", "Firebase"],
    ["React JS", "Node.js", "PostgreSQL"],
    ["Laravel", "PHP", "MySQL"],
    ["Python", "FastAPI", "React JS"],
    ["Flutter", "Node.js", "MongoDB"],
    ["Next.js", "Prisma ORM", "PostgreSQL"],
    ["React Native", "Firebase", "Git"],
    ["UI/UX Design", "Figma", "Adobe Illustrator"],
    ["JavaScript", "React JS", "CSS"],
    ["Python", "Django", "PostgreSQL"],
]


async def main():
    db = Prisma()
    await db.connect()

    print("1. Memperbaiki proyek existing yang penuh tapi masih 'open'...")
    projects = await db.project.find_many(
        where={"status": PJ_OPEN},
        include={"members": True},
    )
    fixed_count = 0
    for p in projects:
        member_count = len(p.members) if p.members else 0
        if p.total_slots is not None and member_count >= p.total_slots:
            await db.project.update(
                where={"id": p.id},
                data={"status": PJ_ONGOING},
            )
            print(f"   → Proyek #{p.id} '{p.title}': {member_count}/{p.total_slots} → status 'ongoing'")
            fixed_count += 1
    print(f"   {fixed_count} proyek diperbaiki.\n")

    print("2. Mengambil semua user untuk dijadikan owner...")
    users = await db.user.find_many()
    if not users:
        print("   ❌ Tidak ada user di database. Jalankan seed.py dulu.")
        await db.disconnect()
        return
    print(f"   {len(users)} user tersedia.\n")

    print("3. Membuat 30 proyek baru dengan status 'open'...")
    created_count = 0
    for title in PROJECT_TITLES:
        owner = random.choice(users)
        total_slots = random.randint(3, 5)
        skills = random.choice(REQUIRED_SKILL_SETS)
        deadline = datetime.now() + timedelta(days=random.randint(7, 90))
        desc = random.choice(DESCRIPTIONS)
        if random.random() > 0.5:
            desc += f" Proyek ini membutuhkan tim dengan keahlian di bidang {', '.join(skills)}."

        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": title,
            "description": desc,
            "required_skills": skills,
            "status": PJ_OPEN,
            "deadline": deadline,
            "total_slots": total_slots,
        })

        # Add owner as "Ketua" member
        await db.projectmember.create(data={
            "project_id": project.id,
            "user_id": owner.id,
            "role": "Ketua",
        })

        # Add 1-2 random members (filling but NOT reaching total_slots)
        potential_members = [u for u in users if u.id != owner.id]
        num_members = random.randint(1, min(2, total_slots - 2))
        if num_members > 0 and potential_members:
            selected = random.sample(potential_members, min(num_members, len(potential_members)))
            for m in selected:
                await db.projectmember.create(data={
                    "project_id": project.id,
                    "user_id": m.id,
                    "role": "Anggota",
                })

        created_count += 1
        if created_count % 10 == 0:
            print(f"   {created_count}/30 proyek dibuat...")

    print(f"\n   ✅ {created_count} proyek baru berhasil dibuat!\n")

    print("4. Verifikasi: proyek 'open' dengan total_slots vs filled_slots...")
    open_projects = await db.project.find_many(
        where={"status": PJ_OPEN},
        include={"members": True},
    )
    for p in open_projects:
        filled = len(p.members) if p.members else 0
        if p.total_slots is not None and filled >= p.total_slots:
            print(f"   ⚠️  Proyek #{p.id} '{p.title}': {filled}/{p.total_slots} — masih 'open'!")
    print("   Verifikasi selesai.\n")

    print("✅ SELESAI!")
    print(f"   Total proyek open sekarang: {len(open_projects)}")

    await db.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
