import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/entities/competition.dart';
import '../domain/entities/explore_person.dart';
import '../domain/entities/explore_tab.dart';
import '../domain/entities/project.dart';
import '../domain/repositories/explore_repository.dart';

class ExploreController extends GetxController {
  ExploreController(this._repository);

  final searchTextController = TextEditingController();
  final projectScrollController = ScrollController();
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  var projectPage = 1;
  var projectTotalAvailable = 0;
  bool get hasMoreProjects => projectPage * 15 < projectTotalAvailable;

  @override
  void onClose() {
    _searchDebounce.dispose();
    searchTextController.dispose();
    projectScrollController.dispose();
    super.onClose();
  }

  final ExploreRepository _repository;

  final activeTab = ExploreTab.project.obs;

  // Dynamic filter observables
  final selectedSort = 'Paling relevan'.obs;
  final selectedFaculty = 'Semua jurusan'.obs;
  final selectedCategory = 'Semua kategori'.obs;
  final selectedSkill = 'Semua skill'.obs;
  final selectedDeadline = 'Semua deadline'.obs;
  final selectedSlot = 'Semua slot'.obs;
  final selectedAvailability = 'Terbuka kolaborasi'.obs;

  final projects = <Project>[].obs;
  final filteredProjects = <Project>[].obs;

  final competitions = <Competition>[].obs;
  final filteredCompetitions = <Competition>[].obs;

  final searchQuery = ''.obs;

  final people = <ExplorePerson>[].obs;
  final filteredPeople = <ExplorePerson>[].obs;
  final _savedRecommendedPeople = <ExplorePerson>[];

  final sortOptions = const ['Terbaru', 'Terpopuler', 'Paling Relevan'];
  final skillOptions = const [
    'React',
    'Flutter',
    'Figma',
    'Python',
    'Node.js',
    'Kotlin',
  ];

