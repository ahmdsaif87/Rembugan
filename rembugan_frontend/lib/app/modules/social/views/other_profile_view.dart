import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';

class OtherProfileView extends StatefulWidget {
  const OtherProfileView({super.key});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  int selectedTabIndex = 0;
  bool isFollowing = false;
  bool _isLoading = true;

  final _api = Get.find<ApiClient>();

  String _id = '';
  String _name = '';
  String _role = '';
  String _avatarUrl = '';
  String _coverUrl = '';
  String _bio = '';
  List<String> _tags = [];
  List<ProfileExperience> _experiences = [];
  List<Map<String, dynamic>> _portfolios = [];
  List<Map<String, dynamic>> _projectHistory = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _id = args?['id'] as String? ?? '';
    _name = args?['name'] as String? ?? '';
    _role = args?['role'] as String? ?? '';
    _avatarUrl = args?['avatarUrl'] as String? ?? '';
    _tags = (args?['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    if (_id.isNotEmpty) {
      _fetchProfile();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await _api.get('/profile/$_id');
      final data = res.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        final skills = (data['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final experiences = (data['experiences'] as List<dynamic>?)
                ?.map(
                    (e) => ProfileExperience.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        final portfolios = (data['portfolios'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .toList() ??
            [];
        final projectHistory = (data['project_history'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .toList() ??
            [];

        setState(() {
          _name = data['full_name'] as String? ?? _name;
          _role = data['interest'] as String? ?? _role;
          _avatarUrl = data['photo_url'] as String? ?? _avatarUrl;
          _coverUrl = data['cover_url'] as String? ?? _coverUrl;
          _bio = data['bio'] as String? ?? '';
          _tags = skills;
          _experiences = experiences;
          _portfolios = portfolios;
          _projectHistory = projectHistory;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: c.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileCover(
            avatarUrl: _avatarUrl,
            coverUrl: _coverUrl,
            onBack: () => Get.back(),
            onMore: () {},
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileIdentity(name: _name, role: _role),
                if (_bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      height: 1.32,
                      color: c.grey900,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _ProfileActions(
                  isFollowing: isFollowing,
                  onFollowToggle: () {
                    setState(() {
                      isFollowing = !isFollowing;
                    });
                  },
                  onChat: () {
                    Get.toNamed('/room-chat');
                  },
                ),
                const SizedBox(height: 16),
                _ProfileTabs(
                  activeIndex: selectedTabIndex,
                  onChanged: (index) {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 14),
                _ProfileTabContent(
                  activeIndex: selectedTabIndex,
                  name: _name,
                  role: _role,
                  avatarUrl: _avatarUrl,
                  tags: _tags,
                  experiences: _experiences,
                  portfolios: _portfolios,
                  projectHistory: _projectHistory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({
    this.avatarUrl,
    this.coverUrl = '',
    required this.onBack,
    required this.onMore,
  });

  final String? avatarUrl;
  final String coverUrl;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: topPadding + 158,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: coverUrl.isNotEmpty
                ? Image.network(coverUrl, fit: BoxFit.cover)
                : const AppCoverPlaceholder(),
          ),
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: _ProfileCircleButton(
              icon: FluentIcons.chevron_left_24_regular,
              onTap: onBack,
            ),
          ),
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: _ProfileCircleButton(
              icon: FluentIcons.more_horizontal_24_regular,
              onTap: onMore,
              tooltip: 'Lainnya',
            ),
          ),
          Positioned(
            left: 16,
            bottom: -46,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: AppAvatar(photoUrl: avatarUrl, radius: 47),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  const _ProfileCircleButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final btn = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, size: 23, color: c.grey900),
    );
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: tooltip != null
            ? Tooltip(message: tooltip!, child: btn)
            : btn,
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.satoshiStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.grey900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          role,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
      ],
    );
  }
}

class _SkillWrap extends StatelessWidget {
  const _SkillWrap({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 8,
      children: skills.map((skill) => _SkillChip(label: skill)).toList(),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.grey200),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.isFollowing,
    required this.onFollowToggle,
    required this.onChat,
  });

  final bool isFollowing;
  final VoidCallback onFollowToggle;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onFollowToggle,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? c.grey100 : AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isFollowing
                    ? Border.all(color: c.border)
                    : null,
              ),
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isFollowing
                      ? c.textSecondary
                      : c.surface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onChat,
          child: Container(
            width: 42,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: c.borderStrong),
            ),
            child: Icon(
              FluentIcons.chat_24_regular,
              color: c.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.activeIndex, required this.onChanged});

  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    const tabs = ['Postingan', 'Pengalaman', 'Keahlian', 'Kolaborasi'];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          tabs.length,
          (index) => _ProfileTab(
            label: tabs[index],
            active: activeIndex == index,
            onTap: () => onChanged(index),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxs,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? AppColors.primary500 : c.textTertiary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.primary500 : AppColors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({
    required this.activeIndex,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.experiences,
    required this.portfolios,
    required this.projectHistory,
  });

  final int activeIndex;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final List<ProfileExperience> experiences;
  final List<Map<String, dynamic>> portfolios;
  final List<Map<String, dynamic>> projectHistory;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    if (activeIndex == 1) {
      if (experiences.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          alignment: Alignment.center,
          child: Text(
            'Belum ada riwayat pengalaman',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: c.textTertiary,
            ),
          ),
        );
      }
      return _ExperienceList(experiences: experiences);
    }

    if (activeIndex == 2) {
      if (tags.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          alignment: Alignment.center,
          child: Text(
            'Belum ada keahlian',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: c.textTertiary,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _SkillWrap(skills: tags),
      );
    }

    if (activeIndex == 3) {
      if (projectHistory.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          alignment: Alignment.center,
          child: Text(
            'Belum ada riwayat kolaborasi',
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: c.textTertiary,
            ),
          ),
        );
      }
      return _ProjectHistoryList(projects: projectHistory);
    }

    if (portfolios.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        alignment: Alignment.center,
        child: Text(
          'Belum ada postingan',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            color: c.textTertiary,
          ),
        ),
      );
    }

