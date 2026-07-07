import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/entities/color_seed.dart';
import '../../domain/entities/competition.dart';
import '../../domain/entities/explore_person.dart';
import '../../domain/entities/feed_showcase.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/explore_repository.dart';

class ApiExploreRepository implements ExploreRepository {
  late final _api = Get.find<ApiClient>();

  @override
  Future<({List<Project> projects, int total})> getProjects({int page = 1, int limit = 15}) async {
    try {
      final response = await _api.get('/projects/explore', queryParameters: {
        'page': page,
        'limit': limit,
      });
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      final total = data['total_projects_available'] as int? ?? 0;

      final projects = items.map((item) {
        final raw = item as Map<String, dynamic>;
        return _mapToProject(raw);
      }).toList();

      return (projects: projects, total: total);
    } catch (e) {
      debugPrint('ApiExploreRepository.getProjects error: $e');
      return (projects: const <Project>[], total: 0);
    }
  }

  @override
  Future<({List<FeedShowcase> showcases, bool hasNext})> getShowcases({int page = 1, int limit = 10}) async {
    try {
      final response = await _api.get('/showcase/', queryParameters: {'page': page, 'limit': limit});
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      final hasNext = data['has_next'] as bool? ?? false;
      final showcases = items.map((e) => _mapToShowcase(e as Map<String, dynamic>)).toList();
      return (showcases: showcases.cast<FeedShowcase>(), hasNext: hasNext);
    } catch (e) {
      debugPrint('ApiExploreRepository.getShowcases error: $e');
      return (showcases: const <FeedShowcase>[], hasNext: false);
    }
  }

  @override
  Future<({List<FeedShowcase> showcases, bool hasNext})> getFollowingShowcases({int page = 1, int limit = 10}) async {
    try {
      final response = await _api.get('/showcase/', queryParameters: {
        'page': page, 'limit': limit, 'tab': 'following',
      });
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      final hasNext = data['has_next'] as bool? ?? false;
      final showcases = items.map((e) => _mapToShowcase(e as Map<String, dynamic>)).toList();
      return (showcases: showcases.cast<FeedShowcase>(), hasNext: hasNext);
    } catch (e) {
      debugPrint('ApiExploreRepository.getFollowingShowcases error: $e');
      return (showcases: const <FeedShowcase>[], hasNext: false);
    }
  }

