import asyncio
import random
import json
from datetime import datetime, timedelta
from prisma import Prisma
from app.core.security import hash_password

PASSWORD_HASH = hash_password("00000000")

MAJORS = {
    "01": "D3 Akuntansi",
    "02": "D3 Keperawatan",
    "03": "D3 Teknik Mesin",
    "04": "D3 Teknik Komputer",
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
    "06": ["Umar Zulkarnain", "Vina Violita", "Wahyu Nugroho", "Xena Marisa", "Yudi Permana"],
    "07": ["Zahra Almira", "Agus Wijaya", "Bella Octavia", "Candra Kusuma", "Dinda Kirana"],
    "08": ["Eka Pratiwi", "Farhan Kurniawan", "Gina Sabrina", "Hafiz Ramadhan", "Intan Permata"],
    "09": ["Jefri Kurniawan", "Kiki Amalia", "Lukman Hakim", "Mira Soraya", "Nizar Rahman"],
    "10": ["Olivia Hernanda", "Panji Saputra", "Queen Auryn", "Raka Maulana", "Siska Melina"],
    "11": ["Titis Widya", "Ujang Permana", "Vera Anatasha", "Winda Sari", "Xavier Tama"],
    "21": ["Yoga Pratama", "Zidan Alfariz", "Alifia Rahman", "Bima Sakti", "Cinta Laura"],
    "22": ["Dimas Ardianto", "Elsa Safira", "Fikri Haikal", "Geby Maharani", "Haris Munandar"],
}

NIM_YEARS = ["23", "24", "25"]

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

