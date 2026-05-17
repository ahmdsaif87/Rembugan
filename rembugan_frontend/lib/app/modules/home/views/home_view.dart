import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../routes/app_pages.dart';
import '../../social/views/comment_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                  children: [
                    _buildPostCard(
                      context: context,
                      avatarUrl: 'https://i.pravatar.cc/100?img=33',
                      name: 'Cameron Williamson',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                      hasImage: true,
                      imageUrl: 'https://picsum.photos/id/20/400/250',
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _buildPostCard(
                      context: context,
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Marvin McKinney',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                      hasImage: false,
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _buildPostCard(
                      context: context,
                      avatarUrl: 'https://i.pravatar.cc/100?img=12',
                      name: 'Marvin McKinney',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                      hasImage: false,
                    ),
                    const Divider(height: 1, color: Color(0xFFE1E4E8)),
                    _buildPostCard(
                      context: context,
                      avatarUrl: 'https://i.pravatar.cc/100?img=33',
                      name: 'Cameron Williamson',
                      subtitle: 'D4 Teknik Informatika - 2 jam yang lalu',
                      content:
                          'lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet lorem ipsum dolor sir amet',
                      hasImage: true,
                      imageUrl: 'https://picsum.photos/id/20/400/250',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppNavDestination.home),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beranda',
                  style: AppFonts.headingStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan diskusi dan peluang kolaborasi.',
                  style: AppFonts.generalSansStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const GuestModeBadge(),
          const SizedBox(width: 8),
          AppIconButton(
            icon: FluentIcons.alert_24_regular,
            badge: true,
            onTap: () {
              if (GuestGuard.blockIfGuest('melihat notifikasi')) return;
              Get.toNamed(Routes.NOTIFICATIONS);
            },
          ),
          const SizedBox(width: 10),
          AppIconButton(
            icon: FluentIcons.chat_empty_24_regular,
            onTap: () {
              if (GuestGuard.blockIfGuest('membuka chat')) return;
              Get.toNamed(Routes.CHAT);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE1E4E8))),
        ),
        child: Row(
          children: [
            _buildTabButton('Untukmu', true),
            _buildTabButton('Mengikuti', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.generalSansStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required String avatarUrl,
    required String name,
    required String subtitle,
    required String content,
    required bool hasImage,
    String? imageUrl,
  }) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: () => showCommentsSheet(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: const AssetImage('lib/assets/img/avatar.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppFonts.generalSansStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.generalSansStyle(
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (GuestGuard.blockIfGuest('mengikuti profil')) return;
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 31),
                      side: const BorderSide(color: Color(0xFFDADDE2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    child: Text(
                      'Ikuti',
                      style: AppFonts.generalSansStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
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
                style: AppFonts.generalSansStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary.withValues(alpha: 0.88),
                  height: 1.56,
                ),
              ),
              if (hasImage && imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInteractionItem(
                    FluentIcons.heart_24_regular,
                    '120',
                    'menyukai postingan',
                    const Color(0xFFE5484D),
                  ),
                  const SizedBox(width: 22),
                  _buildInteractionItem(
                    FluentIcons.chat_24_regular,
                    '20',
                    'berkomentar',
                    AppColors.textSecondary,
                  ),
                  const Spacer(),
                  _buildInteractionItem(
                    FluentIcons.send_24_regular,
                    '',
                    'membagikan postingan',
                    AppColors.textSecondary,
                  ),
                  const SizedBox(width: 20),
                  _buildInteractionItem(
                    FluentIcons.bookmark_24_regular,
                    '',
                    'menyimpan postingan',
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
    String feature,
    Color activeColor,
  ) {
    return InkWell(
      onTap: () {
        if (feature == 'berkomentar') {
          showCommentsSheet(Get.context!);
          return;
        }
        if (GuestGuard.blockIfGuest(feature)) return;
      },
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: activeColor.withValues(alpha: 0.88), size: 22),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                count,
                style: AppFonts.generalSansStyle(
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
