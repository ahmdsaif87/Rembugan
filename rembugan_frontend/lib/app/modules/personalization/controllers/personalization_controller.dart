import 'package:get/get.dart';

import '../../../core/services/profile_service.dart';

class PersonalizationController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isUploading = false.obs;
  final isScanned = false.obs;
  final isManualInput = false.obs;
  final scanningStep = 0.obs;
  final extractedProfile = ProfileService.seedProfile.obs;

  final extractionSteps = const [
    'Membaca struktur PDF resume',
    'Menjalankan OCR untuk nama dan kontak',
    'Memetakan skill, tools, dan framework',
    'Menyusun semantic bio dari pengalaman',
    'Membentuk profile kolaborasi',
  ];

  void simulateUpload() async {
    isUploading.value = true;
    isScanned.value = false;
    scanningStep.value = 0;

    for (var index = 0; index < extractionSteps.length; index++) {
      scanningStep.value = index;
      await Future.delayed(const Duration(milliseconds: 650));
    }

    extractedProfile.value = ProfileService.seedProfile.copyWith(
      name: 'Dede Fernanda',
      handle: '@dede.flutter',
      bio:
          'Mahasiswa Informatika yang fokus pada pengembangan mobile app dan UI/UX design dengan pengalaman membangun aplikasi berbasis Flutter, Firebase, dan proyek kolaboratif kampus. Terbiasa bekerja dalam sprint kecil, merapikan design system, dan menerjemahkan kebutuhan pengguna menjadi pengalaman mobile yang clean.',
      skills: [
        'Flutter',
        'Dart',
        'Firebase',
        'Figma',
        'UI/UX',
        'Python',
        'REST API',
        'GetX',
      ],
      experiences: const [
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
              'Mendesain prototype mobile, komponen reusable, dan validasi usability untuk program mentoring kampus.',
          techStack: ['Figma', 'Design System'],
        ),
        ProfileExperience(
          title: 'Finalist Product Sprint',
          organization: 'Hackathon EduCollab',
          duration: 'Nov 2025',
          description:
              'Berkolaborasi sebagai frontend lead untuk membangun MVP matching tim dan presentasi produk.',
          techStack: ['Flutter', 'REST API'],
        ),
      ],
      hasResumePhoto: false,
    );

    await Future.delayed(const Duration(seconds: 3)); // Simulate AI processing
    isUploading.value = false;
    isScanned.value = true;
  }

  void updateName(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(name: value);
  }

  void updateBio(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(bio: value);
  }

  void updateLocation(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(location: value);
  }

  void updateSocialLink(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(socialLink: value);
  }

  void addSkill(String value) {
    final skill = value.trim();
    if (skill.isEmpty || extractedProfile.value.skills.contains(skill)) return;
    extractedProfile.value = extractedProfile.value.copyWith(
      skills: [...extractedProfile.value.skills, skill],
    );
  }

  void removeSkill(String skill) {
    extractedProfile.value = extractedProfile.value.copyWith(
      skills: extractedProfile.value.skills
          .where((item) => item != skill)
          .toList(),
    );
  }

  void addExperience() {
    extractedProfile.value = extractedProfile.value.copyWith(
      experiences: [
        ...extractedProfile.value.experiences,
        const ProfileExperience(
          title: 'Role baru',
          organization: 'Organisasi / Proyek',
          duration: 'Periode',
          description: 'Deskripsi singkat pengalaman.',
        ),
      ],
    );
  }

  void startManualInput() {
    isManualInput.value = true;
    isUploading.value = false;
    isScanned.value = false;
    extractedProfile.value = ProfileService.seedProfile.copyWith(
      name: '',
      bio: '',
      location: '',
      socialLink: '',
      skills: const [],
      experiences: const [],
    );
  }

  void removeExperience(ProfileExperience experience) {
    extractedProfile.value = extractedProfile.value.copyWith(
      experiences: extractedProfile.value.experiences
          .where((item) => item != experience)
          .toList(),
    );
  }

  void generateProfile() {
    _profileService.updateProfile(extractedProfile.value);
  }

  void reset() {
    isUploading.value = false;
    isScanned.value = false;
    isManualInput.value = false;
    scanningStep.value = 0;
    extractedProfile.value = ProfileService.seedProfile;
  }
}
