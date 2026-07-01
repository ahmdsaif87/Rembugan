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
    final (Color bg, Color fg, Color iconBg, IconData icon) = switch (type) {
      AppToastType.success => (
        AppColors.success50,
        AppColors.success700,
        AppColors.success100,
        FluentIcons.checkmark_24_filled,
      ),
      AppToastType.error => (
        AppColors.danger50,
        AppColors.danger700,
        AppColors.danger100,
        FluentIcons.dismiss_circle_24_filled,
      ),
      AppToastType.warning => (
        AppColors.warning50,
        AppColors.warning700,
        AppColors.warning100,
        FluentIcons.warning_24_filled,
      ),
      AppToastType.info => (
        AppColors.info50,
        AppColors.info700,
        AppColors.info100,
        FluentIcons.info_24_filled,
      ),
    };

    Get.rawSnackbar(
      messageText: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        title,
                        style: AppFonts.satoshiStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          height: 1.2,
                        ),
                      ),
                    ),
                  Text(
                    message,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fg,
                      height: 1.3,
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
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      borderRadius: 14,
      duration: Duration(seconds: type == AppToastType.error ? 4 : 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      barBlur: 0,
      overlayBlur: 0,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}
