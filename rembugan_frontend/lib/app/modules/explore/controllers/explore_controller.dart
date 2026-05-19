import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/entities/competition.dart';
import '../domain/entities/explore_tab.dart';
import '../domain/entities/project.dart';
import '../domain/repositories/explore_repository.dart';

class ExplorePerson {
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final String matchLabel;

  const ExplorePerson({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
  });
}

class ExploreController extends GetxController {
  ExploreController(this._repository);

  final searchTextController = TextEditingController();

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  final ExploreRepository _repository;

  final activeTab = ExploreTab.project.obs;
  final selectedSort = ''.obs;
  final selectedCategories = <String>[].obs;
  final selectedSkills = <String>[].obs;
  final activeFilters = <String>[].obs;
  
  final projects = <Project>[].obs;
  final filteredProjects = <Project>[].obs;
  
  final competitions = <Competition>[].obs;
  final filteredCompetitions = <Competition>[].obs;

  final searchQuery = ''.obs;

  final people = const [
    ExplorePerson(
      name: 'Dede Fernanda',
      role: 'Flutter Developer',
      avatarUrl: 'https://i.pravatar.cc/100?img=60',
      tags: ['Flutter', 'Figma'],
      matchLabel: 'Skill yang sama',
    ),
    ExplorePerson(
      name: 'Raka Pratama',
      role: 'UI/UX Designer',
      avatarUrl: 'https://i.pravatar.cc/100?img=47',
      tags: ['Design', 'Research'],
      matchLabel: 'Paling cocok untuk kamu',
    ),
  ];
  final filteredPeople = <ExplorePerson>[].obs;

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
    
    final loadedCompetitions = _repository.getCompetitions();
    competitions.assignAll(loadedCompetitions);
    filteredCompetitions.assignAll(loadedCompetitions);

    filteredPeople.assignAll(people);
  }

  void changeTab(ExploreTab tab) {
    activeTab.value = tab;
    searchTextController.clear();
    search('');
  }

  int get activeFilterCount {
    var count = 0;
    if (selectedSort.value.isNotEmpty) count++;
    count += selectedCategories.length;
    count += selectedSkills.length;
    return count;
  }

  void search(String query) {
    searchQuery.value = query;
    final lowerQuery = query.toLowerCase();

    // 1. Filter projects
    filteredProjects.assignAll(
      projects.where((project) {
        final matchesQuery = lowerQuery.isEmpty ||
            project.title.toLowerCase().contains(lowerQuery) ||
            project.category.toLowerCase().contains(lowerQuery) ||
            project.skills.any((s) => s.toLowerCase().contains(lowerQuery));

        final matchesCategory = selectedCategories.isEmpty ||
            selectedCategories.contains(project.category);
        final matchesSkill = selectedSkills.isEmpty ||
            project.skills.any(selectedSkills.contains);

        return matchesQuery && matchesCategory && matchesSkill;
      }),
    );

    // 2. Filter competitions
    filteredCompetitions.assignAll(
      competitions.where((comp) {
        return lowerQuery.isEmpty ||
            comp.title.toLowerCase().contains(lowerQuery) ||
            comp.category.toLowerCase().contains(lowerQuery) ||
            comp.caption.toLowerCase().contains(lowerQuery);
      }),
    );

    // 3. Filter people
    filteredPeople.assignAll(
      people.where((person) {
        return lowerQuery.isEmpty ||
            person.name.toLowerCase().contains(lowerQuery) ||
            person.role.toLowerCase().contains(lowerQuery) ||
            person.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      }),
    );
  }

  void applyFilters() {
    activeFilters
      ..clear()
      ..addAll([
        if (selectedSort.value.isNotEmpty) selectedSort.value,
        ...selectedCategories,
        ...selectedSkills,
      ]);

    final lowerQuery = searchQuery.value.toLowerCase();
    filteredProjects.assignAll(
      projects.where((project) {
        final matchesQuery = lowerQuery.isEmpty ||
            project.title.toLowerCase().contains(lowerQuery) ||
            project.category.toLowerCase().contains(lowerQuery) ||
            project.skills.any((s) => s.toLowerCase().contains(lowerQuery));

        final matchesCategory =
            selectedCategories.isEmpty ||
            selectedCategories.contains(project.category);
        final matchesSkill =
            selectedSkills.isEmpty ||
            project.skills.any(selectedSkills.contains);

        return matchesQuery && matchesCategory && matchesSkill;
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
    applyFilters();
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
