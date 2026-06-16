import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme.dart';

/// Confirmation and action dialogs.
class AppDialog {
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool isDanger = false,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Get.context != null
            ? AppC.of(Get.context!).surfaceElevated
            : AppColors.surfaceElevated,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          title,
          style: AppFonts.satoshiStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Get.context != null
                ? AppC.of(Get.context!).textPrimary
                : AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: Get.context != null
                ? AppC.of(Get.context!).textSecondary
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelLabel,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Get.context != null
                    ? AppC.of(Get.context!).textSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmLabel,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDanger ? AppColors.danger600 : AppColors.primary500,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<T?> showCustom<T>({
    required String title,
    required Widget content,
    String? confirmLabel,
    VoidCallback? onConfirm,
  }) {
    return Get.dialog<T>(
      AlertDialog(
        backgroundColor: Get.context != null
            ? AppC.of(Get.context!).surfaceElevated
            : AppColors.surfaceElevated,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          title,
          style: AppFonts.satoshiStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Get.context != null
                ? AppC.of(Get.context!).textPrimary
                : AppColors.textPrimary,
          ),
        ),
        content: content,
        actions: confirmLabel != null
            ? [
                TextButton(
                  onPressed: onConfirm ?? () => Get.back(),
                  child: Text(
                    confirmLabel,
                    style: AppFonts.satoshiStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Bottom sheet with consistent styling.
class AppSheet {
  static Future<T?> show<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: Get.overlayContext!,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.transparent,
      builder: (_) => _SheetWrapper(
        useSafeArea: useSafeArea,
        child: child,
      ),
    );
  }

  static Widget handle(AppC c) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: c.grey300,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }

  static Widget header({
    required AppC c,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.headingStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppFonts.satoshiStyle(
              fontSize: 12,
              height: 1.4,
              color: c.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetWrapper extends StatelessWidget {
  const _SheetWrapper({required this.child, this.useSafeArea = true});

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final padded = Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheet.handle(c),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );

    final sheet = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: useSafeArea
          ? SafeArea(top: false, child: padded)
          : padded,
    );

    return sheet;
  }
}