      return Column(
        children: portfolios.map((p) {
          return _PostCard(
            avatarUrl: avatarUrl,
            name: name,
            subtitle: '$role - ${_formatPortfolioDate(p['created_at'])}',
            content: p['content'] as String? ?? '',
            likeCount: '${p['likes_count'] ?? 0}',
            commentCount: '${p['comments_count'] ?? 0}',
          );
        }).toList(),
      );
  }
}

class _ExperienceList extends StatelessWidget {
  const _ExperienceList({required this.experiences});

  final List<ProfileExperience> experiences;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: experiences.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exp = experiences[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp.title,
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              if (exp.organization.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  exp.organization,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
              if (exp.duration.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  exp.duration,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    color: c.textTertiary,
                  ),
                ),
              ],
              if (exp.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exp.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    color: c.grey700,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProjectHistoryList extends StatelessWidget {
  const _ProjectHistoryList({required this.projects});

  final List<Map<String, dynamic>> projects;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = projects[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['title'] as String? ?? '',
                style: AppFonts.satoshiStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              if (project['role'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Role: ${project['role']}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
              if (project['status'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Status: ${project['status']}',
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    color: c.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.content,
    required this.likeCount,
    required this.commentCount,
  });

  final String? avatarUrl;
  final String name;
  final String subtitle;
  final String content;
  final String likeCount;
  final String commentCount;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = int.tryParse(widget.likeCount) ?? 0;
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
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppAvatar(photoUrl: widget.avatarUrl, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            widget.name,
                            style: AppFonts.satoshiStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: c.grey900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 11.5,
                              color: c.grey400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    FluentIcons.more_vertical_24_regular,
                    color: c.grey400,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.content,
                style: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: c.grey900,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInteractionItem(
                    _isLiked
                        ? FluentIcons.heart_24_filled
                        : FluentIcons.heart_24_regular,
                    '$_likeCount',
                    _isLiked ? AppColors.error500 : c.grey500,
                    onTap: _toggleLike,
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    widget.commentCount,
                    c.grey500,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    c.grey500,
                    onTap: () {},
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    _isBookmarked
                        ? FluentIcons.bookmark_24_filled
                        : FluentIcons.bookmark_24_regular,
                    '',
                    _isBookmarked ? AppColors.warning500 : c.grey500,
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionItem(
    IconData icon,
    String count,
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
            Icon(icon, color: activeColor, size: 20),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 6),
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

String _formatPortfolioDate(dynamic date) {
  if (date == null) return '';
  try {
    final dt = DateTime.parse(date.toString());
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inDays < 1) return '${diff.inHours}j lalu';
    if (diff.inDays < 30) return '${diff.inDays}h lalu';
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return '';
  }
}
