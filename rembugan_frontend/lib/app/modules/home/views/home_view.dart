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
              color: active ? c.textPrimary : c.grey400,
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
    final c = AppC.of(context);
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
        Divider(height: 1, color: c.border),
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
          name: 'Marvin McKinney',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Tadi siang habis coba fitur scan resume terbaru di Rembugan, gila ternyata akurat banget ya! Skill Figma langsung ke-detect otomatis. UI-nya juga clean banget, jadi makin semangat nyari proyek kolaborasi di sini. Mantap tim developer! 👏',
          hasImage: false,
          initialLikes: 98,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context),
          onShowShare: () => _showShareSheet(context),
        ),
        Divider(height: 1, color: c.border),
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
        Divider(height: 1, color: c.border),
        _PostCardWidget(
          avatarUrl: 'https://i.pravatar.cc/100?img=33',
          name: 'Cameron Williamson',
          subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
          content:
              'Guys, pendaftaran Essay & Poster Competition Creative Fest 2026 udah mau ditutup tanggal 20 Juni besok. Buat yang pengen asah portofolio tingkat nasional wajib banget ikut sih. Link registrasi ada di detail lomba ya! 🎉',
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
      Divider(height: 1, color: c.border),

      // Proyek Rekomendasi
      _buildRecommendedProjectsSection(context),
      Divider(height: 1, color: c.border),

      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
        name: 'Marvin McKinney',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Tadi siang habis coba fitur scan resume terbaru di Rembugan, gila ternyata akurat banget ya! Skill Figma langsung ke-detect otomatis. UI-nya juga clean banget, jadi makin semangat nyari proyek kolaborasi di sini. Mantap tim developer! 👏',
        hasImage: false,
        initialLikes: 98,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border),

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
      Divider(height: 1, color: c.border),

      // Lomba Rekomendasi
      _buildRecommendedCompetitionsSection(context),
      Divider(height: 1, color: c.border),

      _PostCardWidget(
        avatarUrl: 'https://i.pravatar.cc/100?img=33',
        name: 'Cameron Williamson',
        subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
        content:
            'Guys, pendaftaran Essay & Poster Competition Creative Fest 2026 udah mau ditutup tanggal 20 Juni besok. Buat yang pengen asah portofolio tingkat nasional wajib banget ikut sih. Link registrasi ada di detail lomba ya! 🎉',
        hasImage: true,
        imageAssets: const ['lib/assets/img/contoh poster1.jpeg'],
        initialLikes: 87,
        showFollowButton: true,
        onShowComments: () => showCommentsSheet(context),
        onShowShare: () => _showShareSheet(context),
      ),
      Divider(height: 1, color: c.border),

      // Orang Rekomendasi
      _buildRecommendedPeopleSection(context),
      const SizedBox(height: 10),
    ];
  }

  Widget _buildRecommendedProjectsSection(BuildContext context) {
    final c = AppC.of(context);
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
                  color: c.textPrimary,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: c.textSecondary,
              ),
            ],
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
    final c = AppC.of(context);
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
                  color: c.textPrimary,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: c.textSecondary,
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
    final c = AppC.of(context);
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
                  color: c.textPrimary,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: c.textSecondary,
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
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 32,
        child: Icon(icon, size: 24, color: c.grey900),
      ),
    );
  }
}

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
    final c = AppC.of(context);
    final visibleSkills = widget.project.skills.take(2).toList();
    final matchLabel = widget.index.isEven ? 'Sesuai skill' : 'Cocok jurusan';

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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: _isPressed ? AppColors.primary200 : c.border,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.project.faculty.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 10.5,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.info700,
                      ),
                    ),
                  ),
                  _FeedMatchBadge(label: matchLabel),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.project.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 11,
                height: 1.25,
                color: c.grey600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: visibleSkills
                    .map(
                      (skill) =>
                          _FeedMiniChip(label: skill, color: c.grey100),
                    )
                    .toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  _FeedProjectAvatarStack(count: widget.project.memberAvatars.length),
                  const SizedBox(width: 8),
                  Text(
                    widget.project.postedAgo,
                  style: AppFonts.satoshiStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: c.grey500,
                  ),
                  ),
                  const Spacer(),
                  Icon(
                    FluentIcons.people_team_24_filled,
                    size: 16,
                    color: c.grey700,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.project.filledSlots}/${widget.project.totalSlots}',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedMatchBadge extends StatelessWidget {
  const _FeedMatchBadge({required this.label});

  final String label;

  _StatusTone get tone {
    final value = label.toLowerCase();
    if (value.contains('cocok')) {
      return const _StatusTone(
        background: AppColors.info50,
        border: AppColors.info50,
        foreground: AppColors.info700,
      );
    }
    if (value.contains('ditutup') || value.contains('deadline')) {
      return const _StatusTone(
        background: AppColors.warning50,
        border: AppColors.warning100,
        foreground: AppColors.warning700,
      );
    }
    if (value.contains('penuh')) {
      return const _StatusTone(
        background: AppColors.danger50,
        border: AppColors.danger100,
        foreground: AppColors.danger600,
      );
    }
    if (value.contains('trending')) {
      return const _StatusTone(
        background: AppColors.info50,
        border: AppColors.info100,
        foreground: AppColors.info600,
      );
    }
    if (value.contains('baru')) {
      return const _StatusTone(
        background: AppColors.primary50,
        border: AppColors.primary50,
        foreground: AppColors.primary400,
      );
    }
    return const _StatusTone(
      background: AppColors.info50,
      border: AppColors.info50,
      foreground: AppColors.info700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: style.background),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: style.foreground,
        ),
      ),
    );
  }
}

