import 'package:get/get.dart';
import '../../explore/domain/entities/project.dart';
import '../../explore/domain/entities/competition.dart';
import '../../explore/data/repositories/fake_explore_repository.dart';
import '../../../core/theme/theme.dart';

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

  final recommendedProjects = <Project>[].obs;
  final recommendedCompetitions = <Competition>[].obs;
  final recommendedPeople = <RecommendedPerson>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecommendations();
  }

  void setTab(int index) {
    activeTab.value = index;
  }

  void _loadRecommendations() {
    final repo = FakeExploreRepository();

    // Load projects for recommendations
    recommendedProjects.assignAll(repo.getProjects());

    // Load competitions for recommendations
    recommendedCompetitions.assignAll(repo.getCompetitions());

    // Create recommended people with reactive following state
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
  }

  void toggleFollowPerson(RecommendedPerson person) {
    person.isFollowing.toggle();
    Get.snackbar(
      person.isFollowing.value ? 'Mengikuti' : 'Batal Mengikuti',
      person.isFollowing.value
          ? 'Kamu sekarang mengikuti ${person.name}.'
          : 'Kamu berhenti mengikuti ${person.name}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: person.isFollowing.value
          ? AppColors.success50
          : AppColors.white,
      colorText: person.isFollowing.value
          ? AppColors.success700
          : AppColors.textPrimary,
      duration: const Duration(seconds: 2),
    );
  }
}
