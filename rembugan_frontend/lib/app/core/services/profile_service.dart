import 'package:get/get.dart';

class ProfileExperience {
  const ProfileExperience({
    required this.title,
    required this.organization,
    required this.duration,
    required this.description,
    this.techStack = const [],
  });

  final String title;
  final String organization;
  final String duration;
  final String description;
  final List<String> techStack;

  ProfileExperience copyWith({
    String? title,
    String? organization,
    String? duration,
    String? description,
    List<String>? techStack,
  }) {
    return ProfileExperience(
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

class ProjectHistoryItem {
  final int id;
  final String title;
  final String status;
  final String role;

  const ProjectHistoryItem({
    required this.id,
    required this.title,
    required this.status,
    required this.role,
  });

  factory ProjectHistoryItem.fromJson(Map<String, dynamic> json) {
    return ProjectHistoryItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.handle,
    required this.bio,
    required this.major,
    required this.socialLink,
    required this.skills,
    required this.experiences,
    required this.collaborationHistory,
    required this.hasResumePhoto,
    this.avatarAsset = 'lib/assets/img/avatar.png',
  });

  final String name;
  final String handle;
  final String bio;
  final String major;
  final String socialLink;
  final List<String> skills;
  final List<ProfileExperience> experiences;
  final List<PlatformCollaboration> collaborationHistory;
  final bool hasResumePhoto;
<<<<<<< Updated upstream
  final String avatarAsset;
=======
  final int connectionCount;
  final int projectCount;
  final String? nim;
  final String? faculty;
  final String? major;
  final List<ProjectHistoryItem> projectHistory;

  const ProfileData({
    this.id,
    required this.name,
    required this.handle,
    required this.bio,
    required this.interest,
    required this.socialLink,
    this.photoUrl = '',
    this.coverUrl = '',
    required this.skills,
    required this.experiences,
    required this.collaborationHistory,
    this.hasResumePhoto = false,
    this.connectionCount = 0,
    this.projectCount = 0,
    this.nim,
    this.faculty,
    this.major,
    this.projectHistory = const [],
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final socialLinks = json['social_links'];
    String socialLink = '';
    if (socialLinks is Map) {
      final values = socialLinks.values.whereType<String>().toList();
      if (values.isNotEmpty) socialLink = values.first;
    } else if (socialLinks is String) {
      socialLink = socialLinks;
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
      socialLink: socialLink,
      photoUrl: json['photo_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      nim: json['nim'] as String?,
      faculty: json['faculty'] as String?,
      major: json['major'] as String?,
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
              ?.map((e) => ProjectHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
>>>>>>> Stashed changes

  ProfileData copyWith({
    String? name,
    String? handle,
    String? bio,
    String? major,
    String? socialLink,
    List<String>? skills,
    List<ProfileExperience>? experiences,
    List<PlatformCollaboration>? collaborationHistory,
    bool? hasResumePhoto,
<<<<<<< Updated upstream
    String? avatarAsset,
=======
    int? connectionCount,
    int? projectCount,
    List<ProjectHistoryItem>? projectHistory,
>>>>>>> Stashed changes
  }) {
    return ProfileData(
      name: name ?? this.name,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      major: major ?? this.major,
      socialLink: socialLink ?? this.socialLink,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      collaborationHistory: collaborationHistory ?? this.collaborationHistory,
      hasResumePhoto: hasResumePhoto ?? this.hasResumePhoto,
<<<<<<< Updated upstream
      avatarAsset: avatarAsset ?? this.avatarAsset,
=======
      connectionCount: connectionCount ?? this.connectionCount,
      projectCount: projectCount ?? this.projectCount,
      projectHistory: projectHistory ?? this.projectHistory,
>>>>>>> Stashed changes
    );
  }
}

class ProfileService extends GetxService {
  static ProfileData seedProfile = const ProfileData(
    name: 'Dede Fernanda',
    handle: '@dede.flutter',
    bio:
        'Mahasiswa Informatika yang fokus pada pengembangan mobile app dan UI/UX design dengan pengalaman membangun aplikasi berbasis Flutter, Firebase, dan proyek kolaboratif kampus.',
    major: 'Teknik Informatika',
    socialLink: 'github.com/dedef',
    skills: ['Flutter', 'Dart', 'Firebase', 'Figma', 'UI/UX', 'Python'],
    experiences: [
      ProfileExperience(
        title: 'Mobile App Developer',
        organization: 'Proyek Kampus Sistem Mentoring',
        duration: 'Feb 2025 - Jun 2025',
        description:
            'Membangun aplikasi mentoring mahasiswa dengan flow jadwal, chat dasar, dan dashboard peserta.',
        techStack: ['Flutter', 'GetX', 'Firebase'],
      ),
      ProfileExperience(
        title: 'UI/UX Designer',
        organization: 'Komunitas Informatika',
        duration: 'Agu 2025 - Des 2025',
        description:
            'Mendesain prototype mobile untuk program mentoring dan validasi kebutuhan pengguna.',
        techStack: ['Figma', 'Design System'],
      ),
    ],
    collaborationHistory: [
      PlatformCollaboration(
        role: 'Frontend Lead',
        workspace: 'Hackathon EduCollab',
        members: 5,
        duration: '12 hari',
        contribution:
            'Merapikan onboarding, dashboard tim, dan integrasi API submission.',
        status: 'Selesai',
        skills: ['Flutter', 'REST API', 'UI Polish'],
      ),
      PlatformCollaboration(
        role: 'Product Collaborator',
        workspace: 'Mentoring Kampus MVP',
        members: 4,
        duration: '3 minggu',
        contribution:
            'Ikut sprint riset pengguna, prioritas fitur, dan testing prototype.',
        status: 'Archived',
        skills: ['Research', 'Prototype'],
      ),
    ],
    hasResumePhoto: false,
  );

  final profile = seedProfile.obs;

  void updateProfile(ProfileData data) {
    profile.value = data;
  }
}
