import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import 'package:rembugan/app/core/widgets/app_toast.dart';

class PersonalizationController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();
  final ApiClient _api = Get.find<ApiClient>();
  final AuthService _auth = Get.find<AuthService>();

  final isUploading = false.obs;
  final isScanned = false.obs;
  final isManualInput = false.obs;
  final scanningStep = 0.obs;
  final extractedProfile = const ProfileData(
    name: '',
    handle: '',
    bio: '',
    major: '',
    socialLink: '',
    skills: [],
    experiences: [],
    collaborationHistory: [],
    hasResumePhoto: false,
  ).obs;

  String? _photoUrl;
  final RxnString _localPhotoPath = RxnString(null);

  RxnString get localPhotoPath => _localPhotoPath;
  String? get photoUrl => _photoUrl;

  final extractionSteps = const [
    'Membaca struktur PDF resume',
    'Menjalankan OCR untuk nama dan kontak',
    'Memetakan skill, tools, dan framework',
    'Menyusun semantic bio dari pengalaman',
    'Membentuk profile kolaborasi',
  ];

  Future<void> pickAndExtractCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    isUploading.value = true;
    isScanned.value = false;
    scanningStep.value = 0;

    try {
      for (var i = 0; i < extractionSteps.length; i++) {
        scanningStep.value = i;
        await Future.delayed(const Duration(milliseconds: 400));
      }

      final token = await _api.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/onboarding/extract-cv');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Gagal membaca file');
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
          contentType: MediaType('application', 'pdf'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Gagal mengekstrak CV');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final responseData = json['data'] as Map<String, dynamic>;

      _photoUrl = responseData['photo_url'] as String?;
      final nama = responseData['nama'] as String? ?? '';
      final skills = (responseData['skills_terdeteksi'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          [];
      final bio = responseData['bio_suggestion'] as String? ?? '';
      final experiencesRaw = responseData['experiences'] as List? ?? [];

      final experiences = experiencesRaw.map((e) {
        final exp = e as Map<String, dynamic>;
        return ProfileExperience(
          title: exp['title'] as String? ?? '',
          organization: exp['organization'] as String? ?? '',
          duration: exp['duration'] as String? ?? '',
          description: exp['description'] as String? ?? '',
          techStack: (exp['tech_stack'] as List?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [],
        );
      }).toList();

      extractedProfile.value = ProfileData(
        name: nama.isNotEmpty ? nama : '',
        handle: '',
        bio: bio,
        major: '',
        socialLink: '',
        skills: skills,
        experiences: experiences,
        collaborationHistory: const [],
        hasResumePhoto: _photoUrl != null,
      );

      isUploading.value = false;
      isScanned.value = true;
    } catch (e) {
      isUploading.value = false;
      AppToast.error('Gagal mengekstrak CV. Coba lagi.', title: 'Gagal');
    }
  }

  // ignore: avoid_future_delayed_no_future
  void simulateUpload() => pickAndExtractCv();

  Future<void> pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    // Validate size (5MB)
    final sizeBytes = file.size;
    if (sizeBytes > 5 * 1024 * 1024) {
      AppToast.warning('Maksimal foto 5 MB.', title: 'Ukuran terlalu besar');
      return;
    }

    // Set local preview immediately
    if (!kIsWeb) {
      _localPhotoPath.value = file.path;
    }

    // Upload to backend
    try {
      final token = await _api.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/upload/image');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Gagal membaca file');
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: MediaType('image', file.extension ?? 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
          contentType: MediaType('image', file.extension ?? 'jpeg'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _photoUrl = json['data']['url'] as String?;
        if (_photoUrl != null) {
          extractedProfile.value =
              extractedProfile.value.copyWith(hasResumePhoto: true);
        }
      } else {
        AppToast.error('Upload foto gagal.', title: 'Gagal');
      }
    } catch (e) {
      AppToast.error('Upload foto gagal.', title: 'Gagal');
    }
  }

  void updateName(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(name: value);
  }

  void updateBio(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(bio: value);
  }

  void updateMajor(String value) {
    extractedProfile.value = extractedProfile.value.copyWith(major: value);
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

  void addCustomExperience(ProfileExperience experience) {
    extractedProfile.value = extractedProfile.value.copyWith(
      experiences: [...extractedProfile.value.experiences, experience],
    );
  }

  void updateExperience(int index, ProfileExperience updated) {
    final list = [...extractedProfile.value.experiences];
    if (index >= 0 && index < list.length) {
      list[index] = updated;
      extractedProfile.value = extractedProfile.value.copyWith(
        experiences: list,
      );
    }
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
    extractedProfile.value = const ProfileData(
      name: '',
      handle: '',
      bio: '',
      major: '',
      socialLink: '',
      skills: [],
      experiences: [],
      collaborationHistory: [],
      hasResumePhoto: false,
    );
  }

  void removeExperience(ProfileExperience experience) {
    extractedProfile.value = extractedProfile.value.copyWith(
      experiences: extractedProfile.value.experiences
          .where((item) => item != experience)
          .toList(),
    );
  }

  Future<void> generateProfile() async {
    final profile = extractedProfile.value;
    if (profile.name.trim().isEmpty) {
      AppToast.warning('Nama wajib diisi');
      return;
    }

    try {
      await _api.put('/onboarding/save-profile', data: {
        'full_name': profile.name,
        'bio': profile.bio,
        'photo_url': _photoUrl,
        'skills': profile.skills,
        'social_links': profile.socialLink.isNotEmpty
            ? {'website': profile.socialLink}
            : null,
        'experiences': profile.experiences
            .map((e) => {
                  'title': e.title,
                  'organization': e.organization,
                  'duration': e.duration,
                  'description': e.description,
                  'tech_stack': e.techStack,
                })
            .toList(),
      });

      _profileService.updateProfile(
        profile.copyWith(photoUrl: _photoUrl ?? ''),
      );

      final user = _auth.currentUser.value;
      if (user != null) {
        _auth.currentUser.value = user.copyWith(isOnboarded: true);
        _auth.currentUser.refresh();
      }

      Get.offAllNamed('/home');
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      AppToast.error(detail?.toString() ?? 'Gagal menyimpan profil.', title: 'Gagal');
    }
  }

  void reset() {
    isUploading.value = false;
    isScanned.value = false;
    isManualInput.value = false;
    scanningStep.value = 0;
    _photoUrl = null;
    extractedProfile.value = const ProfileData(
      name: '',
      handle: '',
      bio: '',
      major: '',
      socialLink: '',
      skills: [],
      experiences: [],
      collaborationHistory: [],
      hasResumePhoto: false,
    );
  }
}
