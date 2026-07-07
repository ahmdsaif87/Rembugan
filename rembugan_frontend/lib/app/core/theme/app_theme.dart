import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary500,
      onPrimary: AppTextColors.textPrimaryWhite,
      primaryContainer: AppSurfaceColors.surfaceAccent,
      onPrimaryContainer: AppColors.primary700,
      secondary: AppSurfaceColors.surfaceAccent,
      onSecondary: AppColors.primary500,
      surface: AppSurfaceColors.surfaceWhite,
      onSurface: AppTextColors.textPrimaryBlack,
      error: AppColors.error,
      onError: AppTextColors.textPrimaryWhite,
      outline: AppColors.grey200,
      outlineVariant: AppColors.grey300,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.inter,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppSurfaceColors.surfaceWhite,
      textTheme: AppTextStyles.lightTextTheme,
      splashColor: AppColors.primary500.withValues(alpha: 0.08),
      highlightColor: AppColors.primary500.withValues(alpha: 0.04),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppSurfaceColors.surfaceWhite,
        foregroundColor: AppTextColors.textPrimaryBlack,
        surfaceTintColor: AppSurfaceColors.surfaceWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium(),
        iconTheme: const IconThemeData(color: AppIconColors.iconBlack),
      ),
      cardTheme: CardThemeData(
        color: AppSurfaceColors.surfaceWhite,
        surfaceTintColor: AppSurfaceColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.grey200),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _primaryButtonStyle(),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _primaryButtonStyle()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTextColors.textLinks,
          textStyle: AppTextStyles.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.grey200),
          ),
          foregroundColor: const WidgetStatePropertyAll(
            AppTextColors.textPrimaryBlack,
          ),
          backgroundColor: const WidgetStatePropertyAll(
            AppSurfaceColors.surfaceWhite,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.primary50;
          }
          return AppColors.grey50;
        }),
        hintStyle: AppTextStyles.bodyMedium(color: AppTextColors.textGrey),
        labelStyle: AppTextStyles.bodyMedium(
          color: AppTextColors.textPrimaryBlack,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: _inputBorder(AppColors.grey200),
        enabledBorder: _inputBorder(AppColors.grey200),
        focusedBorder: _inputBorder(AppColors.primary500, width: 1.2),
        errorBorder: _inputBorder(AppColors.error, width: 1.2),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.2),
        disabledBorder: _inputBorder(AppColors.grey300),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppSurfaceColors.surfaceWhite,
        selectedItemColor: AppIconColors.iconAccent,
        unselectedItemColor: AppIconColors.iconGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: AppIconColors.iconBlack),
      dividerColor: AppColors.grey200,
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primary500,
      onPrimary: AppColors.white,
      primaryContainer: DarkColors.primary50,
      onPrimaryContainer: AppColors.primary200,
      secondary: DarkColors.primary50,
      onSecondary: AppColors.primary300,
      surface: DarkColors.surface,
      onSurface: DarkColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.white,
      outline: DarkColors.border,
      outlineVariant: DarkColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.inter,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DarkColors.background,
      textTheme: AppTextStyles.darkTextTheme,
      splashColor: AppColors.primary500.withValues(alpha: 0.12),
      highlightColor: AppColors.primary500.withValues(alpha: 0.06),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DarkColors.surface,
        foregroundColor: DarkColors.textPrimary,
        surfaceTintColor: DarkColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium(
          color: DarkColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: DarkColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: DarkColors.card,
        surfaceTintColor: DarkColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: DarkColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _primaryButtonStyle(),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _primaryButtonStyle()),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary300,
          textStyle: AppTextStyles.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: DarkColors.border),
          ),
          foregroundColor: const WidgetStatePropertyAll(
            DarkColors.textPrimary,
          ),
          backgroundColor: const WidgetStatePropertyAll(
            DarkColors.surfaceElevated,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return DarkColors.inputFocused;
          }
          return DarkColors.input;
        }),
        hintStyle: AppTextStyles.bodyMedium(color: DarkColors.textTertiary),
        labelStyle: AppTextStyles.bodyMedium(color: DarkColors.textPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: _inputBorder(DarkColors.border),
        enabledBorder: _inputBorder(DarkColors.border),
        focusedBorder: _inputBorder(AppColors.primary400, width: 1.2),
        errorBorder: _inputBorder(AppColors.error, width: 1.2),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.2),
        disabledBorder: _inputBorder(DarkColors.borderStrong),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: AppColors.primary400,
        unselectedItemColor: DarkColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: DarkColors.textSecondary),
      dividerColor: DarkColors.border,
      dividerTheme: const DividerThemeData(
        color: DarkColors.border,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DarkColors.surfaceElevated,
        surfaceTintColor: DarkColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DarkColors.surface,
        surfaceTintColor: DarkColors.surface,
        modalBarrierColor: Color(0x80000000),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: DarkColors.surfaceElevated,
        surfaceTintColor: DarkColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: DarkColors.border),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return DarkColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary500;
          }
          return DarkColors.surfaceSecondary;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary500;
          }
          return DarkColors.borderStrong;
        }),
      ),
    );
  }

  static ButtonStyle _primaryButtonStyle() {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey300;
        }
        if (states.contains(WidgetState.pressed)) {
          return AppColors.primary600;
        }
        return AppColors.primary500;
      }),
      foregroundColor: const WidgetStatePropertyAll(
        AppTextColors.textPrimaryWhite,
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.primary700.withValues(alpha: 0.2);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.white.withValues(alpha: 0.08);
        }
        return AppColors.transparent;
      }),
      textStyle: WidgetStatePropertyAll(AppTextStyles.button(fontSize: 16)),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