  late final Worker _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    projectScrollController.addListener(_onProjectScroll);
    _searchDebounce = debounce<String>(
      searchQuery,
      (_) => _onSearchChanged(),
      time: const Duration(milliseconds: 300),
    );
    loadExploreData();
  }

  void _onSearchChanged() {
    final query = searchQuery.value;
    if (activeTab.value == ExploreTab.people && query.isNotEmpty) {
      _searchPeople();
    } else {
      applyFilters();
    }
  }

  void _searchPeople() async {
    final query = searchQuery.value;
    if (query.isEmpty) {
      people.assignAll(_savedRecommendedPeople);
      applyFilters();
      return;
    }
    try {
      final results = await _repository.searchPeople(query);
      people.assignAll(results);
      applyFilters();
    } catch (_) {
      applyFilters();
    }
  }

  Future<void> refreshProjects() async {
    isRefreshing.value = true;
    projectPage = 1;
    try {
      final result = await _repository.getProjects(page: 1, limit: 15);
      projects.assignAll(result.projects);
      filteredProjects.assignAll(result.projects);
      projectTotalAvailable = result.total;
      applyFilters();
    } catch (_) {
      applyFilters();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _onProjectScroll() {
    if (projectScrollController.position.pixels >=
        projectScrollController.position.maxScrollExtent - 250) {
      loadMoreProjects();
    }
  }

  void loadExploreData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    projectPage = 1;
    try {
      final projectResult = await _repository.getProjects(page: 1, limit: 15);
      projects.assignAll(projectResult.projects);
      filteredProjects.assignAll(projectResult.projects);
      projectTotalAvailable = projectResult.total;

      final results = await Future.wait([
        _repository.getCompetitions(),
        _repository.getRecommendedPeople(),
        _repository.getMyOfferingsSkills(),
      ]);

      final loadedCompetitions = results[0] as List<Competition>;
      competitions.assignAll(loadedCompetitions);
      filteredCompetitions.assignAll(loadedCompetitions);

      final loadedPeople = results[1] as List<ExplorePerson>;
      final offeringSkills = results[2] as List<String>;

      // Set matchLabel only when offering exists with matching skills
      List<ExplorePerson> processedPeople;
      if (offeringSkills.isNotEmpty) {
        final offeringLower = offeringSkills.map((s) => s.toLowerCase()).toSet();
        processedPeople = loadedPeople.map((person) {
          final hasMatch = person.tags.any(
            (t) => offeringLower.contains(t.toLowerCase()),
          );
          return ExplorePerson(
            id: person.id,
            name: person.name,
            role: person.role,
            avatarUrl: person.avatarUrl,
            tags: person.tags,
            matchLabel: hasMatch ? 'Rekomendasi untukmu' : '',
          );
        }).toList();
      } else {
        processedPeople = loadedPeople.map((p) => ExplorePerson(
          id: p.id,
          name: p.name,
          role: p.role,
          avatarUrl: p.avatarUrl,
          tags: p.tags,
          matchLabel: '',
        )).toList();
      }

      _savedRecommendedPeople
        ..clear()
        ..addAll(processedPeople);
      people.assignAll(processedPeople);
      filteredPeople.assignAll(processedPeople);

      applyFilters();
    } catch (e) {
      debugPrint('ExploreController.loadExploreData error: $e');
      hasError.value = true;
      errorMessage.value = 'Gagal memuat data. Periksa koneksi atau coba lagi.';
      // If offering endpoint fails, show people without badge
      final loadedPeople = _savedRecommendedPeople.isNotEmpty
          ? _savedRecommendedPeople
          : <ExplorePerson>[];
      people.assignAll(loadedPeople);
      filteredPeople.assignAll(loadedPeople);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> applyToProject(int projectId) async {
    try {
      await _repository.applyToProject(projectId);
      Project updated(Project p) => Project(
        projectId: p.projectId,
        title: p.title,
        description: p.description,
        postedBy: p.postedBy,
        posterRole: p.posterRole,
        avatarUrl: p.avatarUrl,
        posterId: p.posterId,
        deadline: p.deadline,
        university: p.university,
        postedAgo: p.postedAgo,
        totalSlots: p.totalSlots,
        filledSlots: p.filledSlots,
        matchScore: p.matchScore,
        hasApplied: true,
        isMember: p.isMember,
        skills: p.skills,
        memberAvatars: p.memberAvatars,
        memberNames: p.memberNames,
      );

      final pIdx = projects.indexWhere((p) => p.projectId == projectId);
      if (pIdx >= 0) projects[pIdx] = updated(projects[pIdx]);
      final fIdx = filteredProjects.indexWhere((p) => p.projectId == projectId);
      if (fIdx >= 0) filteredProjects[fIdx] = updated(filteredProjects[fIdx]);
      return null;
    } on dio.DioException catch (e) {
      final msg = e.response?.data?['detail'] as String? ?? 'Gagal mengirim lamaran';
      return msg;
    } catch (e) {
      return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  void loadMoreProjects() async {
    if (isLoadingMore.value || !hasMoreProjects) return;
    isLoadingMore.value = true;
    try {
      projectPage++;
      final result = await _repository.getProjects(page: projectPage, limit: 15);
      projects.addAll(result.projects);
      filteredProjects.addAll(result.projects);
      applyFilters();
    } catch (e) {
      projectPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void retry() {
    loadExploreData();
  }

  void changeTab(ExploreTab tab) {
    activeTab.value = tab;
    searchTextController.clear();
    searchQuery.value = '';
    applyFilters();
    if (tab.isPeople && people.isEmpty) {
      loadExploreData();
    }
  }

  int get activeFilterCount {
    var count = 0;
    if (selectedSort.value != 'Paling relevan' && selectedSort.value.isNotEmpty)
      count++;
    if (selectedFaculty.value != 'Semua jurusan') count++;
    if (selectedCategory.value != 'Semua kategori' &&
        selectedCategory.value != 'Semua kategori lomba')
      count++;
    if (selectedSkill.value != 'Semua skill') count++;
    if (selectedDeadline.value != 'Semua deadline') count++;
    if (selectedSlot.value != 'Semua slot') count++;
    if (selectedAvailability.value != 'Terbuka kolaborasi') count++;
    return count;
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();

    // 1. Projects — search query + hide full teams + relevan filter
    var tempProjects = projects.where((project) {
      if (project.openSlots <= 0) return false;

      final matchesQuery =
          query.isEmpty ||
          project.title.toLowerCase().contains(query) ||
          project.skills.any((s) => s.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      // Hide only when sort is relevan AND there are scored projects to show
      if (selectedSort.value == 'Paling relevan' && project.matchScore <= 0) {
        final hasScored = projects.any((p) => p.matchScore > 0);
        if (hasScored) return false;
      }

      return true;
    }).toList();

    if (selectedSort.value == 'Semua') {
      tempProjects = tempProjects.reversed.toList();
    }
    filteredProjects.assignAll(tempProjects);

    // 2. Competitions
    var tempCompetitions = competitions.where((comp) {
      final matchesQuery =
          query.isEmpty ||
          comp.title.toLowerCase().contains(query) ||
          comp.caption.toLowerCase().contains(query) ||
          comp.organizer.toLowerCase().contains(query);

      bool matchesDeadline = true;
      if (selectedDeadline.value != 'Semua deadline') {
        final days = comp.daysLeft;
        if (days == null) {
          matchesDeadline = false;
        } else {
          if (selectedDeadline.value == '< 1 minggu') {
            matchesDeadline = days < 7;
          } else if (selectedDeadline.value == '1 minggu') {
            matchesDeadline = days >= 7 && days <= 14;
          } else if (selectedDeadline.value == '2 minggu') {
            matchesDeadline = days > 14 && days <= 21;
          } else if (selectedDeadline.value == 'Bulan ini') {
            matchesDeadline = days <= 30;
          }
        }
      }

      return matchesQuery && matchesDeadline;
    }).toList();

    if (selectedSort.value == 'Semua') {
      tempCompetitions = tempCompetitions.reversed.toList();
    }
    filteredCompetitions.assignAll(tempCompetitions);

    // 3. People
    var tempPeople = people.where((person) {
      final matchesQuery =
          query.isEmpty ||
          person.name.toLowerCase().contains(query) ||
          person.role.toLowerCase().contains(query) ||
          person.tags.any((t) => t.toLowerCase().contains(query));

      bool matchesFaculty = true;
      if (selectedFaculty.value != 'Semua jurusan') {
        final role = person.role.toLowerCase();
        if (selectedFaculty.value == 'Teknik Informatika' ||
            selectedFaculty.value == 'Sistem Informasi') {
          matchesFaculty = role.contains('dev') || role.contains('developer');
        } else if (selectedFaculty.value == 'DKV') {
          matchesFaculty = role.contains('design') || role.contains('designer');
        }
      }

      final matchesSkill =
          selectedSkill.value == 'Semua skill' ||
          person.tags.any(
            (t) => t.toLowerCase() == selectedSkill.value.toLowerCase(),
          );

      return matchesQuery && matchesFaculty && matchesSkill;
    }).toList();

    if (selectedSort.value == 'Terpopuler') {
      tempPeople = tempPeople.reversed.toList();
    }
    filteredPeople.assignAll(tempPeople);
  }

  void clearAllFilters() {
    selectedSort.value = 'Paling relevan';
    selectedFaculty.value = 'Semua jurusan';
    selectedCategory.value = 'Semua kategori';
    selectedSkill.value = 'Semua skill';
    selectedDeadline.value = 'Semua deadline';
    selectedSlot.value = 'Semua slot';
    selectedAvailability.value = 'Terbuka kolaborasi';
    applyFilters();
  }
}
