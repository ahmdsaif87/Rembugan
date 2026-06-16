import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  static void success(String message, {String? title}) =>
      _show(AppToastType.success, message, title: title);

  static void error(String message, {String? title}) =>
      _show(AppToastType.error, message, title: title);

  static void warning(String message, {String? title}) =>
      _show(AppToastType.warning, message, title: title);

  static void info(String message, {String? title}) =>
      _show(AppToastType.info, message, title: title);

  static void _show(AppToastType type, String message, {String? title}) {
    final (Color bg, Color fg, IconData icon) = switch (type) {
      AppToastType.success => (
        AppColors.success50,
        AppColors.success700,
        FluentIcons.checkmark_circle_24_filled,
      ),
      AppToastType.error => (
        AppColors.danger50,
        AppColors.danger700,
        FluentIcons.error_circle_24_filled,
      ),
      AppToastType.warning => (
        AppColors.warning50,
        AppColors.warning700,
        FluentIcons.warning_24_filled,
      ),
      AppToastType.info => (
        AppColors.info50,
        AppColors.info700,
        FluentIcons.info_24_filled,
      ),
    };

    Get.rawSnackbar(
      messageText: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  Text(
                    message,
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: fg,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.sm,
      duration: Duration(seconds: type == AppToastType.error ? 4 : 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
