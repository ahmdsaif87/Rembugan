import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum AppBannerType { info, success, warning, error }

class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final AppBannerType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (type) {
      AppBannerType.success => (
        AppColors.success50,
        AppColors.success700,
        FluentIcons.checkmark_circle_24_filled,
      ),
      AppBannerType.error => (
        AppColors.danger50,
        AppColors.danger700,
        FluentIcons.error_circle_24_filled,
      ),
      AppBannerType.warning => (
        AppColors.warning50,
        AppColors.warning700,
        FluentIcons.warning_24_filled,
      ),
      AppBannerType.info => (
        AppColors.info50,
        AppColors.info700,
        FluentIcons.info_24_filled,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: fg.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: fg,
                height: 1.4,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppFonts.satoshiStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                FluentIcons.dismiss_24_regular,
                size: 16,
                color: fg.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
