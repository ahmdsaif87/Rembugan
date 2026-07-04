import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_client.dart';
import '../../explore/domain/entities/competition.dart';
import '../../explore/domain/entities/feed_showcase.dart';
import '../../explore/domain/entities/project.dart';
import '../../explore/domain/repositories/explore_repository.dart';

class RecommendedPerson {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final String matchLabel;
  final Rx<String?> connectionStatus;

  RecommendedPerson({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
    String? connectionStatus,
  }) : connectionStatus = Rx<String?>(connectionStatus);
}

class HomeController extends GetxController {
  final activeTab = 0.obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final recommendedProjects = <Project>[].obs;
  final recommendedCompetitions = <Competition>[].obs;
  final recommendedPeople = <RecommendedPerson>[].obs;

  final showcases = <FeedShowcase>[].obs;
  final isLoadingMore = false.obs;
  int _showcasePage = 1;
  bool _hasNextPage = true;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadRecommendations();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll < 300) {
      onScroll(maxScroll, currentScroll);
    }
  }

  void setTab(int index) {
    if (activeTab.value == index) return;
    activeTab.value = index;
    showcases.clear();
    _showcasePage = 1;
    _hasNextPage = true;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    if (index == 1) {
      _loadFollowingFeed();
    } else {
      _loadForYouFeed();
    }
  }

  void onScroll(double maxScroll, double currentScroll) {
    if (!_hasNextPage || isLoadingMore.value) return;
    if (maxScroll - currentScroll < 300) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasNextPage) return;
    isLoadingMore.value = true;
    try {
      _showcasePage++;
      final repo = Get.find<ExploreRepository>();
      final result = activeTab.value == 1
          ? await repo.getFollowingShowcases(page: _showcasePage, limit: 10)
          : await repo.getShowcases(page: _showcasePage, limit: 10);
      showcases.addAll(result.showcases);
      _hasNextPage = result.hasNext;
    } catch (e) {
      _showcasePage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void loadRecommendations() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      final repo = Get.find<ExploreRepository>();

      final projectResult = await repo.getProjects();
      final competitions = await repo.getCompetitions();
      final people = await repo.getRecommendedPeople();
      final showcaseResult = await repo.getShowcases(page: 1, limit: 10);

      recommendedProjects.assignAll(projectResult.projects);
      recommendedCompetitions.assignAll(competitions);
      recommendedPeople.assignAll(people.map((p) => RecommendedPerson(
        id: p.id,
        name: p.name,
        role: p.role,
        avatarUrl: p.avatarUrl,
        tags: p.tags,
        matchLabel: p.matchLabel,
      )));
      showcases.assignAll(showcaseResult.showcases);
      _showcasePage = 1;
      _hasNextPage = showcaseResult.hasNext;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data. Periksa koneksi kamu.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadForYouFeed() async {
    try {
      final repo = Get.find<ExploreRepository>();
      final result = await repo.getShowcases(page: 1, limit: 10);
      showcases.assignAll(result.showcases);
      _showcasePage = 1;
      _hasNextPage = result.hasNext;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data. Periksa koneksi kamu.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFollowingFeed() async {
    try {
      final repo = Get.find<ExploreRepository>();
      final result = await repo.getFollowingShowcases(page: 1, limit: 10);
      showcases.assignAll(result.showcases);
      _showcasePage = 1;
      _hasNextPage = result.hasNext;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data. Periksa koneksi kamu.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFollowPerson(RecommendedPerson person) async {
    if (person.connectionStatus.value != null) return;
    try {
      final api = Get.find<ApiClient>();
      await api.post('/connections/send/${person.id}');
      person.connectionStatus.value = 'pending';
      recommendedPeople.refresh();
    } catch (_) {}
  }

  Future<void> toggleLike(FeedShowcase showcase) async {
    try {
      final api = Get.find<ApiClient>();
      if (showcase.likedByMe) {
        await api.delete('/showcase/${showcase.id}/like');
      } else {
        await api.post('/showcase/${showcase.id}/like');
      }
      showcase.likedByMe = !showcase.likedByMe;
      if (showcase.likedByMe) {
        showcase.likesCount++;
      } else {
        showcase.likesCount--;
      }
      showcases.refresh();
    } catch (_) {}
  }
}
