import '../../domain/entities/color_seed.dart';
import '../../domain/entities/competition.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/explore_repository.dart';

class FakeExploreRepository implements ExploreRepository {
  @override
  List<Project> getProjects() {
    return const [
      Project(
        title: 'Rembugan - Aplikasi Pencari Partner',
        description:
            'Aplikasi mobile untuk mempertemukan mahasiswa yang ingin berkolaborasi dalam proyek teknologi, riset, maupun startup.',
        category: 'Mobile Dev',
        faculty: 'Teknik Informatika',
        postedBy: 'Dede Fernanda',
        posterRole: 'Teknik Informatika',
        avatarUrl: 'https://i.pravatar.cc/100?img=60',
        deadline: '30 Jun 2026',
        university: 'Universitas Nusantara',
        postedAgo: '2 hari lalu',
        totalSlots: 4,
        filledSlots: 2,
        skills: ['Flutter', 'Figma'],
        memberAvatars: [
          'https://i.pravatar.cc/100?img=60',
          'https://i.pravatar.cc/100?img=47',
        ],
        memberNames: ['Dede', 'Raka'],
      ),
      Project(
        title: 'Dashboard Analitik Akademik',
        description:
            'Platform web untuk memvisualisasikan data akademik mahasiswa secara real-time. Membutuhkan developer dashboard dan backend.',
        category: 'Web Dev',
        faculty: 'Sistem Informasi',
        postedBy: 'Sarah Jenkins',
        posterRole: 'Sistem Informasi',
        avatarUrl: 'https://i.pravatar.cc/100?img=47',
        deadline: '15 Jul 2026',
        university: 'Universitas Nusantara',
        postedAgo: '3 hari lalu',
        totalSlots: 5,
        filledSlots: 3,
        skills: ['React', 'Python'],
        memberAvatars: [
          'https://i.pravatar.cc/100?img=47',
          'https://i.pravatar.cc/100?img=33',
          'https://i.pravatar.cc/100?img=12',
        ],
        memberNames: ['Sarah', 'Ahmad', 'Budi'],
      ),
      Project(
        title: 'E-Commerce Redesign App',
        description:
            'Redesign aplikasi e-commerce lokal untuk meningkatkan conversion rate dan user experience secara menyeluruh.',
        category: 'UI/UX Design',
        faculty: 'Desain Komunikasi Visual',
        postedBy: 'Marvin McKinney',
        posterRole: 'DKV',
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        deadline: '20 Aug 2026',
        university: 'Universitas Nusantara',
        postedAgo: '5 hari lalu',
        totalSlots: 3,
        filledSlots: 1,
        skills: ['Figma', 'Flutter'],
        memberAvatars: ['https://i.pravatar.cc/100?img=33'],
        memberNames: ['Marvin'],
      ),
      Project(
        title: 'Sistem Rekomendasi Kampus',
        description:
            'Machine learning model untuk merekomendasikan jurusan berdasarkan minat dan kemampuan calon mahasiswa.',
        category: 'Data Science',
        faculty: 'Teknik Informatika',
        postedBy: 'Cameron Williamson',
        posterRole: 'Teknik Informatika',
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        deadline: '01 Sep 2026',
        university: 'Universitas Nusantara',
        postedAgo: '1 minggu lalu',
        totalSlots: 4,
        filledSlots: 2,
        skills: ['Python', 'React'],
        memberAvatars: [
          'https://i.pravatar.cc/100?img=12',
          'https://i.pravatar.cc/100?img=60',
        ],
        memberNames: ['Cameron', 'Dede'],
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
