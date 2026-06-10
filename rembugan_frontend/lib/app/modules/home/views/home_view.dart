import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../social/views/comment_view.dart';
import '../controllers/home_controller.dart';
import '../../explore/domain/entities/project.dart';
import '../../explore/domain/entities/competition.dart';
import '../../explore/views/explore_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
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

  Widget _buildHeader() {
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
                color: AppColors.grey900,
                height: 1.1,
              ),
            ),
          ),
          _HeaderIcon(
            icon: FluentIcons.chat_empty_24_regular,
            onTap: () => Get.toNamed(Routes.CHAT),
          ),
          const SizedBox(width: 18),
          _HeaderIcon(
            icon: FluentIcons.alert_24_regular,
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          const SizedBox(width: 18),
          _HeaderIcon(icon: FluentIcons.search_24_regular, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.grey200)),
        ),
        child: Obx(
          () => Row(
            children: [
              _buildTabButton('Untukmu', controller.activeTab.value == 0, 0),
              _buildTabButton('Mengikuti', controller.activeTab.value == 1, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, int index) {
    return Expanded(
      child: GestureDetector(
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
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: active ? AppColors.grey900 : AppColors.grey400,
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
      builder: (context) => const _ShareSheet(),
    );
  }

  List<Widget> _buildMixedFeed(BuildContext context) {
    if (controller.activeTab.value == 1) {
      // "Mengikuti" tab gets the original pure posts (or customized)
      return [
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=33',
          name: 'Cameron Williamson',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Ada yang tertarik gabung tim buat ikut Creative Fest 2026? Kuota tim tinggal 1 slot lagi buat backend developer. Kita rencana pake FastAPI + PostgreSQL. Yang minat silakan cek profil atau langsung chat ya! 🚀🚀',
          hasImage: true,
          imageAssets: const [
            'lib/assets/img/contoh poster1.jpeg',
            'lib/assets/img/contoh poster2.jpeg',
          ],
          initialLikes: 142,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context),
          onShowShare: () => _showShareSheet(context),
        ),
        const Divider(height: 1, color: AppColors.grey200),
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
          name: 'Marvin McKinney',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Tadi siang habis coba fitur scan resume terbaru di Rembugan, gila ternyata akurat banget ya! Skill Figma langsung ke-detect otomatis. UI-nya juga clean banget, jadi makin semangat nyari proyek kolaborasi di sini. Mantap tim developer! 👏✨',
          hasImage: false,
          initialLikes: 98,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context),
          onShowShare: () => _showShareSheet(context),
        ),
        const Divider(height: 1, color: AppColors.grey200),
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
          name: 'Marvin McKinney',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Sharing sedikit tips buat temen-temen D4 Teknik Informatika yang lagi ngerjain project akhir: Coba biasain bikin design system di Figma dulu sebelum masuk ke codingan Flutter. Ini bener-bener ngehemat waktu integrasi UI nanti dan bikin komponen jadi reusable!',
          hasImage: false,
          initialLikes: 205,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context),
          onShowShare: () => _showShareSheet(context),
        ),
        const Divider(height: 1, color: AppColors.grey200),
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=33',
          name: 'Cameron Williamson',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Guys, pendaftaran Essay & Poster Competition Creative Fest 2026 udah mau ditutup tanggal 20 Juni besok. Buat yang pengen asah portofolio tingkat nasional wajib banget ikut sih. Link registrasi ada di detail lomba ya! 🎨✍️',
          hasImage: true,
          imageAssets: const ['lib/assets/img/contoh poster1.jpeg'],
          initialLikes: 87,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context),
          onShowShare: () => _showShareSheet(context),
        ),
      ];
    }

    // "Untukmu" tab gets the mixed feed
    return [
      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        name: 'Cameron Williamson',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Ada yang tertarik gabung tim buat ikut Creative Fest 2026? Kuota tim tinggal 1 slot lagi buat backend developer. Kita rencana pake FastAPI + PostgreSQL. Yang minat silakan cek profil atau langsung chat ya! 🚀🚀',
        hasImage: true,
        imageAssets: const [
          'lib/assets/img/contoh poster1.jpeg',
          'lib/assets/img/contoh poster2.jpeg',
        ],
        initialLikes: 142,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      const Divider(height: 1, color: AppColors.grey200),

      // Proyek Rekomendasi
      _buildRecommendedProjectsSection(context),
      const Divider(height: 1, color: AppColors.grey200),

      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        name: 'Marvin McKinney',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Tadi siang habis coba fitur scan resume terbaru di Rembugan, gila ternyata akurat banget ya! Skill Figma langsung ke-detect otomatis. UI-nya juga clean banget, jadi makin semangat nyari proyek kolaborasi di sini. Mantap tim developer! 👏✨',
        hasImage: false,
        initialLikes: 98,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      const Divider(height: 1, color: AppColors.grey200),

      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        name: 'Marvin McKinney',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Sharing sedikit tips buat temen-temen D4 Teknik Informatika yang lagi ngerjain project akhir: Coba biasain bikin design system di Figma dulu sebelum masuk ke codingan Flutter. Ini bener-bener ngehemat waktu integrasi UI nanti dan bikin komponen jadi reusable!',
        hasImage: false,
        initialLikes: 205,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      const Divider(height: 1, color: AppColors.grey200),

      // Lomba Rekomendasi
      _buildRecommendedCompetitionsSection(context),
      const Divider(height: 1, color: AppColors.grey200),

      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        name: 'Cameron Williamson',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Guys, pendaftaran Essay & Poster Competition Creative Fest 2026 udah mau ditutup tanggal 20 Juni besok. Buat yang pengen asah portofolio tingkat nasional wajib banget ikut sih. Link registrasi ada di detail lomba ya! 🎨✍️',
        hasImage: true,
        imageAssets: const ['lib/assets/img/contoh poster1.jpeg'],
        initialLikes: 87,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      const Divider(height: 1, color: AppColors.grey200),

      // Orang Rekomendasi
      _buildRecommendedPeopleSection(context),
      const SizedBox(height: 10),
    ];
  }

  Widget _buildRecommendedProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Proyek',
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: controller.recommendedProjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final project = controller.recommendedProjects[index];
              return _RecommendedProjectCard(
                project: project,
                index: index,
                onTap: () => ExploreView.showProjectSheet(context, project),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendedCompetitionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Lomba',
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
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
              return _RecommendedCompetitionCard(
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendedPeopleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Orang',
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
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
              return _RecommendedPersonCard(
                person: person,
                onFollow: () => controller.toggleFollowPerson(person),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Details sheets now directly invoke static ExploreView.showProjectSheet/showCompetitionSheet
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 32,
        child: Icon(icon, size: 24, color: AppColors.grey900),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  RECOMMENDED CARDS WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _RecommendedProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const _RecommendedProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
  });

  @override
  State<_RecommendedProjectCard> createState() =>
      _RecommendedProjectCardState();
}

