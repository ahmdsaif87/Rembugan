import '../../domain/entities/color_seed.dart';
import '../../domain/entities/competition.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/explore_repository.dart';

class FakeExploreRepository implements ExploreRepository {
  @override
  List<Project> getProjects() {
    return const [
      Project(
        title: 'Aplikasi Inventaris Lab Vokasi',
        description:
            'Buat aplikasi peminjaman alat lab biar ga pake buku catatan lagi. Tim udah ada 2, butuh 1 Flutter dev + 1 UI designer.',
        category: 'Mobile Dev',
        faculty: 'Teknik Informatika',
        postedBy: 'Raka Pratama',
        posterRole: 'Teknik Informatika',
        avatarUrl: 'https://i.pravatar.cc/100?img=47',
        deadline: '10 Jul 2026',
        university: 'Politeknik Negeri',
        postedAgo: '1 hari lalu',
        totalSlots: 4,
        filledSlots: 2,
        skills: ['Flutter', 'Figma'],
        memberAvatars: [
          'https://i.pravatar.cc/100?img=47',
          'https://i.pravatar.cc/100?img=60',
        ],
        memberNames: ['Raka', 'Dinda'],
      ),
      Project(
        title: 'Website Dashboard Beasiswa',
        description:
            'Kampus butuh dashboard buat tracking pengajuan beasiswa. Stack Laravel + MySQL. Cari 2 backend biar cepet selesai sebelum sidang.',
        category: 'Web Dev',
        faculty: 'Sistem Informasi',
        postedBy: 'Ahmad Fauzi',
        posterRole: 'Sistem Informasi',
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        deadline: '20 Jul 2026',
        university: 'Universitas Nusantara',
        postedAgo: '3 hari lalu',
        totalSlots: 3,
        filledSlots: 1,
        skills: ['Laravel', 'MySQL'],
        memberAvatars: ['https://i.pravatar.cc/100?img=33'],
        memberNames: ['Ahmad'],
      ),
      Project(
        title: 'Desain Ulang Portal Alumni',
        description:
            'Portal alumni kampus tampilannya masih jadul banget. Butuh 1 UI/UX designer buat bikin design system baru + prototype interaktif. Udah ada tim dev tinggal nunggu desain.',
        category: 'UI/UX Design',
        faculty: 'Desain Komunikasi Visual',
        postedBy: 'Nina Kartika',
        posterRole: 'DKV',
        avatarUrl: 'https://i.pravatar.cc/100?img=55',
        deadline: '5 Agt 2026',
        university: 'Universitas Nusantara',
        postedAgo: '2 hari lalu',
        totalSlots: 2,
        filledSlots: 1,
        skills: ['Figma', 'Prototyping'],
        memberAvatars: ['https://i.pravatar.cc/100?img=55'],
        memberNames: ['Nina'],
      ),
      Project(
        title: 'Skripsi — Prediksi Harga Pangan',
        description:
            'Cari 1 teman buat project skripsi bareng. Topik prediksi harga bahan pangan pakai machine learning. Udah dapat dataset dari BPS. Butuh yang paham Python & pandas.',
        category: 'Data Science',
        faculty: 'Ilmu Komputer',
        postedBy: 'Fitriani Nurul',
        posterRole: 'Ilmu Komputer',
        avatarUrl: 'https://i.pravatar.cc/100?img=60',
        deadline: '15 Agt 2026',
        university: 'Universitas Nusantara',
        postedAgo: '6 hari lalu',
        totalSlots: 2,
        filledSlots: 1,
        skills: ['Python', 'Pandas'],
        memberAvatars: [
          'https://i.pravatar.cc/100?img=60',
        ],
        memberNames: ['Fitriani'],
      ),
    ];
  }

  @override
  List<Competition> getCompetitions() {
    return const [
      Competition(
        title: 'Hackathon FTIK 2025',
        caption:
            'Kompetisi pengembangan solusi digital untuk mahasiswa FTIK. Bentuk tim, validasi ide, dan presentasikan MVP terbaikmu.',
        category: 'HACKATHON',
        organizer: 'Himpunan Mahasiswa FTIK',
        deadline: '12 Jun 2026',
        badge: 'Paling Sesuai',
        color: ColorSeed(0xFFFF7043, 0xFFFF4B5F),
        registrationLink: 'https://rembugan.app/lomba/hackathon-ftik-2025',
        campusTag: 'Intra Kampus',
      ),
      Competition(
        title: 'Business Plan Competition - FEB Open',
        caption:
            'Ajang business plan terbuka untuk ide bisnis tahap awal dengan mentor dari praktisi dan akademisi.',
        category: 'BUSINESS PLAN',
        organizer: 'Fakultas Ekonomi dan Bisnis',
        deadline: '30 Jun 2026',
        badge: 'Sangat Sesuai',
        color: ColorSeed(0xFF37D69A, 0xFF10A3A4),
        registrationLink: 'https://rembugan.app/lomba/feb-open',
        campusTag: 'Intra Kampus',
      ),
      Competition(
        title: 'GEMASTIK XVII - Data Mining',
        caption:
            'Seleksi tim data mining untuk GEMASTIK dengan fokus eksplorasi data, pemodelan, dan komunikasi insight.',
        category: 'CODING',
        organizer: 'Kemendikbudristek',
        deadline: '28 Jul 2026',
        badge: 'Sesuai untuk Anda',
        color: ColorSeed(0xFF6A8DFF, 0xFF4164EA),
        registrationLink: 'https://rembugan.app/lomba/gemastik-data-mining',
        campusTag: 'Nasional',
      ),
      Competition(
        title: 'UI/UX Design Jam - INOVASI 2025',
        caption:
            'Tantangan desain produk digital cepat untuk memecahkan masalah layanan kampus dengan riset ringkas dan prototipe.',
        category: 'DESIGN',
        organizer: 'BEM Universitas Nusantara',
        deadline: '8 Jun 2026',
        badge: 'Segera',
        color: ColorSeed(0xFF7A63F1, 0xFFC43DDC),
        registrationLink: 'https://rembugan.app/lomba/inovasi-uiux',
        campusTag: 'Intra Kampus',
      ),
      Competition(
        title: 'EduTech Innovation Challenge',
        caption:
            'Kompetisi inovasi teknologi pendidikan untuk tim lintas jurusan yang ingin membangun solusi pembelajaran.',
        category: 'IDEATION',
        organizer: 'Pusat Inovasi Kampus',
        deadline: '18 Jul 2026',
        badge: 'Baru',
        color: ColorSeed(0xFF4C7DFF, 0xFF3156E8),
        registrationLink: 'https://rembugan.app/lomba/edutech-challenge',
        campusTag: 'Nasional',
      ),
    ];
  }
}