  @override
  Future<List<Competition>> getCompetitions() async {
    try {
      final response = await _api.get('/competitions/all');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['data'];
        if (items is List) {
          return items.map((item) {
            final raw = item as Map<String, dynamic>;
            return _mapToCompetition(raw);
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('ApiExploreRepository.getCompetitions error: $e');
      return [];
    }
  }

  @override
  Future<List<ExplorePerson>> getRecommendedPeople() async {
    try {
      final response = await _api.get('/profile/recommended');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;

      return items.map((item) {
        final raw = item as Map<String, dynamic>;
        return _mapToPerson(raw);
      }).toList();
    } catch (e) {
      debugPrint('ApiExploreRepository.getRecommendedPeople error: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getMyOfferingsSkills() async {
    try {
      final response = await _api.get('/projects/my-projects');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      final skills = <String>{};
      for (final item in items) {
        final raw = item as Map<String, dynamic>;
        if (raw['status'] == 'open') {
          final required = raw['required_skills'] as List<dynamic>? ?? [];
          skills.addAll(required.map((e) => e.toString()));
        }
      }
      return skills.toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> applyToProject(int projectId) async {
    await _api.post('/collaboration/$projectId/apply', data: {});
  }

  @override
  Future<List<ExplorePerson>> searchPeople(String query) async {
    try {
      final response = await _api.get('/profile/search', queryParameters: {'q': query});
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;

      return items.map((item) {
        final raw = item as Map<String, dynamic>;
        return _mapToPerson(raw);
      }).toList();
    } catch (e) {
      debugPrint('ApiExploreRepository.searchPeople error: $e');
      return [];
    }
  }

  static Project _mapToProject(Map<String, dynamic> raw) {
    final title = raw['title'] as String? ?? '';
    final description = raw['description'] as String? ?? '';
    final postedBy = raw['owner_name'] as String? ?? '';
    final posterRole = '';
    final avatarUrl = raw['owner_photo'] as String? ?? '';
    final posterId = raw['owner_id'] as String? ?? '';
    final deadlineRaw = raw['deadline'] as String?;
    final deadline = deadlineRaw != null ? _formatIsoDeadline(deadlineRaw) : '';
    final university = '';
    final postedAgo = _computePostedAgo(raw['created_at'] as String?);
    var totalSlots = raw['total_slots'] as int? ?? 1;
    final filledSlots = raw['filled_slots'] as int? ?? 0;
    if (totalSlots < filledSlots) totalSlots = filledSlots;

    final skills = (raw['required_skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final memberNames = (raw['member_names'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (postedBy.isNotEmpty ? [postedBy] : const []);
    final memberAvatars = (raw['member_avatars'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final matchScore = raw['match_score'] as int? ?? 0;
    final hasApplied = raw['has_applied'] as bool? ?? false;
    final isMember = raw['is_member'] as bool? ?? false;
    final projectId = raw['id'] as int? ?? 0;

    return Project(
      projectId: projectId,
      title: title,
      description: description,
      postedBy: postedBy,
      posterRole: posterRole,
      avatarUrl: avatarUrl,
      posterId: posterId,
      deadline: deadline,
      university: university,
      postedAgo: postedAgo,
      totalSlots: totalSlots,
      filledSlots: filledSlots,
      matchScore: matchScore,
      hasApplied: hasApplied,
      isMember: isMember,
      skills: skills,
      memberAvatars: memberAvatars,
      memberNames: memberNames,
    );
  }

  static String _formatIsoDeadline(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  static String _computePostedAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      if (diff.inDays < 30) return '${diff.inDays ~/ 7} minggu lalu';
      return '${diff.inDays ~/ 30} bulan lalu';
    } catch (_) {
      return '';
    }
  }

  static ExplorePerson _mapToPerson(Map<String, dynamic> raw) {
    final id = raw['id'] as String? ?? '';
    final name = raw['full_name'] as String? ?? '';
    final role = raw['major'] as String? ?? raw['bio'] as String? ?? '';
    final avatarUrl = raw['photo_url'] as String? ?? '';
    final skills = (raw['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final connectionStatus = raw['connection_status'] as String?;

    return ExplorePerson(
      id: id,
      name: name,
      role: role,
      avatarUrl: avatarUrl,
      tags: skills,
      matchLabel: 'Rekomendasi untukmu',
      connectionStatus: connectionStatus,
    );
  }

  static FeedShowcase _mapToShowcase(Map<String, dynamic> raw) {
    return FeedShowcase(
      id: raw['id'] as String? ?? '',
      authorId: raw['author_id'] as String? ?? '',
      authorName: raw['author_name'] as String? ?? '',
      authorPhoto: raw['author_photo'] as String?,
      authorMajor: raw['author_major'] as String?,
      authorFaculty: raw['author_faculty'] as String?,
      content: raw['content'] as String? ?? '',
      mediaUrls: (raw['media_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (raw['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: raw['likes_count'] as int? ?? 0,
      commentsCount: raw['comments_count'] as int? ?? 0,
      likedByMe: raw['liked_by_me'] as bool? ?? false,
      matchScore: raw['match_score'] as int? ?? 0,
      connectionStatus: raw['connection_status'] as String?,
      createdAt: raw['created_at'] as String? ?? '',
    );
  }

  static final _categoryColors = <String, ColorSeed>{
    'hackathon': const ColorSeed(0xFFFF7043, 0xFFFF4B5F),
    'coding': const ColorSeed(0xFF6A8DFF, 0xFF4164EA),
    'design': const ColorSeed(0xFF7A63F1, 0xFFC43DDC),
    'bisnis': const ColorSeed(0xFF37D69A, 0xFF10A3A4),
    'business': const ColorSeed(0xFF37D69A, 0xFF10A3A4),
    'ideation': const ColorSeed(0xFF4C7DFF, 0xFF3156E8),
    'data': const ColorSeed(0xFF6A8DFF, 0xFF4164EA),
    'ui/ux': const ColorSeed(0xFF7A63F1, 0xFFC43DDC),
  };

  static Competition _mapToCompetition(Map<String, dynamic> raw) {
    final title = raw['judul'] as String? ?? raw['title'] as String? ?? '';
    final caption = raw['caption'] as String? ?? '';
    final kategori = raw['kategori'] as String? ?? 'Umum';
    final organizer = raw['sumber'] as String? ?? '';
    final deadlineStr = _formatDeadline(raw['deadline']);
    final badge = _computeBadge(deadlineStr);
    final color = _pickColor(kategori);
    final link = raw['link_direct'] as String? ?? raw['link'] as String? ?? raw['url'] as String? ?? '#';
    final posterUrl = raw['poster'] as String? ?? '';
    final campusTag = _campusTag(organizer);

    final matchScore = raw['match_score'] as int? ?? 0;

    return Competition(
      title: title,
      caption: caption,
      category: kategori,
      organizer: organizer,
      deadline: deadlineStr,
      badge: badge,
      color: color,
      registrationLink: link,
      campusTag: campusTag,
      posterUrl: posterUrl,
      matchScore: matchScore,
    );
  }

  static String _formatDeadline(dynamic ddl) {
    if (ddl == null || ddl == '') return '30 Des 2026';
    if (ddl is String) {
      try {
        final dt = DateTime.parse(ddl);
        return _formatDate(dt);
      } catch (_) {}
      final ddlLower = ddl.toLowerCase();
      for (final month in _monthMap.entries) {
        if (ddlLower.contains(month.key)) {
          return ddl;
        }
      }
      return ddl;
    }
    if (ddl is DateTime) {
      return _formatDate(ddl);
    }
    return ddl.toString();
  }

  static const _monthMap = {
    'januari': 'Jan', 'februari': 'Feb', 'maret': 'Mar', 'april': 'Apr',
    'mei': 'Mei', 'juni': 'Jun', 'juli': 'Jul', 'agustus': 'Agu',
    'september': 'Sep', 'oktober': 'Okt', 'november': 'Nov', 'desember': 'Des',
    'jan': 'Jan', 'feb': 'Feb', 'mar': 'Mar', 'apr': 'Apr',
    'jun': 'Jun', 'jul': 'Jul', 'agu': 'Agu', 'sep': 'Sep',
    'okt': 'Okt', 'nov': 'Nov', 'des': 'Des',
  };

  static String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _computeBadge(String deadline) {
    if (deadline.isEmpty) return 'Baru';
    final endDate = Competition.parseEndDate(deadline);
    if (endDate == null) return 'Baru';
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff < 0) return 'Ditutup';
    if (diff <= 7) return '🔥 Segera';
    if (diff <= 14) return 'Mendesak';
    if (diff <= 30) return 'Bulan ini';
    return 'Baru';
  }

  static ColorSeed _pickColor(String kategori) {
    final key = kategori.toLowerCase();
    for (final entry in _categoryColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return const ColorSeed(0xFF4C7DFF, 0xFF3156E8);
  }

  static String _campusTag(String sumber) {
    final s = sumber.toLowerCase();
    if (s.contains('kampus') || s.contains('universitas') ||
        s.contains('bem') || s.contains('hima') || s.contains('ftik') ||
        s.contains('feb') || s.contains('fakultas')) {
      return 'Intra Kampus';
    }
    return 'Nasional';
  }
}