class _RecommendedProjectCardState extends State<_RecommendedProjectCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 1. Determine index-based semantic color, badge, and reason
    final Color semanticColor = switch (widget.index % 2) {
      0 => AppColors.warning500, // Amber/Yellow (Cocok Untukmu)
      _ => AppColors.success500, // Green (Direkomendasikan)
    };

    final String badgeText = switch (widget.index % 2) {
      0 => '✨ Cocok Untukmu',
      _ => '⭐ Direkomendasikan',
    };

    final Color badgeBg = switch (widget.index % 2) {
      0 => AppColors.warning50,
      _ => AppColors.success50,
    };

    final Color badgeBorder = switch (widget.index % 2) {
      0 => AppColors.warning100,
      _ => AppColors.success100,
    };

    final Color badgeTextCol = switch (widget.index % 2) {
      0 => AppColors.warning700,
      _ => AppColors.success500,
    };

    final String reasonText = switch (widget.index % 2) {
      0 => 'Sesuai dengan keahlian Flutter kamu',
      _ => 'Banyak dicari di jurusan kamu',
    };

    final IconData reasonIcon = switch (widget.index % 2) {
      0 => Icons.auto_awesome_outlined,
      _ => Icons.trending_up_rounded,
    };

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.grey50, // premium off-white/cool-gray surface!
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isPressed ? AppColors.grey400 : AppColors.grey300,
              width: 1.2,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : AppShadows.medium,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              children: [
                // Top subtle semantic color accent strip!
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 3,
                  child: Container(color: semanticColor),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 15, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row (Category Tag & Premium Small Badge)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              widget.project.category.toUpperCase(),
                              style: AppFonts.satoshiStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              border: Border.all(
                                color: badgeBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: AppFonts.satoshiStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: badgeTextCol,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        widget.project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Description
                      Text(
                        widget.project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Subtle Alasan Rekomendasi (Helper text)
                      Row(
                        children: [
                          Icon(
                            reasonIcon,
                            size: 12.5,
                            color: semanticColor.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reasonText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppColors.grey200),
                      const SizedBox(height: 8),
                      // Bottom Row (Owner Avatar & Slot Status)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundImage: const AssetImage(
                              'lib/assets/img/avatar.png',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.project.postedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(
                                AppRadius.xxs,
                              ),
                            ),
                            child: Text(
                              '${widget.project.openSlots} slot',
                              style: AppFonts.satoshiStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeTextCol,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCompetitionCard extends StatelessWidget {
  final Competition competition;
  final int index;
  final VoidCallback onTap;

  const _RecommendedCompetitionCard({
    required this.competition,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final posterAsset = switch (index % 4) {
      0 => 'lib/assets/img/contoh poster1.jpeg',
      1 => 'lib/assets/img/contoh poster2.jpeg',
      2 => 'lib/assets/img/contoh poster3.jpeg',
      _ => 'lib/assets/img/contoh poster4.jpeg',
    };

    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
        image: DecorationImage(
          image: AssetImage(posterAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0.08),
                  AppColors.black.withValues(alpha: 0.35),
                  AppColors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tag & Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        competition.category.toUpperCase(),
                        style: AppFonts.satoshiStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning500,
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                      ),
                      child: Text(
                        competition.badge,
                        style: AppFonts.satoshiStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom content (Title, organizer, deadline)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            competition.organizer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 10.5,
                              color: AppColors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 10,
                          color: AppColors.white.withValues(alpha: 0.72),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          competition.deadline,
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
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

class _RecommendedPersonCard extends StatelessWidget {
  final RecommendedPerson person;
  final VoidCallback onFollow;

  const _RecommendedPersonCard({required this.person, required this.onFollow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primarySoft,
              backgroundImage: NetworkImage(person.avatarUrl),
            ),
            const SizedBox(height: 8),
            Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              person.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: person.tags
                  .take(2)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                      ),
                      child: Text(
                        tag,
                        style: AppFonts.satoshiStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 28,
                child: TextButton(
                  onPressed: onFollow,
                  style: TextButton.styleFrom(
                    backgroundColor: person.isFollowing.value
                        ? AppColors.grey100
                        : AppColors.primary,
                    foregroundColor: person.isFollowing.value
                        ? AppColors.textSecondary
                        : AppColors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  child: Text(
                    person.isFollowing.value ? 'Mengikuti' : 'Ikuti',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: person.isFollowing.value
                          ? AppColors.textSecondary
                          : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCardWidget extends StatefulWidget {
  const _PostCardWidget({
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.content,
    required this.hasImage,
    this.imageUrl,
    this.imageAssets,
    this.showFollowButton = true,
    this.initialLikes = 120,
    required this.onShowComments,
    required this.onShowShare,
  });

  final String avatarUrl;
  final String name;
  final String subtitle;
  final String content;
  final bool hasImage;
  final String? imageUrl;
  final List<String>? imageAssets;
  final bool showFollowButton;
  final int initialLikes;
  final VoidCallback onShowComments;
  final VoidCallback onShowShare;

  @override
  State<_PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<_PostCardWidget> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isFollowing = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikes;
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    Get.snackbar(
      _isFollowing ? 'Mengikuti' : 'Batal Mengikuti',
      _isFollowing
          ? 'Kamu sekarang mengikuti ${widget.name}.'
          : 'Kamu berhenti mengikuti ${widget.name}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isFollowing ? AppColors.success50 : AppColors.white,
      colorText: _isFollowing ? AppColors.success700 : AppColors.textPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    Get.snackbar(
      _isBookmarked ? 'Postingan disimpan' : 'Postingan dihapus',
      _isBookmarked
          ? 'Postingan berhasil disimpan ke penanda kamu.'
          : 'Postingan dihapus dari penanda kamu.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isBookmarked ? AppColors.success50 : AppColors.white,
      colorText: _isBookmarked ? AppColors.success700 : AppColors.textPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onShowComments,
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: AssetImage('lib/assets/img/avatar.png'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Dede Fernanda',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.satoshiStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.grey900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '• 5 Menit',
                              style: AppFonts.satoshiStyle(
                                fontSize: 11,
                                color: AppColors.grey400,
                                fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Teknik Informatika',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 12,
                              color: AppColors.grey500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showFollowButton)
                    GestureDetector(
                      onTap: _toggleFollow,
                      child: Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.primary500),
                        ),
                        child: Text(
                          _isFollowing ? 'Mengikuti' : 'Ikuti',
                          style: AppFonts.satoshiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.content,
                style: AppFonts.satoshiStyle(
                  fontSize: 15,
                  color: AppColors.grey900,
                  height: 1.36,
                ),
              ),
              if (widget.imageAssets != null &&
                  widget.imageAssets!.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (widget.imageAssets!.length == 1)
                  GestureDetector(
                    onTap: () => _showImageViewer(
                      context,
                      assetPath: widget.imageAssets!.first,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.asset(
                        widget.imageAssets!.first,
                        width: double.infinity,
                        height: 373,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (widget.imageAssets!.length == 2)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImageViewer(
                            context,
                            assetPath: widget.imageAssets![0],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.asset(
                              widget.imageAssets![0],
                              height: 236,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImageViewer(
                            context,
                            assetPath: widget.imageAssets![1],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Image.asset(
                              widget.imageAssets![1],
                              height: 236,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ] else if (widget.hasImage && widget.imageUrl != null) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () =>
                      _showImageViewer(context, imageUrl: widget.imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      widget.imageUrl!,
                      width: double.infinity,
                      height: 373,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildInteractionItem(
                    _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                    '$_likeCount',
                    'menyukai postingan',
                    _isLiked ? AppColors.error500 : AppColors.grey500,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 18),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    '20',
                    'berkomentar',
                    AppColors.grey500,
                    onTap: widget.onShowComments,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    'membagikan postingan',
                    AppColors.grey500,
                    onTap: widget.onShowShare,
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    _isBookmarked ? FluentIcons.bookmark_24_filled : FluentIcons.bookmark_24_regular,
                    '',
                    'menyimpan postingan',
                    _isBookmarked ? AppColors.warning500 : AppColors.grey500,
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildInteractionItem(
      IconData icon,
      String count,
      String feature,
      Color activeColor, {
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(icon, color: activeColor, size: 22),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  count,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet();

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Aisyah', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Nadia', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Raka', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Dede', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Bagikan ke Teman',
            style: AppFonts.headingStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Cari teman...',
              hintStyle: AppFonts.satoshiStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(
                FluentIcons.search_24_regular,
                size: 18,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.grey50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(friend['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          friend['name'],
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: friend['sent']
                            ? null
                            : () {
                                setState(() {
                                  friend['sent'] = true;
                                });
                                Get.snackbar(
                                  'Terkirim',
                                  'Postingan dibagikan ke ${friend['name']}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.success50,
                                  colorText: AppColors.success700,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: friend['sent']
                              ? AppColors.grey100
                              : AppColors.primary,
                          foregroundColor: friend['sent']
                              ? AppColors.textTertiary
                              : AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        child: Text(
                          friend['sent'] ? 'Terkirim' : 'Kirim',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.grey200),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareAction(
                icon: FluentIcons.copy_24_regular,
                label: 'Salin Link',
                onTap: () {
                  Clipboard.setData(
                    const ClipboardData(text: 'https://rembugan.app/post/1'),
                  );
                  Navigator.pop(context);
                  Get.snackbar(
                    'Tautan disalin',
                    'Link postingan berhasil disalin ke clipboard.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success50,
                    colorText: AppColors.success700,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              _buildShareAction(
                icon: FluentIcons.chat_24_regular,
                label: 'WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'WhatsApp',
                    'Membuka WhatsApp...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildShareAction(
                icon: FluentIcons.send_24_regular,
                label: 'Telegram',
                onTap: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Telegram',
                    'Membuka Telegram...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showImageViewer(
  BuildContext context, {
  String? assetPath,
  String? imageUrl,
}) {
  showDialog<void>(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: AppColors.black.withValues(alpha: 0.4)),
            ),
          ),
          Positioned(
            top: 40,
            right: AppSpacing.lg,
            child: Material(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.95,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: assetPath != null
                      ? Image.asset(assetPath, fit: BoxFit.contain)
                      : Image.network(imageUrl!, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
