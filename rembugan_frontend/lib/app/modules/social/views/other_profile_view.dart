import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';

class OtherProfileView extends StatefulWidget {
  const OtherProfileView({super.key});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  int selectedTabIndex = 0;
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _ProfileTopBar(
                onBack: () => Get.back(),
              ),
              const SizedBox(height: 24),
              const _ProfileStatsHeader(),
              const SizedBox(height: 20),
              const _ProfileIdentity(),
              const SizedBox(height: 14),
              const _SkillWrap(),
              const SizedBox(height: 22),
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
              const SizedBox(height: 26),
              _ProfileTabs(
                activeIndex: selectedTabIndex,
                onChanged: (index) {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
              ),
              const SizedBox(height: 14),
              _ProfileTabContent(activeIndex: selectedTabIndex),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderStrong,
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(
                FluentIcons.arrow_left_24_regular,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Text(
        //   'Profil',
        //   style: AppFonts.headingStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.w700,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            FluentIcons.more_horizontal_24_regular,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatsHeader extends StatelessWidget {
  const _ProfileStatsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('lib/assets/img/avatar.png'),
        ),
        SizedBox(width: 24),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileMetric(value: '48', label: 'Postingan'),
              _ProfileMetric(value: '1.2K', label: 'Pengikut'),
              _ProfileMetric(value: '9', label: 'Kolaborasi'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                'Raka Pratama',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'D4 Teknik Informatika',
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '@raka.design',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'UI/UX Designer dan product thinker. Mendesain produk kolaborasi kampus dengan fokus pada clarity, flow, dan UX research.',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            height: 1.62,
            color: AppColors.textPrimary.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}

class _SkillWrap extends StatelessWidget {
  const _SkillWrap();

  @override
  Widget build(BuildContext context) {
    final skills = ['Figma', 'Research', 'Design System'];
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onFollowToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? const Color(0xFFF3F4F6) : Colors.black,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                  side: isFollowing
                      ? const BorderSide(color: AppColors.border)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                isFollowing ? 'Mengikuti' : 'Ikuti',
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFollowing ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        InkWell(
          onTap: onChat,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: const Icon(
              FluentIcons.chat_24_regular,
              color: AppColors.textPrimary,
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
    const tabs = ['Postingan', 'Pengalaman', 'Kolaborasi'];

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.textPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    if (activeIndex == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          'Belum ada riwayat pengalaman',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    if (activeIndex == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          'Belum ada riwayat kolaborasi',
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return const Column(
      children: [
        _PostCard(
          avatarAsset: 'lib/assets/img/avatar.png',
          name: 'Raka Pratama',
          subtitle: 'D4 Teknik Informatika - 1 jam lalu',
          content:
              'Sedang eksplorasi pattern untuk onboarding komunitas kampus. Yang paling penting: user cepat paham value tanpa kebanyakan teks.',
          likeCount: '142',
          commentCount: '24',
        ),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppFonts.satoshiStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.avatarAsset,
    required this.name,
    required this.subtitle,
    required this.content,
    this.hasImage = false,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
  });

  final String avatarAsset;
  final String name;
  final String subtitle;
  final String content;
  final bool hasImage;
  final String? imageUrl;
  final String likeCount;
  final String commentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: AssetImage(avatarAsset),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppFonts.satoshiStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.satoshiStyle(
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    FluentIcons.more_vertical_24_regular,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary.withValues(alpha: 0.88),
                  height: 1.5,
                ),
              ),
              if (hasImage && imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInteractionItem(
                    FluentIcons.heart_24_regular,
                    likeCount,
                    const Color(0xFFE5484D),
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    commentCount,
                    AppColors.textSecondary,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    AppColors.textSecondary,
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    FluentIcons.bookmark_24_regular,
                    '',
                    const Color(0xFFD69E2E),
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
    Color activeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: activeColor.withValues(alpha: 0.88), size: 20),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 6),
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
    );
  }
}