class _StatusTone {
  const _StatusTone({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}

class _FeedMiniChip extends StatelessWidget {
  const _FeedMiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: c.grey700,
        ),
      ),
    );
  }
}

class _FeedProjectAvatarStack extends StatelessWidget {
  const _FeedProjectAvatarStack({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final visibleCount = count.clamp(1, 2);

    return SizedBox(
      width: 57,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visibleCount; i++)
            Positioned(
              left: i * 15,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 1.4),
                ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: AssetImage('lib/assets/img/avatar.png'),
                ),
              ),
            ),
          Positioned(
            left: visibleCount * 15,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: c.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 14,
                color: c.grey500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedSkillChip extends StatelessWidget {
  const _FeedSkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: c.grey100,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: c.grey600,
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
    final c = AppC.of(context);
    return Container(
      width: 165,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 1.2),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppNetworkAvatar(radius: 24, imageUrl: person.avatarUrl),
            const SizedBox(height: 8),
            Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              person.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                color: c.textSecondary,
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
                        color: c.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                      ),
                      child: Text(
                        tag,
                        style: AppFonts.satoshiStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
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
                        ? c.grey100
                        : AppColors.primary,
                    foregroundColor: person.isFollowing.value
                        ? c.textSecondary
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
                          ? c.textSecondary
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
    final c = AppC.of(context);
    setState(() {
      _isFollowing = !_isFollowing;
    });
    Get.snackbar(
      _isFollowing ? 'Mengikuti' : 'Batal Mengikuti',
      _isFollowing
          ? 'Kamu sekarang mengikuti ${widget.name}.'
          : 'Kamu berhenti mengikuti ${widget.name}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isFollowing ? AppColors.success50 : c.surface,
      colorText: _isFollowing ? AppColors.success700 : c.textPrimary,
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
    final c = AppC.of(context);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    Get.snackbar(
      _isBookmarked ? 'Postingan disimpan' : 'Postingan dihapus',
      _isBookmarked
          ? 'Postingan berhasil disimpan ke penanda kamu.'
          : 'Postingan dihapus dari penanda kamu.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isBookmarked ? AppColors.success50 : c.surface,
      colorText: _isBookmarked ? AppColors.success700 : c.textPrimary,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: widget.onShowComments,
      child: Container(
        color: c.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.OTHER_PROFILE),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: c.primarySoft,
                    backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
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
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '• 5 Menit',
                              style: AppFonts.satoshiStyle(
                                fontSize: 11,
                                color: c.grey400,
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
                            color: c.grey500,
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
                        color: c.surface,
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
                fontSize: 14,
                color: c.textPrimary,
                height: 1.38,
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
                  _isLiked
                      ? FluentIcons.heart_24_filled
                      : FluentIcons.heart_24_regular,
                  '$_likeCount',
                  'menyukai postingan',
                  _isLiked ? AppColors.error500 : c.grey500,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 18),
                _buildInteractionItem(
                  FluentIcons.chat_24_regular,
                  '20',
                  'berkomentar',
                  c.grey500,
                  onTap: widget.onShowComments,
                ),
                const Spacer(),
                _buildInteractionItem(
                  FluentIcons.send_24_regular,
                  '',
                  'membagikan postingan',
                  c.grey500,
                  onTap: widget.onShowShare,
                ),
                const SizedBox(width: 22),
                _buildInteractionItem(
                  _isBookmarked
                      ? FluentIcons.bookmark_24_filled
                      : FluentIcons.bookmark_24_regular,
                  '',
                  'menyimpan postingan',
                  _isBookmarked ? AppColors.warning500 : c.grey500,
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
    final c = AppC.of(context);
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
                  color: c.textSecondary,
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
    final c = AppC.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                color: c.grey200,
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
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: c.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Cari teman...',
              hintStyle: AppFonts.satoshiStyle(
                fontSize: 12,
                color: c.textTertiary,
              ),
              prefixIcon: Icon(
                FluentIcons.search_24_regular,
                size: 18,
                color: c.textTertiary,
              ),
              filled: true,
              fillColor: c.grey50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: c.border),
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
                            color: c.textPrimary,
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
                              ? c.grey100
                              : AppColors.primary,
                          foregroundColor: friend['sent']
                              ? c.textTertiary
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
          Divider(color: c.border),
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
    final c = AppC.of(context);
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
              decoration: BoxDecoration(
                color: c.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c.textPrimary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
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
