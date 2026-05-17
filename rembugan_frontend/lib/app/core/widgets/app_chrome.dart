import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/session_service.dart';
import '../../routes/app_pages.dart';
import '../theme/theme.dart';

enum AppNavDestination { home, explore, team, profile, none }

class AppLayeredBackground extends StatelessWidget {
  const AppLayeredBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: child,
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.shadow,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadow ?? const [],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    this.badge = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? AppColors.textPrimary : AppColors.surface;
    final foreground = isPrimary ? Colors.white : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isPrimary ? AppColors.textPrimary : AppColors.border,
            ),
            boxShadow: isPrimary ? AppShadows.soft : const [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: foreground, size: 22),
              if (badge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.generalSansStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: AppFonts.generalSansStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText!,
              style: AppFonts.generalSansStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppSurface(
          shadow: const [],
          borderColor: AppColors.border,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.14),
                      AppColors.warning.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentBlue.withValues(alpha: 0.82),
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.generalSansStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.generalSansStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.current, super.key});

  final AppNavDestination current;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, bottomPadding + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: current == AppNavDestination.home
                ? FluentIcons.home_24_filled
                : FluentIcons.home_24_regular,
            label: 'Beranda',
            active: current == AppNavDestination.home,
            onTap: () => _go(Routes.HOME),
          ),
          _NavItem(
            icon: current == AppNavDestination.explore
                ? FluentIcons.globe_24_filled
                : FluentIcons.globe_24_regular,
            label: 'Jelajah',
            active: current == AppNavDestination.explore,
            onTap: () => _go(Routes.EXPLORE),
          ),
          _CreateButton(),
          _NavItem(
            icon: current == AppNavDestination.team
                ? FluentIcons.apps_24_filled
                : FluentIcons.apps_24_regular,
            label: 'Proyek',
            active: current == AppNavDestination.team,
            onTap: () => _go(Routes.TEAM),
          ),
          _NavItem(
            icon: current == AppNavDestination.profile
                ? FluentIcons.person_24_filled
                : FluentIcons.person_24_regular,
            label: 'Profil',
            active: current == AppNavDestination.profile,
            onTap: () => _go(Routes.PROFILE),
          ),
        ],
      ),
    );
  }

  void _go(String route) {
    if (Get.currentRoute == route) return;
    if (route == Routes.CHAT && GuestGuard.isGuest) {
      GuestGuard.showLoginPrompt(feature: 'membuka chat');
      return;
    }
    if (route == Routes.PROFILE && GuestGuard.isGuest) {
      Get.toNamed(Routes.GUEST_LANDING);
      return;
    }
    if (route == Routes.HOME) {
      Get.offAllNamed(route);
    } else {
      Get.toNamed(route);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 54,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: active ? AppColors.border : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.generalSansStyle(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: color,
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

class _CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (GuestGuard.isGuest) {
              GuestGuard.showLoginPrompt(feature: 'membuat postingan');
              return;
            }
            Get.toNamed(Routes.CREATE_POST);
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppShadows.soft,
            ),
            child: const Icon(
              FluentIcons.add_24_filled,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class GuestGuard {
  static bool get isGuest => Get.find<SessionService>().isGuest.value;

  static bool blockIfGuest(String feature) {
    if (!isGuest) return false;
    showLoginPrompt(feature: feature);
    return true;
  }

  static void showLoginPrompt({required String feature}) {
    Get.dialog<void>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  FluentIcons.lock_closed_24_regular,
                  color: AppColors.textPrimary,
                  size: 21,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Masuk untuk $feature',
                style: AppFonts.headingStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mode tamu bisa membaca konten publik. Untuk berinteraksi, chat, menyimpan, atau membuat konten, masuk dengan akun Rembugan.',
                style: AppFonts.interStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      child: const Text('Nanti'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back<void>();
                        Get.offAllNamed(Routes.LOGIN);
                      },
                      child: const Text('Masuk'),
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

class GuestModeBadge extends StatelessWidget {
  const GuestModeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!Get.find<SessionService>().isGuest.value) {
        return const SizedBox.shrink();
      }

      return InkWell(
        onTap: () => Get.toNamed(Routes.GUEST_LANDING),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FluentIcons.eye_24_regular,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                'Guest',
                style: AppFonts.interStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
