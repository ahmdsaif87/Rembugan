import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../routes/app_pages.dart';
import '../../home/views/widgets/post_card_widget.dart';
import '../../home/views/widgets/share_sheet.dart';
import 'comment_view.dart';

class OtherProfileView extends StatefulWidget {
  const OtherProfileView({super.key});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  int selectedTabIndex = 0;
  bool _isLoading = true;
  String? _connectionStatus;
  int? _connectionId;
  bool _isIncoming = false;
  int _connectionCount = 0;
  int _projectCount = 0;
  final Set<String> _likedShowcaseIds = {};

  final _api = Get.find<ApiClient>();

  String _id = '';
  String _name = '';
  String _role = '';
  String _avatarUrl = '';
  String _coverUrl = '';
  String _bio = '';
  String _interest = '';
  Map<String, String> _socialLinks = {};
  List<String> _tags = [];
  List<ProfileExperience> _experiences = [];
  List<Map<String, dynamic>> _portfolios = [];
  List<Map<String, dynamic>> _projectHistory = [];

  @override
  void initState() {
    super.initState();
    _id = Get.parameters['userId'] ?? '';
    final args = Get.arguments as Map<String, dynamic>?;
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
      final resData = res.data;
      final data = resData is Map ? resData['data'] as Map<String, dynamic>? : null;
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

        final rawSocialLinks = data['social_links'];
        Map<String, String> parsedLinks = {};
        if (rawSocialLinks is Map) {
          parsedLinks = rawSocialLinks.map((k, v) => MapEntry(k.toString(), v.toString()));
        }

        setState(() {
          _name = data['full_name'] as String? ?? _name;
          _role = data['major'] as String? ?? _role;
          _avatarUrl = data['photo_url'] as String? ?? _avatarUrl;
          _coverUrl = data['cover_url'] as String? ?? _coverUrl;
          _bio = data['bio'] as String? ?? '';
          _interest = data['interest'] as String? ?? '';
          _socialLinks = parsedLinks;
          _tags = skills;
          _experiences = experiences;
          _portfolios = portfolios;
          _projectHistory = projectHistory;
          _connectionStatus = data['connection_status'] as String?;
          _connectionId = data['connection_id'] as int?;
          _isIncoming = data['is_incoming'] as bool? ?? false;
          _connectionCount = data['connection_count'] as int? ?? 0;
          _projectCount = data['project_count'] as int? ?? 0;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _sendConnection() async {
    try {
      await _api.post('/connections/send/$_id');
      setState(() {
        _connectionStatus = 'pending';
      });
    } catch (_) {
      AppToast.error('Gagal mengirim permintaan koneksi');
    }
  }

  Future<void> _acceptConnection() async {
    if (_connectionId == null) return;
    try {
      await _api.put('/connections/accept/$_connectionId');
      setState(() {
        _connectionStatus = 'accepted';
      });
      AppToast.success('Koneksi diterima');
    } catch (_) {
      AppToast.error('Gagal menerima koneksi');
    }
  }

  Future<void> _rejectConnection() async {
    if (_connectionId == null) return;
    try {
      await _api.put('/connections/reject/$_connectionId');
      setState(() {
        _connectionStatus = 'rejected';
        _connectionId = null;
        _isIncoming = false;
      });
      AppToast.success('Koneksi ditolak');
    } catch (_) {
      AppToast.error('Gagal menolak koneksi');
    }
  }

  Future<void> _removeConnection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus koneksi?'),
        content: const Text('Apakah kamu yakin ingin menghapus koneksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.put('/connections/remove/$_id');
      setState(() {
        _connectionStatus = null;
        _connectionId = null;
      });
      AppToast.success('Koneksi berhasil dihapus');
    } catch (_) {
      AppToast.error('Gagal menghapus koneksi');
    }
  }

  void _navigateToChat() {
    final currentUid = Get.find<AuthService>().currentUser.value?.id;
    if (currentUid == null || _id.isEmpty) return;
    final sorted = [currentUid, _id]..sort();
    final roomId = 'dm_${sorted[0]}_${sorted[1]}';
    Get.toNamed(Routes.ROOM_CHAT, arguments: ChatRoom(
      roomId: roomId,
      type: 'dm',
      name: _name,
      otherUserId: _id,
      photoUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
    ));
  }

  void _onToggleLike(String showcaseId) {
    setState(() {
      if (_likedShowcaseIds.contains(showcaseId)) {
        _likedShowcaseIds.remove(showcaseId);
      } else {
        _likedShowcaseIds.add(showcaseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: c.background,
        body: const SkeletonProfile(),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileIdentity(
                  userId: _id,
                  name: _name,
                  major: _role,
                  interest: _interest,
                  bio: _bio,
                  socialLinks: _socialLinks,
                  connectionCount: _connectionCount,
                  projectCount: _projectCount,
                  projectHistory: _projectHistory,
                ),
                const SizedBox(height: 14),
                  _ProfileActions(
                    connectionStatus: _connectionStatus,
                    isIncoming: _isIncoming,
                    onConnect: _sendConnection,
                    onAccept: _acceptConnection,
                    onReject: _rejectConnection,
                    onRemove: _removeConnection,
                    onChat: _navigateToChat,
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
                  likedShowcaseIds: _likedShowcaseIds,
                  onToggleLike: _onToggleLike,
                  userId: _id,
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
  });

  final String? avatarUrl;
  final String coverUrl;
  final VoidCallback onBack;

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
    required this.userId,
    required this.name,
    required this.major,
    required this.interest,
    required this.bio,
    required this.socialLinks,
    required this.connectionCount,
    required this.projectCount,
    required this.projectHistory,
  });

  final String userId;
  final String name;
  final String major;
  final String interest;
  final String bio;
  final Map<String, String> socialLinks;
  final int connectionCount;
  final int projectCount;
  final List<Map<String, dynamic>> projectHistory;

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
          major,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.grey500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.CONNECTIONS_LIST, arguments: {
                'userId': userId,
                'userName': name,
              }),
              child: Row(
                children: [
                  Icon(FluentIcons.people_24_regular, size: 14, color: c.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '$connectionCount koneksi',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.PROJECT_HISTORY, arguments: {
                'userName': name,
                'projects': projectHistory,
              }),
              child: Row(
                children: [
                  Icon(FluentIcons.briefcase_24_regular, size: 14, color: c.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '$projectCount proyek',
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (interest.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            interest,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
        ],
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            bio,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              height: 1.32,
              color: c.grey900,
            ),
          ),
        ],
        if (socialLinks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (socialLinks.containsKey('instagram'))
                _SocialLinkButton(
                  icon: FluentIcons.camera_24_regular,
                  label: 'Instagram',
                  url: 'https://instagram.com/${socialLinks['instagram']}',
                ),
              if (socialLinks.containsKey('linkedin'))
                _SocialLinkButton(
                  icon: FluentIcons.briefcase_24_regular,
                  label: 'LinkedIn',
                  url: 'https://linkedin.com/in/${socialLinks['linkedin']}',
                ),
              if (socialLinks.containsKey('website'))
                _SocialLinkButton(
                  icon: FluentIcons.globe_24_regular,
                  label: 'Website',
                  url: socialLinks['website']!,
                ),
            ],
          ),
        ],
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
    required this.connectionStatus,
    required this.isIncoming,
    required this.onConnect,
    required this.onAccept,
    required this.onReject,
    required this.onRemove,
    required this.onChat,
  });

  final String? connectionStatus;
  final bool isIncoming;
  final VoidCallback onConnect;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onRemove;
  final VoidCallback onChat;

  bool get _isConnected => connectionStatus == 'accepted';
  bool get _isPending => connectionStatus == 'pending';

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    if (_isConnected) {
      return SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.grey100,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FluentIcons.person_24_regular, size: 16, color: c.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Terhubung',
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _ChatButton(onTap: onChat),
          ],
        ),
      );
    }

    if (_isPending && isIncoming) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onReject,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.border),
                ),
                child: Text(
                  'Tolak',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onAccept,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Terima',
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: c.surface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ChatButton(onTap: onChat),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isPending ? null : onConnect,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isPending ? c.grey100 : AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: _isPending ? Border.all(color: c.border) : null,
              ),
              child: Text(
                _isPending ? 'Tertunda' : 'Hubungkan',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _isPending ? c.textSecondary : c.surface,
                ),
              ),
            ),
          ),
        ),
        if (!_isPending) ...[
          const SizedBox(width: 10),
          _ChatButton(onTap: onChat),
        ],
      ],
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.border),
        ),
        child: Icon(FluentIcons.chat_24_regular, color: AppColors.primary, size: 20),
      ),
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
    required this.likedShowcaseIds,
    required this.onToggleLike,
    required this.userId,
  });

  final int activeIndex;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final List<ProfileExperience> experiences;
  final List<Map<String, dynamic>> portfolios;
  final List<Map<String, dynamic>> projectHistory;
  final Set<String> likedShowcaseIds;
  final void Function(String showcaseId) onToggleLike;
  final String userId;

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
        final showcaseId = p['id']?.toString() ?? '';
        final isLiked = likedShowcaseIds.contains(showcaseId);
        return PostCardWidget(
          showcaseId: showcaseId,
          authorId: userId,
          avatarUrl: avatarUrl,
          name: name,
          subtitle: '$role - ${formatDate(p['created_at'] as String?)}',
          content: p['content'] as String? ?? '',
          mediaUrls: (p['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
          initialLikes: p['likes_count'] as int? ?? 0,
          initialComments: p['comments_count'] as int? ?? 0,
          isLiked: isLiked,
          showFollowButton: false,
          onShowComments: () => showCommentsSheet(context, showcaseId),
          onShowShare: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
              builder: (_) => ShareSheet(postId: showcaseId, postType: 'post'),
            );
          },
          onToggleLike: () => onToggleLike(showcaseId),
          onTapProfile: () {},
        );
      }).toList(),
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: c.primarySoft,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () async {
          try {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } catch (_) {
            AppToast.error('Tidak bisa membuka tautan');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary500),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
        ),
      ),
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
