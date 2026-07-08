import 'dart:convert';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileService profileService = Get.find<ProfileService>();
  final ApiClient api = Get.find<ApiClient>();
  final _picker = ImagePicker();

  late ProfileData draft;
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController interestController;
  late TextEditingController instagramController;
  late TextEditingController linkedinController;
  late TextEditingController externalController;
  bool _isSaving = false;
  bool _hasLocalOnlyCollaborationChanges = false;

  @override
  void initState() {
    super.initState();
    draft = profileService.profile.value;
    nameController = TextEditingController(text: draft.name);
    bioController = TextEditingController(text: draft.bio);
    interestController = TextEditingController(text: draft.interest);
    instagramController = TextEditingController(text: draft.socialLinks['instagram'] ?? '');
    linkedinController = TextEditingController(text: draft.socialLinks['linkedin'] ?? '');
    externalController = TextEditingController(text: draft.socialLinks['website'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    interestController.dispose();
    instagramController.dispose();
    linkedinController.dispose();
    externalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: AppC.of(context).surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42, height: 4,
                decoration: BoxDecoration(
                  color: AppC.of(context).borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(FluentIcons.camera_24_regular),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(FluentIcons.image_24_regular),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    AppToast.info('Mengupload gambar...');
    try {
      final bytes = await picked.readAsBytes();
      final url = (await api.uploadImageBytes(
        '/upload/image',
        bytes,
        filename: picked.name,
      ) as Map<String, dynamic>?)?['url'] as String?;
      if (url != null && mounted) {
        setState(() {
          if (isCover) {
            draft = draft.copyWith(coverUrl: url);
          } else {
            draft = draft.copyWith(photoUrl: url);
          }
        });
        AppToast.success('Gambar siap disimpan. Tekan Simpan untuk memperbarui profil.');
      } else {
        AppToast.error('Gagal mengupload gambar.');
      }
    } catch (e) {
      debugPrint('EditProfileView._pickImage error: $e');
      AppToast.error('Gagal mengupload gambar. Coba lagi.');
    }
  }

  Future<void> _scanAndFillCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    AppToast.info('Menganalisis CV...');

    try {
      final token = await api.getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}/onboarding/extract-cv');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        final bytes = result.files.first.bytes;
        if (bytes == null) throw Exception('Gagal membaca file');
        request.files.add(http.MultipartFile.fromBytes(
          'file', bytes,
          filename: result.files.first.name,
          contentType: MediaType('application', 'pdf'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file', result.files.first.path!,
          filename: result.files.first.name,
          contentType: MediaType('application', 'pdf'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        AppToast.error('Gagal menganalisis CV.', title: 'Gagal');
        return;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final nama = data['nama'] as String? ?? '';
      final skills = (data['skills_terdeteksi'] as List?)
              ?.map((s) => s.toString())
              .toList() ?? [];
      final bio = data['bio_suggestion'] as String? ?? '';

      setState(() {
        if (nama.isNotEmpty) {
          nameController.text = nama;
          draft = draft.copyWith(name: nama);
        }
        if (bio.isNotEmpty) {
          bioController.text = bio;
          draft = draft.copyWith(bio: bio);
        }
        if (skills.isNotEmpty) {
          draft = draft.copyWith(skills: skills);
        }
      });

      AppToast.success('Data CV berisi, silakan periksa kembali.');
    } catch (e) {
      debugPrint('EditProfileView._scanAndFillCv error: $e');
      AppToast.error('Gagal memproses CV. Coba lagi.', title: 'Gagal');
    }
  }

  bool _experiencesChanged(List<ProfileExperience> a, List<ProfileExperience> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].title != b[i].title ||
          a[i].organization != b[i].organization ||
          a[i].duration != b[i].duration ||
          a[i].description != b[i].description ||
          !listEquals(a[i].techStack, b[i].techStack)) {
        return true;
      }
    }
    return false;
  }

  DateTime? _parseDurationStart(String? duration) {
    if (duration == null || duration.isEmpty) return null;
    final parts = duration.split(' - ');
    if (parts.isEmpty) return null;
    return _parseDateStr(parts[0].trim());
  }

  DateTime? _parseDurationEnd(String? duration) {
    if (duration == null || duration.isEmpty) return null;
    final parts = duration.split(' - ');
    if (parts.length < 2) return null;
    final end = parts[1].trim().toLowerCase();
    if (['now', 'present', 'sekarang', 'saat ini'].contains(end)) return null;
    return _parseDateStr(parts[1].trim());
  }

  DateTime? _parseDateStr(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {}
    final parts = s.split('-');
    if (parts.length == 2) {
      final y = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim());
      if (y != null && m != null && m >= 1 && m <= 12) return DateTime(y, m);
    }
    final y = int.tryParse(s);
    if (y != null) return DateTime(y, 1);
    return null;
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}';
    if (end == null) return '$startStr - Present';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      AppToast.error('Nama wajib diisi.');
      return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(Duration.zero);
    try {
      final old = profileService.profile.value;
      final newSocialLinks = <String, String>{};
      if (instagramController.text.trim().isNotEmpty) newSocialLinks['instagram'] = instagramController.text.trim();
      if (linkedinController.text.trim().isNotEmpty) newSocialLinks['linkedin'] = linkedinController.text.trim();
      if (externalController.text.trim().isNotEmpty) newSocialLinks['website'] = externalController.text.trim();

      final newDraft = draft.copyWith(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        interest: interestController.text.trim(),
        socialLinks: newSocialLinks,
        skills: draft.skills.map((skill) => skill.trim()).where((skill) => skill.isNotEmpty).toList(),
        experiences: draft.experiences
            .where((exp) => exp.title.trim().isNotEmpty && exp.organization.trim().isNotEmpty)
            .toList(),
      );

      final settings = <String, dynamic>{};
      if (newDraft.name != old.name) settings['full_name'] = newDraft.name;
      if (newDraft.bio != old.bio) settings['bio'] = newDraft.bio;
      if (newDraft.interest != old.interest) settings['interest'] = newDraft.interest;
      if (newDraft.photoUrl != old.photoUrl) settings['photo_url'] = newDraft.photoUrl;
      if (newDraft.coverUrl != old.coverUrl) settings['cover_url'] = newDraft.coverUrl;
      if (!mapEquals(newDraft.socialLinks, old.socialLinks)) {
        settings['social_links'] = newSocialLinks;
      }
      if (!listEquals(newDraft.skills, old.skills)) settings['skills'] = newDraft.skills;
      if (_experiencesChanged(newDraft.experiences, old.experiences)) {
        settings['experiences'] = newDraft.experiences.map((e) => {
          'title': e.title,
          'organization': e.organization,
          'duration': e.duration,
          'description': e.description,
          'tech_stack': e.techStack,
        }).toList();
      }

      final hasBackendChanges = settings.isNotEmpty;
      final hasLocalOnlyChanges = _hasLocalOnlyCollaborationChanges;

      if (hasBackendChanges) {
        final err = await profileService.updateSettings(settings);
        if (err != null) {
          AppToast.error(err, title: 'Error');
          return;
        }
      }

      profileService.updateProfile(newDraft);

      if (!mounted) return;

      setState(() {
        draft = newDraft;
        _hasLocalOnlyCollaborationChanges = false;
      });

      if (!hasBackendChanges && !hasLocalOnlyChanges) {
        AppToast.info('Tidak ada perubahan.');
        _returnToProfile();
        return;
      }

      AppToast.success(
        hasLocalOnlyChanges
            ? 'Profil utama tersimpan. Riwayat kolaborasi belum tersimpan permanen.'
            : 'Profil berhasil diperbarui.',
      );
      _returnToProfile();
    } catch (e) {
      debugPrint('EditProfileView._save error: $e');
      AppToast.error('Gagal menyimpan profil. Coba lagi.', title: 'Error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _returnToProfile() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Get.offAllNamed(Routes.PROFILE);
  }

  bool get _hasUnsavedChanges {
    final old = profileService.profile.value;
    final currentSocialLinks = <String, String>{};
    if (instagramController.text.trim().isNotEmpty) {
      currentSocialLinks['instagram'] = instagramController.text.trim();
    }
    if (linkedinController.text.trim().isNotEmpty) {
      currentSocialLinks['linkedin'] = linkedinController.text.trim();
    }
    if (externalController.text.trim().isNotEmpty) {
      currentSocialLinks['website'] = externalController.text.trim();
    }

    return nameController.text.trim() != old.name ||
        bioController.text.trim() != old.bio ||
        interestController.text.trim() != old.interest ||
        draft.photoUrl != old.photoUrl ||
        draft.coverUrl != old.coverUrl ||
        !mapEquals(currentSocialLinks, old.socialLinks) ||
        !listEquals(draft.skills, old.skills) ||
        _experiencesChanged(draft.experiences, old.experiences) ||
        _hasLocalOnlyCollaborationChanges;
  }

  Future<void> _closeWithUnsavedCheck() async {
    if (!_hasUnsavedChanges) {
      Get.back();
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar tanpa menyimpan?'),
        content: const Text('Perubahan yang belum disimpan akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Keluar', style: TextStyle(color: AppC.of(context).textSecondary)),
          ),
        ],
      ),
    );
    if (discard == true) Get.back();
  }

  Future<void> showSkillSheet() async {
    final skillController = TextEditingController();
    var skills = [...draft.skills];

    try {
      await _showEditSheet(
        title: 'Perbarui skill',
        helper: 'Skill membantu sistem merekomendasikan proyek yang relevan.',
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final c = AppC.of(context);
            void addSkill(String value) {
              final skill = value.trim();
              if (skill.isEmpty ||
                  skills.any((item) => item.toLowerCase() == skill.toLowerCase())) {
                return;
              }
              setSheetState(() {
                skills = [...skills, skill];
                skillController.clear();
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return InputChip(
                      label: Text(skill),
                      onDeleted: () {
                        setSheetState(() {
                          skills = skills.where((item) => item != skill).toList();
                        });
                      },
                      backgroundColor: c.primarySoft,
                      side: BorderSide(color: c.border),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skillController,
                  onSubmitted: addSkill,
                  decoration: InputDecoration(
                    hintText: 'Cari atau tambah skill',
                    suffixIcon: IconButton(
                      onPressed: () => addSkill(skillController.text),
                      icon: const Icon(FluentIcons.add_24_regular),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        onSave: () {
          final leftover = skillController.text.trim();
          if (leftover.isNotEmpty &&
              !skills.any((item) => item.toLowerCase() == leftover.toLowerCase())) {
            skills = [...skills, leftover];
          }
          setState(() => draft = draft.copyWith(skills: skills));
          return true;
        },
      );
    } finally {
      skillController.dispose();
    }
  }

  Future<void> showExperienceSheet({ProfileExperience? experience, int? index}) async {
    final titleController = TextEditingController(
      text: experience?.title ?? '',
    );
    final orgController = TextEditingController(
      text: experience?.organization ?? '',
    );
    final descriptionController = TextEditingController(
      text: experience?.description ?? '',
    );

    var startDate = _parseDurationStart(experience?.duration);
    var endDate = _parseDurationEnd(experience?.duration);

    try {
      await _showEditSheet(
        title: experience == null ? 'Tambah pengalaman' : 'Edit pengalaman',
        helper: 'Pengalaman yang membentuk perjalanan dan skill kamu.',
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              children: [
                _SheetField(label: 'Peran atau posisi', controller: titleController),
                _SheetField(
                  label: 'Nama organisasi atau proyek',
                  controller: orgController,
                ),
                _SheetDateField(
                  label: 'Tanggal mulai',
                  value: startDate,
                  onChanged: (d) => setSheetState(() => startDate = d),
                ),
                _SheetDateField(
                  label: 'Tanggal selesai',
                  value: endDate,
                  onChanged: (d) => setSheetState(() => endDate = d),
                  isEndDate: true,
                ),
                _SheetField(
                  label: 'Ceritakan kontribusi atau pengalamanmu',
                  controller: descriptionController,
                  maxLines: 4,
                ),
              ],
            );
          },
        ),
        onSave: () {
          if (titleController.text.trim().isEmpty || orgController.text.trim().isEmpty) {
            AppToast.error('Peran dan organisasi wajib diisi.');
            return false;
          }
          if (startDate == null) {
            AppToast.error('Tanggal mulai wajib diisi.');
            return false;
          }
          final updated = ProfileExperience(
            title: titleController.text.trim(),
            organization: orgController.text.trim(),
            duration: _formatDuration(startDate!, endDate),
            description: descriptionController.text.trim(),
            techStack: experience?.techStack ?? const [],
          );
          final experiences = [...draft.experiences];
          if (index == null) {
            experiences.add(updated);
          } else {
            experiences[index] = updated;
          }
          setState(() {
            draft = draft.copyWith(experiences: experiences);
          });
          return true;
        },
      );
    } finally {
      titleController.dispose();
      orgController.dispose();
      descriptionController.dispose();
    }
  }

  void deleteExperience(ProfileExperience experience) {
    Get.bottomSheet(
      _ConfirmSheet(
        title: 'Hapus pengalaman ini?',
        message:
            'Pengalaman ini akan hilang dari profilmu, tapi bisa kamu tambahkan lagi nanti.',
        onConfirm: () {
          setState(() {
            draft = draft.copyWith(
              experiences: draft.experiences
                  .where((item) => item != experience)
                  .toList(),
            );
          });
          Get.back();
        },
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  Future<T?> _showEditSheet<T>({
    required String title,
    required String helper,
    required Widget child,
    required bool Function() onSave,
    GlobalKey<FormState>? formKey,
  }) {
    return Get.bottomSheet<T>(
      _EditBottomSheet(
        title: title,
        helper: helper,
        onSave: onSave,
        formKey: formKey,
        child: child,
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: c.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: c.surface.withValues(alpha: 0.7),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: AppColors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(FluentIcons.dismiss_24_regular),
          onPressed: _closeWithUnsavedCheck,
        ),
        title: Text(
          'Edit profil',
          style: AppFonts.interStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: AppFonts.interStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isSaving ? null : AppColors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Cover + Avatar header
          SizedBox(
            height: topPadding + 168,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover image
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: SizedBox(
                    height: topPadding + 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        draft.coverUrl.isNotEmpty
                            ? Image.network(draft.coverUrl, fit: BoxFit.cover)
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  FluentIcons.camera_24_regular,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Edit cover',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  left: 16,
                  bottom: -46,
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surface, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AppAvatar(
                            photoUrl: draft.photoUrl,
                            radius: 47,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: const Icon(
                              FluentIcons.camera_24_regular,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // AI Personalize (before form fields)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: _AiPersonalizeCard(
              onTap: _scanAndFillCv,
            ),
          ),
          const SizedBox(height: 16),
          // Form fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  label: 'Nama',
                  controller: nameController,
                  hint: 'Nama lengkap',
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Bio',
                  controller: bioController,
                  hint: 'Ceritakan tentang dirimu',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _ReadonlyField(
                  label: 'Jurusan',
                  value: draft.major,
                ),
                const SizedBox(height: 16),
                _ReadonlyField(
                  label: 'Fakultas',
                  value: draft.faculty,
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Minat',
                  controller: interestController,
                  hint: 'Bidang yang kamu minati',
                ),
                const SizedBox(height: 16),
                Text(
                  'Tautan Sosial',
                  style: AppFonts.interStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _SocialLinkField(
                  icon: FluentIcons.person_24_regular,
                  label: 'Instagram',
                  controller: instagramController,
                  hint: 'Username Instagram',
                ),
                const SizedBox(height: 12),
                _SocialLinkField(
                  icon: FluentIcons.briefcase_24_regular,
                  label: 'LinkedIn',
                  controller: linkedinController,
                  hint: 'Username LinkedIn',
                ),
                const SizedBox(height: 12),
                _SocialLinkField(
                  icon: FluentIcons.link_24_regular,
                  label: 'Tautan Eksternal',
                  controller: externalController,
                  hint: 'https://namadomain.com (Framer, GitHub, dll)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Skill',
              subtitle: 'Skill membantu sistem merekomendasikan proyek.',
              icon: FluentIcons.sparkle_24_regular,
              onEdit: showSkillSheet,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: draft.skills
                    .map((skill) => AppTextPill(label: skill))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Experience',
              subtitle: 'Pengalaman yang membentuk perjalanan dan skill kamu.',
              icon: FluentIcons.briefcase_24_regular,
              onEdit: () => showExperienceSheet(),
              actionLabel: 'Tambah',
              child: draft.experiences.isEmpty
                  ? Text(
                      'Tambahkan pengalaman agar profil lebih meyakinkan.',
                      style: AppFonts.interStyle(
                        fontSize: 13,
                        color: c.textSecondary,
                      ),
                    )
                  : Column(
                      children: draft.experiences.asMap().entries.map((entry) {
                        return _ExperiencePreviewItem(
                          experience: entry.value,
                          onEdit: () => showExperienceSheet(
                            experience: entry.value,
                            index: entry.key,
                          ),
                          onDelete: () => deleteExperience(entry.value),
                        );
                      }).toList(),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EditPreviewSection(
              title: 'Riwayat Kolaborasi',
              subtitle:
                  'Dibuat otomatis dari workspace yang selesai di REMBUGAN.',
              icon: FluentIcons.people_24_regular,
              onEdit: () {},
              hideAction: true,
              child: Column(
                children: draft.collaborationHistory.asMap().entries.map((entry) {
                  return _CollaborationVisibilityItem(
                    item: entry.value,
                    onToggle: () {
                      final collaborations = [...draft.collaborationHistory];
                      collaborations[entry.key] = entry.value.copyWith(
                        visible: !entry.value.visible,
                      );
                      setState(() {
                        draft = draft.copyWith(collaborationHistory: collaborations);
                        _hasLocalOnlyCollaborationChanges = true;
                      });
                      AppToast.info('Visibilitas riwayat hanya berubah di draft.');
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.interStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppFonts.interStyle(
            fontSize: 14,
            color: c.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.interStyle(
              fontSize: 14,
              color: c.textTertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.interStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border.withValues(alpha: 0.5)),
          ),
          child: Text(
            value.isNotEmpty ? value : 'Belum diatur oleh admin',
            style: AppFonts.interStyle(
              fontSize: 14,
              color: value.isNotEmpty ? c.textPrimary : c.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialLinkField extends StatelessWidget {
  const _SocialLinkField({
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: AppColors.primary500, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: AppFonts.interStyle(fontSize: 14, color: c.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppFonts.interStyle(fontSize: 14, color: c.textTertiary),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: c.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AiPersonalizeCard extends StatelessWidget {
  const _AiPersonalizeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            c.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    FluentIcons.sparkle_24_filled,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalisasi dengan AI',
                        style: AppFonts.interStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Scan ulang resume untuk merapikan bio, skill, dan pengalaman.',
                        style: AppFonts.interStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FluentIcons.chevron_right_24_regular,
                  color: c.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditPreviewSection extends StatelessWidget {
  const _EditPreviewSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.child,
    this.actionLabel,
    this.hideAction = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final Widget child;
  final String? actionLabel;
  final bool hideAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: c.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.interStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppFonts.interStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hideAction)
                actionLabel == null
                    ? _MiniEditButton(onTap: onEdit)
                    : TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(FluentIcons.add_24_regular, size: 16),
                        label: Text(actionLabel!),
                      ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _ExperiencePreviewItem extends StatelessWidget {
  const _ExperiencePreviewItem({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

  final ProfileExperience experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.title,
                  style: AppFonts.interStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${experience.organization} - ${experience.duration}',
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  experience.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(FluentIcons.edit_24_regular, size: 16),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(FluentIcons.delete_24_regular, size: 16),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollaborationVisibilityItem extends StatelessWidget {
  const _CollaborationVisibilityItem({
    required this.item,
    required this.onToggle,
  });

  final PlatformCollaboration item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            item.visible
                ? FluentIcons.eye_24_regular
                : FluentIcons.eye_off_24_regular,
            size: 18,
            color: c.textPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.workspace,
                  style: AppFonts.interStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.role} - ${item.members} anggota - ${item.status}',
                  style: AppFonts.interStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(item.visible ? 'Sembunyikan' : 'Tampilkan'),
          ),
        ],
      ),
    );
  }
}

class _EditBottomSheet extends StatefulWidget {
  const _EditBottomSheet({
    required this.title,
    required this.helper,
    required this.onSave,
    this.formKey,
    required this.child,
  });

  final String title;
  final String helper;
  final bool Function() onSave;
  final GlobalKey<FormState>? formKey;
  final Widget child;

  @override
  State<_EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<_EditBottomSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
          child: SingleChildScrollView(
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.borderStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: AppFonts.headingStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.helper,
                    style: AppFonts.interStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  widget.child,
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : Get.back,
                          child: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                  onPressed: _isSaving
                              ? null
                              : () {
                                  if (widget.formKey?.currentState?.validate() == false) return;
                                  setState(() => _isSaving = true);
                                  try {
                                    final saved = widget.onSave();
                                    if (saved) {
                                      Navigator.of(context).pop();
                                    }
                                  } finally {
                                    if (mounted) setState(() => _isSaving = false);
                                  }
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.headingStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppFonts.interStyle(
                fontSize: 13,
                height: 1.45,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    child: const Text('Batalkan'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.helper,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.interStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: AppFonts.interStyle(
                fontSize: 12,
                height: 1.35,
                color: c.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _SheetDateField extends StatelessWidget {
  const _SheetDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isEndDate = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool isEndDate;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final dateStr = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.interStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? now,
                firstDate: DateTime(1900),
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) onChanged(picked);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(FluentIcons.calendar_24_regular, size: 16, color: c.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateStr ?? (isEndDate ? 'Sekarang' : 'Pilih tanggal'),
                      style: AppFonts.interStyle(
                        fontSize: 14,
                        color: dateStr != null ? c.textPrimary : c.textTertiary,
                      ),
                    ),
                  ),
                  if (value != null)
                    GestureDetector(
                      onTap: () => onChanged(null),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(FluentIcons.dismiss_circle_24_regular, size: 16, color: c.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEditButton extends StatelessWidget {
  const _MiniEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.grey600, AppColors.grey800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            FluentIcons.edit_24_regular,
            color: AppColors.white,
            size: 14,
          ),
        ),
        ),
      ),
    );
  }
}
