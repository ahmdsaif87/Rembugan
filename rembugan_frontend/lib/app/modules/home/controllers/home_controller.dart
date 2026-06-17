import 'package:get/get.dart';
import '../../explore/domain/entities/project.dart';
import '../../explore/domain/entities/competition.dart';
import '../../explore/domain/repositories/explore_repository.dart';
import 'package:rembugan/app/core/widgets/app_toast.dart';

class RecommendedPerson {
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final String matchLabel;
  final RxBool isFollowing;

  RecommendedPerson({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
    bool isFollowing = false,
  }) : isFollowing = isFollowing.obs;
}

class HomeController extends GetxController {
  final activeTab = 0.obs; // 0 for 'Untukmu', 1 for 'Mengikuti'
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final recommendedProjects = <Project>[].obs;
  final recommendedCompetitions = <Competition>[].obs;
  final recommendedPeople = <RecommendedPerson>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecommendations();
  }

  void setTab(int index) {
    activeTab.value = index;
  }

  void loadRecommendations() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final repo = Get.find<ExploreRepository>();

      final projectResult = await repo.getProjects();
      recommendedProjects.assignAll(projectResult.projects);
      final competitions = await repo.getCompetitions();
      recommendedCompetitions.assignAll(competitions);
      recommendedPeople.assignAll([
        RecommendedPerson(
          name: 'Dede Fernanda',
          role: 'Flutter Developer',
          avatarUrl: 'https://i.pravatar.cc/100?img=60',
          tags: ['Flutter', 'Dart', 'Figma'],
          matchLabel: 'Kecocokan 95%',
        ),
        RecommendedPerson(
          name: 'Raka Pratama',
          role: 'UI/UX Designer',
          avatarUrl: 'https://i.pravatar.cc/100?img=47',
          tags: ['Figma', 'Research', 'Branding'],
          matchLabel: 'Kecocokan 88%',
        ),
        RecommendedPerson(
          name: 'Sarah Jenkins',
          role: 'Backend Developer',
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
          tags: ['FastAPI', 'PostgreSQL', 'Docker'],
          matchLabel: 'Kecocokan 92%',
        ),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data. Periksa koneksi kamu.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFollowPerson(RecommendedPerson person) {
    person.isFollowing.toggle();
    AppToast.info(
      person.isFollowing.value
          ? 'Kamu sekarang mengikuti ${person.name}.'
          : 'Kamu berhenti mengikuti ${person.name}.',
      title: person.isFollowing.value ? 'Mengikuti' : 'Batal Mengikuti',
    );
  }
}