SKILL_PER_PRODI = {
    "01": ["Microsoft Excel", "Akuntansi", "MYOB", "SAP", "Accurate"],
    "02": ["Keperawatan", "Kesehatan Masyarakat", "Gizi"],
    "03": ["Teknik Mesin", "AutoCAD", "SolidWorks", "CNC", "PLC"],
    "04": ["Python", "Java", "JavaScript", "PHP", "Laravel", "React JS", "Node.js", "SQL", "Git"],
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

# (title, major_code, description)
PROJECT_TITLES = [
    # D3 Akuntansi (01)
    ("Analisis Laporan Keuangan Perusahaan Manufaktur", "01", "Menganalisis laporan keuangan tahunan perusahaan manufaktur untuk menilai profitabilitas, likuiditas, dan solvabilitas sebagai dasar pengambilan keputusan investasi."),
    ("Audit Kepatuhan Internal Operasional Toko Retail", "01", "Melakukan audit internal terhadap prosedur operasional toko retail untuk memastikan kepatuhan terhadap standar akuntansi dan regulasi yang berlaku."),
    ("Penyusunan Anggaran dan Evaluasi Kinerja UMKM Sektor Kuliner", "01", "Membantu UMKM sektor kuliner menyusun anggaran tahunan serta mengevaluasi kinerja keuangan melalui analisis varians dan rasio keuangan."),

    # D3 Keperawatan (02)
    ("Program Edukasi Kesehatan Reproduksi Remaja di Sekolah Menengah", "02", "Merancang dan mengimplementasikan program edukasi kesehatan reproduksi bagi remaja di sekolah menengah untuk meningkatkan pengetahuan dan perilaku sehat."),
    ("Pencegahan Stunting melalui Program Gizi Seimbang pada Balita", "02", "Mengembangkan program intervensi gizi seimbang untuk mencegah stunting pada balita di daerah dengan prevalensi gizi buruk yang tinggi."),
    ("Manajemen Asuhan Keperawatan pada Pasien Diabetes Melitus Tipe 2", "02", "Menyusun dan menerapkan rencana asuhan keperawatan komprehensif bagi pasien diabetes melitus tipe 2 di rumah sakit umum daerah."),

    # D3 Teknik Mesin (03)
    ("Perancangan Sistem Pendingin Ruangan Hemat Energi untuk Gedung Perkantoran", "03", "Merancang sistem HVAC hemat energi dengan memanfaatkan sirkulasi udara alami dan material insulasi termal untuk mengurangi konsumsi listrik."),
    ("Rancang Bangun Mesin Pencacah Sampah Organik Rumah Tangga", "03", "Mendesain dan membangun mesin pencacah sampah organik skala rumah tangga yang ergonomis dan terjangkau untuk mendukung program bank sampah."),
    ("Optimasi Proses Produksi pada Industri Manufaktur Komponen Otomotif", "03", "Mengidentifikasi dan mengoptimalkan parameter proses produksi pada lini manufaktur komponen otomotif untuk meningkatkan efisiensi dan mengurangi reject."),

    # D3 Teknik Komputer (04)
    ("Sistem Monitoring Jaringan Komputer Berbasis IoT untuk Kampus", "04", "Membangun sistem monitoring perangkat jaringan secara real-time menggunakan sensor IoT dan platform dashboard visual."),
    ("Rancang Bangun Sistem Keamanan Rumah Pintar dengan Sensor Gerak", "04", "Merancang sistem keamanan rumah otomatis berbasis mikrokontroler yang terintegrasi dengan notifikasi smartphone dan sensor PIR."),

    # D3 DKV (06)
    ("Perancangan Identitas Visual Brand untuk Produk Kerajinan Lokal", "06", "Merancang identitas visual komprehensif berupa logo, tipografi, dan palette warna untuk brand produk kerajinan tangan lokal."),
    ("Desain Kemasan Produk UMKM Ramah Lingkungan dan Estetis", "06", "Mendesain kemasan produk UMKM yang menarik secara visual dan ramah lingkungan menggunakan material daur ulang dan tinta nabati."),
    ("Branding dan Promosi Destinasi Wisata Alam melalui Media Visual", "06", "Mengembangkan strategi branding visual untuk destinasi wisata alam melalui desain poster, konten media sosial, dan video promosi."),

    # D3 Perhotelan (07)
    ("Analisis Service Quality Hotel Berdasarkan Ulasan Tamu di Platform Online", "07", "Menganalisis kualitas pelayanan hotel dengan metode text mining pada ulasan tamu di platform pemesanan online untuk rekomendasi perbaikan."),
    ("Strategi Digital Marketing untuk Meningkatkan Tingkat Hunian Hotel", "07", "Merancang strategi pemasaran digital terpadu yang mencakup SEO, social media marketing, dan email campaign untuk meningkatkan okupansi hotel."),

    # D3 Farmasi (08)
    ("Formulasi dan Uji Stabilitas Sediaan Kosmesetikal Skincare Alami", "08", "Mengembangkan formulasi sediaan kosmesetikal berbahan aktif alami serta menguji stabilitas fisik dan kimia selama penyimpanan."),
    ("Analisis Kualitatif dan Kuantitatif Bahan Kimia Obat pada Jamu Tradisional", "08", "Mengidentifikasi dan mengukur kadar bahan kimia obat (BKO) yang sering ditambahkan pada jamu tradisional menggunakan metode kromatografi."),
    ("Uji Efektivitas Antibakteri Ekstrak Daun Sirih terhadap Bakteri Penyebab Jerawat", "08", "Menguji daya hambat ekstrak daun sirih (Piper betle) terhadap pertumbuhan bakteri Propionibacterium acnes secara in vitro."),

    # D4 Teknik Informatika (09)
    ("Pengembangan Aplikasi Manajemen Inventaris Laboratorium Berbasis Mobile", "09", "Mengembangkan aplikasi mobile untuk mencatat, melacak, dan mengelola inventaris alat dan bahan laboratorium secara real-time."),
    ("Dashboard Monitoring Akademik dan Kinerja Mahasiswa Berbasis Web", "09", "Membangun dashboard interaktif untuk memonitoring IPK, kehadiran, dan capaian akademik mahasiswa secara visual."),
    ("Sistem Informasi Arsip Digital Surat Menyurat untuk Tata Usaha Kampus", "09", "Merancang sistem informasi arsip digital untuk pengelolaan surat masuk dan keluar di lingkungan tata usaha perguruan tinggi."),

    # D4 Akuntansi Sektor Publik (10)
    ("Analisis Kinerja Keuangan Pemerintah Daerah berdasarkan Rasio Fiskal", "10", "Menganalisis kinerja keuangan pemerintah daerah provinsi menggunakan rasio kemandirian, efektivitas PAD, dan rasio belanja modal."),
    ("Audit Laporan Keuangan Sektor Publik pada Badan Layanan Umum", "10", "Melaksanakan audit atas laporan keuangan BLUD untuk menilai kewajaran penyajian dan kepatuhan terhadap standar akuntansi pemerintahan."),

    # D4 Kebidanan (11)
    ("Program ANC Terpadu untuk Pencegahan Komplikasi Kehamilan Risiko Tinggi", "11", "Mengembangkan program antenatal care terpadu yang melibatkan deteksi dini faktor risiko dan edukasi persiapan persalinan."),
    ("Edukasi Pemberian ASI Eksklusif dan Pendampingan Ibu Menyusui di Masa Pandemi", "11", "Merancang program edukasi dan pendampingan menyusui berbasis komunitas untuk meningkatkan cakupan ASI eksklusif."),

    # S1 Teknik Mesin (21)
    ("Analisis Kekuatan Material Komposit Serat Alam untuk Rangka Kendaraan Ringan", "21", "Menguji dan menganalisis kekuatan tarik dan impak material komposit serat alam sebagai alternatif rangka kendaraan ringan yang lebih ringan dan murah."),
    ("Perancangan Rangka Mesin Produksi Tepat Guna untuk Industri Kecil", "21", "Merancang dan menghitung kekuatan rangka mesin produksi tepat guna dengan metode elemen hingga (FEA) untuk menjamin keamanan operasional."),

    # S1 Manajemen (22)
    ("Analisis Pengaruh Brand Image dan Kualitas Produk terhadap Keputusan Pembelian", "22", "Meneliti pengaruh citra merek dan kualitas produk terhadap keputusan pembelian konsumen pada industri fashion lokal."),
    ("Strategi Peningkatan Loyalitas Pelanggan melalui Program Reward pada E-commerce", "22", "Merancang strategi loyalitas pelanggan berbasis program reward dan personalized experience untuk meningkatkan retensi pada platform e-commerce."),
]

SKILLS_BY_MAJOR = {
    "01": [
        ["Microsoft Excel", "Akuntansi", "MYOB"],
        ["Analisis Data", "SPSS", "STATA"],
        ["Akuntansi", "SAP", "Manajemen Keuangan"],
        ["Microsoft Excel", "Analisis Laporan", "Akuntansi Biaya"],
    ],
    "02": [
        ["Keperawatan", "Kesehatan Masyarakat", "Gizi"],
        ["Manajemen Pasien", "Dokumentasi Medis", "Promosi Kesehatan"],
        ["Keperawatan Dasar", "Farmakologi", "Etika Keperawatan"],
    ],
    "03": [
        ["AutoCAD", "SolidWorks", "Teknik Mesin"],
        ["CNC", "PLC", "Material Testing"],
        ["AutoCAD", "Mekanika Teknik", "CAD 3D"],
    ],
    "04": [
        ["Python", "IoT", "Arduino"],
        ["Jaringan Komputer", "Raspberry Pi", "Sensor"],
        ["Python", "C++", "Embedded System"],
    ],
    "06": [
        ["Figma", "Adobe Illustrator", "UI/UX Design"],
        ["Canva", "CorelDRAW", "Branding"],
        ["Adobe Photoshop", "Tipografi", "Desain Grafis"],
    ],
    "07": [
        ["Housekeeping", "Front Office", "Hotel Management"],
        ["Food & Beverage", "Event Management", "Pelayanan Tamu"],
        ["Manajemen Perhotelan", "Reservasi", "Customer Service"],
    ],
    "08": [
        ["Farmasi", "Kimia Analisis", "Mikrobiologi"],
        ["Formulasi Obat", "Analisis BKO", "Kromatografi"],
        ["Farmasetika", "Kimia Farmasi", "Farmakologi"],
    ],
    "09": [
        ["Flutter", "Dart", "Firebase"],
        ["React JS", "Node.js", "PostgreSQL"],
        ["Python", "FastAPI", "Next.js"],
        ["JavaScript", "Laravel", "MySQL"],
    ],
    "10": [
        ["Microsoft Excel", "Akuntansi Sektor Publik", "SAP"],
        ["Analisis Laporan", "Audit", "Manajemen Keuangan"],
        ["SPSS", "Statistik", "Akuntansi Pemerintahan"],
    ],
    "11": [
        ["Kebidanan", "Keperawatan Ibu Anak", "Gizi"],
        ["ANC", "Persalinan", "Kesehatan Reproduksi"],
        ["Kebidanan Komunitas", "Imunisasi", "ASI Eksklusif"],
    ],
    "21": [
        ["AutoCAD", "SolidWorks", "Teknik Mesin"],
        ["Material Komposit", "CAD 3D", "Analisis Struktur"],
        ["Mekanika Teknik", "FEA", "Perancangan Mesin"],
    ],
    "22": [
        ["Manajemen Keuangan", "Digital Marketing", "Analisis Data"],
        ["Microsoft Excel", "Branding", "Customer Relationship"],
        ["Manajemen SDM", "Pemasaran Digital", "E-commerce"],
    ],
}

KONTEN_SHOWCASE = [
    "Alhamdulillah, proyek aplikasi manajemen tugas akhirnya selesai! Dibangun dengan Flutter dan FastAPI.",
    "Baru selesai mengikuti workshop UI/UX Design selama 2 minggu. Banyak banget ilmu baru!",
    "Presentasi proyek IoT hari ini berjalan lancar. Alat monitoring suhu ruangan berhasil real-time.",
    "Bangga banget bisa berkontribusi dalam proyek sistem informasi perpustakaan digital untuk kampus.",
    "Baru aja menyelesaikan desain ulang website UKM binaan. Tampilan jadi lebih modern dan responsif!",
    "Ikut kompetisi robotik tingkat nasional dan berhasil masuk 10 besar. Pengalaman yang luar biasa!",
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

TIPE_NOTIF = ["like", "comment", "connection_request", "connection_accepted", "chat"]
JUDUL_NOTIF = ["Menyukai showcase Anda", "Memberi komentar pada showcase Anda", "Mengirimkan permintaan koneksi", "Menerima permintaan koneksi Anda", "Mengirimkan pesan baru"]
ISI_NOTIF = [" menyukai postingan showcase Anda.", " berkomentar pada postingan Anda.", " ingin terhubung dengan Anda.", " telah menerima permintaan koneksi Anda.", " mengirimkan pesan baru untuk Anda."]



def generate_nim(year_prefix: str, major_code: str, seq: int) -> str:
    return f"{year_prefix}{major_code}{seq:02d}"


async def main():
    db = Prisma()
    await db.connect()

    # ── 0. Keep Saifi & Dede ──
    print("0. Menyimpan user yang dipertahankan...")
    saifi = await db.user.find_first(where={"nim": "23090112"})
    dede = await db.user.find_first(where={"nim": "23090122"})
    keep_ids = set()
    if saifi:
        keep_ids.add(saifi.id)
        print(f"   → Ahmad Saifi ({saifi.id})")
    if dede:
        keep_ids.add(dede.id)
        print(f"   → Dede Fernanda ({dede.id})")

    # ── 1. Hapus semua data kecuali user yang dipertahankan ──
    print("\n1. Membersihkan database (kecuali Saifi & Dede)...")
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

    # ── 3. Users – 60 mahasiswa angkatan 23/24/25 ──
    print("3. Membuat 60 Users (NIM 23/24/25, password 00000000)...")
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
    nim_to_user = {}

    for major_code, major_name in sorted(MAJORS.items()):
        names = NAMA_PER_PRODI[major_code]
        for i in range(5):
            year_prefix = NIM_YEARS[i % 3]
            nim = generate_nim(year_prefix, major_code, i + 1)
            user = await db.user.create(data={
                "nim": nim,
                "password": PASSWORD_HASH,
                "full_name": names[i],
                "major": major_name,
                "bio": random.choice(BIO_MAHASISWA),
                "photo_url": all_photo_urls[photo_idx % len(all_photo_urls)],
                "cover_url": random.choice(all_cover_urls),
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

    # Ensure keepers get their UserSkill assigned (add to user_records for skill loop)
    if saifi:
        existing = await db.user.find_first(where={"nim": "23090112"})
        if existing:
            user_records.append(existing)
        else:
            s = await db.user.create(data={
                "nim": "23090112",
                "password": PASSWORD_HASH,
                "full_name": "Ahmad Saifi Khayatu Ulumuddin",
                "handle": "ahmadsaifi",
                "major": "D4 Teknik Informatika",
                "bio": "Mahasiswa D4 Teknik Informatika yang suka ngoding.",
                "photo_url": saifi.photo_url or all_photo_urls[0],
                "cover_url": random.choice(all_cover_urls),
                "social_links": saifi.social_links or "{}",
                "is_onboarded": True,
            })
            user_records.append(s)
            print("   → Ahmad Saifi dibuat ulang")
    if dede:
        existing = await db.user.find_first(where={"nim": "23090122"})
        if existing:
            user_records.append(existing)
        else:
            d = await db.user.create(data={
                "nim": "23090122",
                "password": PASSWORD_HASH,
                "full_name": "Dede Fernanda",
                "handle": "dedefernanda",
                "major": "D4 Teknik Informatika",
                "bio": "Mahasiswa D4 Teknik Informatika.",
                "photo_url": dede.photo_url or all_photo_urls[1],
                "cover_url": random.choice(all_cover_urls),
                "social_links": dede.social_links or "{}",
                "is_onboarded": True,
            })
            user_records.append(d)
            print("   → Dede Fernanda dibuat ulang")

    print(f"   {len(user_records)} users total\n")

    # ── 4. UserSkill ──
    print("4. Membuat UserSkill...")
    for user in user_records:
        kode = user.nim[2:4]
        skills_for_prodi = SKILL_PER_PRODI.get(kode, [])
        if skills_for_prodi:
            selected = random.sample(skills_for_prodi, min(random.randint(3, 5), len(skills_for_prodi)))
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
    print("6. Membuat 30 Projects dengan smart category...")

    # Group users by major code from NIM
    prodi_users: dict[str, list] = {}
    for u in user_records:
        kode = u.nim[2:4]
        prodi_users.setdefault(kode, []).append(u)

    project_records = []
    for title, major_code, description in PROJECT_TITLES:
        pool = prodi_users.get(major_code, user_records)
        owner = random.choice(pool)
        total_slots = random.randint(3, 5)
        deadline = datetime.now() + timedelta(days=random.randint(7, 90))

        major_skills = SKILLS_BY_MAJOR.get(major_code, [["Microsoft Excel", "Analisis Data", "Manajemen"]])
        skills = random.choice(major_skills)

        project = await db.project.create(data={
            "owner_id": owner.id,
            "title": title,
            "description": description,
            "required_skills": skills,
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
