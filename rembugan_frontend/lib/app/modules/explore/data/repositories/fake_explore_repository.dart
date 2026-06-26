import '../../domain/entities/competition.dart';
import '../../domain/entities/explore_person.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/explore_repository.dart';

class FakeExploreRepository implements ExploreRepository {
  @override
  Future<({List<Project> projects, int total})> getProjects({int page = 1, int limit = 15}) async {
    return (
      projects: const <Project>[
        Project(
        title: 'Aplikasi Inventaris Lab Vokasi',
        description:
            'Buat aplikasi peminjaman alat lab biar ga pake buku catatan lagi. Tim udah ada 2, butuh 1 Flutter dev + 1 UI designer.',
        postedBy: 'Raka Pratama',
        posterRole: 'Teknik Informatika',
        avatarUrl: 'https://i.pravatar.cc/100?img=47',
        posterId: '1',
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
        postedBy: 'Ahmad Fauzi',
        posterRole: 'Sistem Informasi',
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        posterId: '2',
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
        postedBy: 'Nina Kartika',
        posterRole: 'DKV',
        avatarUrl: 'https://i.pravatar.cc/100?img=55',
        posterId: '3',
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
        postedBy: 'Fitriani Nurul',
        posterRole: 'Ilmu Komputer',
        avatarUrl: 'https://i.pravatar.cc/100?img=60',
        posterId: '4',
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
      ],
      total: 4,
    );
  }

  @override
  Future<List<Competition>> getCompetitions() async {
    return const [];
  }

  @override
  Future<List<ExplorePerson>> getRecommendedPeople() async {
    return const [];
  }

  @override
  Future<List<ExplorePerson>> searchPeople(String query) async {
    return const [];
  }

  @override
  Future<List<String>> getMyOfferingsSkills() async {
    return [];
  }
}
