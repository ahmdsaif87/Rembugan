import 'package:get/get.dart';

import '../domain/entities/competition.dart';
import '../domain/entities/explore_tab.dart';
import '../domain/entities/project.dart';
import '../domain/repositories/explore_repository.dart';

class ExploreController extends GetxController {
  ExploreController(this._repository);

  final ExploreRepository _repository;

  final activeTab = ExploreTab.project.obs;
  final selectedSort = ''.obs;
  final selectedCategories = <String>[].obs;
  final selectedSkills = <String>[].obs;
  final activeFilters = <String>[].obs;
  final projects = <Project>[].obs;
  final filteredProjects = <Project>[].obs;
  final competitions = <Competition>[].obs;

  final sortOptions = const ['Terbaru', 'Terpopuler', 'Paling Relevan'];
  final categoryOptions = const [
    'Mobile Dev',
    'Web Dev',
    'UI/UX Design',
    'Data Science',
    'Backend',
    'Machine Learning',
  ];
  final skillOptions = const [
    'React',
    'Flutter',
    'Figma',
    'Python',
    'Node.js',
    'Kotlin',
  ];

  @override
  void onInit() {
    super.onInit();
    loadExploreData();
  }

  void loadExploreData() {
    final loadedProjects = _repository.getProjects();
    projects.assignAll(loadedProjects);
    filteredProjects.assignAll(loadedProjects);
    competitions.assignAll(_repository.getCompetitions());
  }

  void changeTab(ExploreTab tab) {
    activeTab.value = tab;
  }

  int get activeFilterCount {
    var count = 0;
    if (selectedSort.value.isNotEmpty) count++;
    count += selectedCategories.length;
    count += selectedSkills.length;
    return count;
  }

  void applyFilters() {
    activeFilters
      ..clear()
      ..addAll([
        if (selectedSort.value.isNotEmpty) selectedSort.value,
        ...selectedCategories,
        ...selectedSkills,
      ]);

    if (selectedCategories.isEmpty && selectedSkills.isEmpty) {
      filteredProjects.assignAll(projects);
      return;
    }

    filteredProjects.assignAll(
      projects.where((project) {
        final matchesCategory =
            selectedCategories.isEmpty ||
            selectedCategories.contains(project.category);
        final matchesSkill =
            selectedSkills.isEmpty ||
            project.skills.any(selectedSkills.contains);

        return matchesCategory && matchesSkill;
      }),
    );
  }

  void removeFilter(String filter) {
    if (sortOptions.contains(filter)) {
      selectedSort.value = '';
    } else if (categoryOptions.contains(filter)) {
      selectedCategories.remove(filter);
    } else if (skillOptions.contains(filter)) {
      selectedSkills.remove(filter);
    }

    activeFilters.remove(filter);
    applyFilters();
  }

  void clearAllFilters() {
    selectedSort.value = '';
    selectedCategories.clear();
    selectedSkills.clear();
    activeFilters.clear();
    filteredProjects.assignAll(projects);
  }

  void toggleCategory(String category) {
    selectedCategories.contains(category)
        ? selectedCategories.remove(category)
        : selectedCategories.add(category);
  }

  void toggleSkill(String skill) {
    selectedSkills.contains(skill)
        ? selectedSkills.remove(skill)
        : selectedSkills.add(skill);
  }
}
