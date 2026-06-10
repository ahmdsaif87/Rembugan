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
    if (selectedSort.value != 'Paling relevan' && selectedSort.value.isNotEmpty)
      count++;
    if (selectedFaculty.value != 'Semua jurusan') count++;
    if (selectedCategory.value != 'Semua kategori' &&
        selectedCategory.value != 'Semua kategori lomba' &&
        selectedCategory.value != 'Semua kategori proyek')
      count++;
    if (selectedSkill.value != 'Semua skill') count++;
    if (selectedDeadline.value != 'Semua deadline') count++;
    if (selectedSlot.value != 'Semua slot') count++;
    if (selectedAvailability.value != 'Terbuka kolaborasi') count++;
    return count;
  }

  void search(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();

    // 1. Projects
    var tempProjects = projects.where((project) {
      final matchesQuery =
          query.isEmpty ||
          project.title.toLowerCase().contains(query) ||
          project.category.toLowerCase().contains(query) ||
          project.skills.any((s) => s.toLowerCase().contains(query));

      final matchesFaculty =
          selectedFaculty.value == 'Semua jurusan' ||
          project.faculty.toLowerCase().contains(
            selectedFaculty.value.toLowerCase(),
          );

      var categoryFilter = selectedCategory.value;
      if (categoryFilter == 'Semua kategori proyek')
        categoryFilter = 'Semua kategori';
      final matchesCategory =
          categoryFilter == 'Semua kategori' ||
          project.category.toLowerCase().contains(
            categoryFilter
                .replaceAll(' App', '')
                .replaceAll(' Dev', '')
                .replaceAll(' Design', '')
                .toLowerCase(),
          );

      final matchesSlot =
          selectedSlot.value == 'Semua slot' ||
          (selectedSlot.value == '1 slot' && project.openSlots == 1) ||
          (selectedSlot.value == '2 slot' && project.openSlots == 2) ||
          (selectedSlot.value == '3+ slot' && project.openSlots >= 3);

      return matchesQuery && matchesFaculty && matchesCategory && matchesSlot;
    }).toList();

    if (selectedSort.value == 'Terbaru') {
      tempProjects = tempProjects.reversed.toList();
    }
    filteredProjects.assignAll(tempProjects);

    // 2. Competitions
    var tempCompetitions = competitions.where((comp) {
      final matchesQuery =
          query.isEmpty ||
          comp.title.toLowerCase().contains(query) ||
          comp.category.toLowerCase().contains(query) ||
          comp.caption.toLowerCase().contains(query) ||
          comp.organizer.toLowerCase().contains(query);

      bool matchesFaculty = true;
      if (selectedFaculty.value != 'Semua jurusan') {
        final org = comp.organizer.toLowerCase();
        final cat = comp.category.toLowerCase();
        final title = comp.title.toLowerCase();
        if (selectedFaculty.value == 'Teknik Informatika') {
          matchesFaculty =
              org.contains('ftik') ||
              cat.contains('coding') ||
              cat.contains('hackathon');
        } else if (selectedFaculty.value == 'Sistem Informasi') {
          matchesFaculty =
              org.contains('ftik') ||
              cat.contains('data') ||
              title.contains('edutech');
        } else if (selectedFaculty.value == 'DKV') {
          matchesFaculty = cat.contains('design') || cat.contains('ui/ux');
        } else if (selectedFaculty.value == 'Manajemen') {
          matchesFaculty =
              org.contains('ekonomi') ||
              org.contains('feb') ||
              cat.contains('business');
        }
      }

      var categoryFilter = selectedCategory.value;
      if (categoryFilter == 'Semua kategori lomba')
        categoryFilter = 'Semua kategori';
      bool matchesCategory = true;
      if (categoryFilter != 'Semua kategori') {
        final compCat = comp.category.toUpperCase();
        if (categoryFilter == 'Hackathon') {
          matchesCategory = compCat.contains('HACKATHON');
        } else if (categoryFilter == 'UI/UX') {
          matchesCategory = compCat.contains('DESIGN');
        } else if (categoryFilter == 'Bisnis') {
          matchesCategory = compCat.contains('BUSINESS');
        } else if (categoryFilter == 'Data') {
          matchesCategory = compCat.contains('CODING');
        } else {
          matchesCategory = comp.category.toLowerCase().contains(
            categoryFilter.toLowerCase(),
          );
        }
      }

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

      return matchesQuery &&
          matchesFaculty &&
          matchesCategory &&
          matchesDeadline;
    }).toList();

    if (selectedSort.value == 'Terbaru') {
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
