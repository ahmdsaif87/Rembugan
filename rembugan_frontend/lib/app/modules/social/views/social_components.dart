import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_chrome.dart';

class SocialScaffold extends StatelessWidget {
  const SocialScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      bottomNavigationBar: bottomNavigationBar,
      body: AppLayeredBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Kembali',
                      child: IconButton(
                        onPressed: Get.back,
                        icon: const Icon(FluentIcons.chevron_left_24_regular),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.headingStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.satoshiStyle(
                                fontSize: 12,
                                color: c.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: c.border.withValues(alpha: 0.4),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialPostCard extends StatelessWidget {
  const SocialPostCard({
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.body,
    this.onTap,
    super.key,
  });

  final String name;
  final String handle;
  final String avatarUrl;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.lg,
      shadow: const [],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(photoUrl: avatarUrl, radius: 22),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      handle,
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    _Metric(icon: FluentIcons.heart_24_regular, label: '120'),
                    SizedBox(width: 18),
                    _Metric(icon: FluentIcons.chat_24_regular, label: '18'),
                    SizedBox(width: 18),
                    _Metric(
                      icon: FluentIcons.bookmark_24_regular,
                      label: 'Save',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c.textTertiary),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}

class AppTextPill extends StatelessWidget {
  const AppTextPill({
    required this.label,
    this.active = false,
    this.icon,
    this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: active ? c.borderStrong : c.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: active ? AppColors.primary : c.textSecondary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : c.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: child,
        ),
      );
    }

    return child;
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({this.width, this.height = 12, super.key});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}
