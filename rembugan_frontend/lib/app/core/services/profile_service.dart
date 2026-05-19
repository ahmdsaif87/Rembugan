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

class ProfileData {
  const ProfileData({
    required this.name,
    required this.handle,
    required this.bio,
    required this.location,
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
  final String location;
  final String socialLink;
  final List<String> skills;
  final List<ProfileExperience> experiences;
  final List<PlatformCollaboration> collaborationHistory;
  final bool hasResumePhoto;
  final String avatarAsset;

  ProfileData copyWith({
    String? name,
    String? handle,
    String? bio,
    String? location,
    String? socialLink,
    List<String>? skills,
    List<ProfileExperience>? experiences,
    List<PlatformCollaboration>? collaborationHistory,
    bool? hasResumePhoto,
    String? avatarAsset,
  }) {
    return ProfileData(
      name: name ?? this.name,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      socialLink: socialLink ?? this.socialLink,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      collaborationHistory: collaborationHistory ?? this.collaborationHistory,
      hasResumePhoto: hasResumePhoto ?? this.hasResumePhoto,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}

class ProfileService extends GetxService {
  static ProfileData seedProfile = const ProfileData(
    name: 'Dede Fernanda',
    handle: '@dede.flutter',
    bio:
        'Mahasiswa Informatika yang fokus pada pengembangan mobile app dan UI/UX design dengan pengalaman membangun aplikasi berbasis Flutter, Firebase, dan proyek kolaboratif kampus.',
    location: 'Malang, Indonesia',
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
