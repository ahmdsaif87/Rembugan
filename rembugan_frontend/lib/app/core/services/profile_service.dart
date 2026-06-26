import 'package:get/get.dart';

import 'api_client.dart';

class ProfileExperience {
  final String? id;
  final String title;
  final String organization;
  final String duration;
  final String description;
  final List<String> techStack;

  const ProfileExperience({
    this.id,
    required this.title,
    required this.organization,
    required this.duration,
    required this.description,
    this.techStack = const [],
  });

  factory ProfileExperience.fromJson(Map<String, dynamic> json) {
    final start = json['start_date'] as String? ?? '';
    final end = json['end_date'] as String? ?? '';
    final duration = switch ((start.isNotEmpty, end.isNotEmpty)) {
      (true, true) => '$start - $end',
      (true, false) => start,
      _ => '',
    };
    return ProfileExperience(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      organization: json['company'] as String? ?? '',
      duration: duration,
      description: json['description'] as String? ?? '',
    );
  }

  ProfileExperience copyWith({
    String? id,
    String? title,
    String? organization,
    String? duration,
    String? description,
    List<String>? techStack,
  }) {
    return ProfileExperience(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
    );
  }
}

class PlatformCollaboration {
  const PlatformCollaboration({
    required this.role,
    required this.workspace,
    required this.members,
    required this.duration,
    required this.contribution,
    required this.status,
    this.skills = const [],
    this.visible = true,
  });

  final String role;
  final String workspace;
  final int members;
  final String duration;
  final String contribution;
  final String status;
  final List<String> skills;
  final bool visible;

  PlatformCollaboration copyWith({bool? visible}) {
    return PlatformCollaboration(
      role: role,
      workspace: workspace,
      members: members,
      duration: duration,
      contribution: contribution,
      status: status,
      skills: skills,
      visible: visible ?? this.visible,
    );
  }
}

class ProfileData {
  final String? id;
  final String name;
  final String handle;
  final String bio;
  final String interest;
  final String major;
  final Map<String, String> socialLinks;
  final String photoUrl;
  final String coverUrl;
  final List<String> skills;
  final List<ProfileExperience> experiences;
  final List<PlatformCollaboration> collaborationHistory;
  final bool hasResumePhoto;
  final int connectionCount;
  final int projectCount;
  final List<Map<String, dynamic>> projectHistory;

  const ProfileData({
    this.id,
    required this.name,
    required this.handle,
    required this.bio,
    this.interest = '',
    required this.major,
    this.socialLinks = const {},
    this.photoUrl = '',
    this.coverUrl = '',
    required this.skills,
    required this.experiences,
    required this.collaborationHistory,
    this.hasResumePhoto = false,
    this.connectionCount = 0,
    this.projectCount = 0,
    this.projectHistory = const [],
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final rawSocialLinks = json['social_links'];
    Map<String, String> parsedLinks = {};
    if (rawSocialLinks is Map) {
      parsedLinks = rawSocialLinks.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    final experiences = (json['experiences'] as List<dynamic>?)
            ?.map((e) => ProfileExperience.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ProfileData(
      id: json['id']?.toString(),
      name: json['full_name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      interest: json['interest'] as String? ?? '',
      major: json['major'] as String? ?? '',
      socialLinks: parsedLinks,
      photoUrl: json['photo_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      experiences: experiences,
      collaborationHistory: const [],
      hasResumePhoto: false,
      connectionCount: json['connection_count'] as int? ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
      projectHistory: (json['project_history'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  ProfileData copyWith({
    String? id,
    String? name,
    String? handle,
    String? bio,
    String? interest,
    String? major,
    Map<String, String>? socialLinks,
    String? photoUrl,
    String? coverUrl,
    List<String>? skills,
    List<ProfileExperience>? experiences,
    List<PlatformCollaboration>? collaborationHistory,
    bool? hasResumePhoto,
    int? connectionCount,
    int? projectCount,
    List<Map<String, dynamic>>? projectHistory,
  }) {
    return ProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      interest: interest ?? this.interest,
      major: major ?? this.major,
      socialLinks: socialLinks ?? this.socialLinks,
      photoUrl: photoUrl ?? this.photoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      collaborationHistory: collaborationHistory ?? this.collaborationHistory,
      hasResumePhoto: hasResumePhoto ?? this.hasResumePhoto,
      connectionCount: connectionCount ?? this.connectionCount,
      projectCount: projectCount ?? this.projectCount,
      projectHistory: projectHistory ?? this.projectHistory,
    );
  }
}

class ProfileService extends GetxService {
  final _api = Get.find<ApiClient>();

  final profile = ProfileData(
    name: '',
    handle: '',
    bio: '',
    major: '',
    skills: [],
    experiences: [],
    collaborationHistory: [],
  ).obs;

  final isLoading = true.obs;
  final errorMessage = Rxn<String>();

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _api.get('/profile/me');
      final body = res.data;
      if (body is! Map) {
        errorMessage.value = 'Response bukan object: ${body.runtimeType}';
        return;
      }
      final data = body['data'];
      if (data is! Map) {
        errorMessage.value = 'Field "data" bukan object: ${data.runtimeType}';
        return;
      }
      profile.value = ProfileData.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      errorMessage.value = 'Gagal memuat profil: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> updateSettings(Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/profile/settings', data: data);
      final resultData = res.data['data'] as Map<String, dynamic>?;
      if (resultData != null) {
        final rawLinks = resultData['social_links'];
        Map<String, String> parsedLinks = {};
        if (rawLinks is Map) {
          parsedLinks = rawLinks.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
        profile.value = profile.value.copyWith(
          name: resultData['full_name'] as String? ?? profile.value.name,
          handle: resultData['handle'] as String? ?? profile.value.handle,
          bio: resultData['bio'] as String? ?? profile.value.bio,
          interest: resultData['interest'] as String? ?? profile.value.interest,
          photoUrl: resultData['photo_url'] as String? ?? profile.value.photoUrl,
          coverUrl: resultData['cover_url'] as String? ?? profile.value.coverUrl,
          socialLinks: parsedLinks,
        );
      }
      return null;
    } catch (e) {
      return 'Gagal menyimpan pengaturan';
    }
  }

  void updateProfile(ProfileData data) {
    profile.value = data;
  }
}
