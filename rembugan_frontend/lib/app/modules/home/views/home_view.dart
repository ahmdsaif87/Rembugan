import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../social/views/comment_view.dart';
import '../controllers/home_controller.dart';
import '../../explore/views/explore_view.dart';
import 'widgets/header_icon.dart';
import 'widgets/post_card_widget.dart';
import 'widgets/skeleton_block.dart';
import 'widgets/recommended_project_card.dart';
import 'widgets/recommended_competition_card.dart';
import 'widgets/recommended_person_card.dart';
import 'widgets/share_sheet.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(context),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                  children: _buildMixedFeed(context),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.home),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rembugan.',
              style: AppFonts.headingStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: c.grey900,
                height: 1.1,
              ),
            ),
          ),
          HeaderIcon(
            icon: FluentIcons.chat_empty_24_regular,
            tooltip: 'Chat',
            onTap: () => Get.toNamed(Routes.CHAT),
          ),
          const SizedBox(width: 18),
          HeaderIcon(
            icon: FluentIcons.alert_24_regular,
            tooltip: 'Notifikasi',
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          const SizedBox(width: 18),
          HeaderIcon(
            icon: FluentIcons.search_24_regular,
            tooltip: 'Cari',
            onTap: () => Get.toNamed(Routes.SEARCH),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.border)),
        ),
        child: Obx(
          () => Row(
            children: [
              _buildTabButton('Untukmu', controller.activeTab.value == 0, 0, context),
              _buildTabButton('Mengikuti', controller.activeTab.value == 1, 1, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, int index, BuildContext context) {
    final c = AppC.of(context);
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => controller.setTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 40,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? AppColors.primary500 : AppColors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: active ? c.textPrimary : c.grey500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => const ShareSheet(),
    );
  }

  List<Widget> _buildMixedFeed(BuildContext context) {
    final c = AppC.of(context);
    if (controller.isLoading.value) {
      return _buildSkeletonFeed(context);
    }
    if (controller.hasError.value) {
      return _buildErrorFeed(context);
    }
    if (controller.activeTab.value == 1) {
      // "Mengikuti" tab â€” empty state until user follows people
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 60),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FluentIcons.person_add_24_regular,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada yang diikuti',
                style: AppFonts.satoshiStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ikuti orang untuk melihat postingan mereka di sini.\nTemukan teman satu jurusan atau kolaborator baru!',
                textAlign: TextAlign.center,
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  color: c.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.find<HomeController>().setTab(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    'Cari Orang',
                    style: AppFonts.satoshiStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // "Untukmu" tab gets the mixed feed
    return [
      PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        name: 'Raka Pratama',
        subtitle: 'D4 Teknik Informatika - 3 jam yang lalu',
        content:
            'Butuh 1 UI/UX Designer buat gabung tim ikut Lomba Inovasi Digital Kemendikbud 2026. Deadline pendaftaran 2 minggu lagi. UI udah jadi 60% pake Figma, kita perlu bantu polish dan bikin prototype interaktif. Yang minat chat ya!',
        hasImage: true,
        imageAssets: const [
          'lib/assets/img/contoh poster1.jpeg',
        ],
        initialLikes: 87,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border.withValues(alpha: 0.3)),
      const SizedBox(height: 20),

      // Proyek Rekomendasi
      _buildRecommendedProjectsSection(context),
      const SizedBox(height: 24),

      PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=47',
        name: 'Sari Indah',
        subtitle: 'S1 Sistem Informasi - 8 jam yang lalu',
        content:
            'Halo temen-temen! Aku lagi nyari 2 orang buat project aplikasi peminjaman alat laboratorium kampus. Butuh 1 Flutter dev (yang udah pernah pake GetX) & 1 backend (Node.js + PostgreSQL). Udah dapat dosen pembimbing, tinggal nunggu tim lengkap buat mulai. Ini buat tugas akhir sekalian lomba juga.',
        hasImage: false,
        initialLikes: 124,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border.withValues(alpha: 0.3)),
      const SizedBox(height: 16),

      PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=55',
        name: 'Dimas Prayoga',
        subtitle: 'D3 Manajemen Informatika - 1 hari yang lalu',
        content:
            'Baru selesai ikut Gemastik 2026 kemaren, walau cuma dapet juara harapan tapi banyak banget pelajaran berharganya. Tips buat temen-temen yang mau ikut taun depan: (1) Pilih tim yang komit, bukan yang jago doang. (2) Siapin Pitching Deck dari H-1 bulan. (3) Jangan takut revisi besar di tengah jalan. Tim kami ganti tech stack 2 minggu sebelum submit dan tetep lolos.',
        hasImage: false,
        initialLikes: 231,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border.withValues(alpha: 0.3)),
      const SizedBox(height: 20),

      // Lomba Rekomendasi
      _buildRecommendedCompetitionsSection(context),
      const SizedBox(height: 24),

      PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=60',
        name: 'Fitriani Nurul',
        subtitle: 'S1 Ilmu Komputer - 5 jam yang lalu',
        content:
            'Mencari tim untuk kompetisi Data Science UIC 2026 tingkat nasional. Butuh: 1 orang yg jago Python & pandas buat preprocessing, 1 orang paham statistik/modeling, 1 orang buat visualisasi & storytelling. Tim sudah ada 2 orang (termasuk aku). Target bikin solusi AI buat prediksi pola kemacetan di kota besar. Serius dan bisa komit sampe final ya!',
        hasImage: true,
        imageAssets: const ['lib/assets/img/contoh poster1.jpeg'],
        initialLikes: 156,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border.withValues(alpha: 0.3)),
      const SizedBox(height: 20),

      // Orang Rekomendasi
      _buildRecommendedPeopleSection(context),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _buildSkeletonFeed(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            SkeletonBlock(height: 80),
            const SizedBox(height: 16),
            SkeletonBlock(height: 60),
            const SizedBox(height: 16),
            SkeletonBlock(height: 200),
            const SizedBox(height: 16),
            SkeletonBlock(height: 60),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildErrorFeed(BuildContext context) {
    final c = AppC.of(context);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 80),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.wifi_off_24_regular,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal memuat',
              style: AppFonts.satoshiStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Terjadi kesalahan. Coba lagi.',
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => controller.loadRecommendations(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildRecommendedProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: AppSectionHeader(
            title: 'Rekomendasi Proyek',
          ),
        ),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: controller.recommendedProjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final project = controller.recommendedProjects[index];
              return RecommendedProjectCard(
                project: project,
                index: index,
                onTap: () => ExploreView.showProjectSheet(context, project),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedCompetitionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: AppSectionHeader(
            title: 'Rekomendasi Lomba',
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: controller.recommendedCompetitions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final competition = controller.recommendedCompetitions[index];
              return RecommendedCompetitionCard(
                competition: competition,
                index: index,
                onTap: () => ExploreView.showCompetitionSheet(
                  context,
                  competition,
                  index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedPeopleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: AppSectionHeader(
            title: 'Rekomendasi Orang',
          ),
        ),
        SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: controller.recommendedPeople.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final person = controller.recommendedPeople[index];
              return RecommendedPersonCard(
                person: person,
                onFollow: () => controller.toggleFollowPerson(person),
              );
            },
          ),
        ),
      ],
    );
  }

}
