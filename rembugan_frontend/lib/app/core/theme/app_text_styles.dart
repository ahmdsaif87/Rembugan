import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const String inter = 'Inter';
  static const String satoshi = inter;

  static TextStyle displayLarge({Color? color}) {
    return _style(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: 1.12,
    );
  }

  static TextStyle titleLarge({Color? color}) {
    return _style(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: 1.2,
    );
  }

  static TextStyle titleMedium({Color? color}) {
    return _style(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: 1.25,
    );
  }

  static TextStyle bodyLarge({
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return _style(
      fontSize: 16,
      fontWeight: fontWeight,
      color: color ?? AppTextColors.textSecondaryDarkGrey,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return _style(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? AppTextColors.textSecondaryDarkGrey,
      height: 1.45,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return _style(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppTextColors.textSecondaryDarkGrey,
      height: 1.4,
    );
  }

  static TextStyle button({double fontSize = 14, Color? color}) {
    return _style(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: 1.3,
    );
  }

  static TextStyle heading({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return _style(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: height,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return _style(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTextColors.textSecondaryDarkGrey,
      height: height,
    );
  }

  static TextStyle label({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return _style(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTextColors.textPrimaryBlack,
      height: height,
    );
  }

  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: displayLarge(),
    headlineLarge: titleLarge(),
    headlineMedium: titleMedium(),
    titleLarge: titleMedium(),
    titleMedium: heading(fontSize: 16, fontWeight: FontWeight.w700),
    titleSmall: label(fontSize: 14),
    bodyLarge: bodyLarge(),
    bodyMedium: bodyMedium(),
    bodySmall: bodySmall(),
    labelLarge: button(),
    labelMedium: button(fontSize: 12),
    labelSmall: button(fontSize: 11),
  );

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: inter,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: 0,
    );
  }
}

class AppTextStyle {
  static const String satoshi = AppTextStyles.satoshi;
  static const String inter = AppTextStyles.inter;

  static TextStyle heading({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return AppTextStyles.heading(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return AppTextStyles.body(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle label({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
  }) {
    return AppTextStyles.label(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextTheme get lightTextTheme => AppTextStyles.lightTextTheme;
}

class AppFonts {
  static const String satoshi = AppTextStyles.satoshi;
  static const String inter = AppTextStyles.inter;

  static TextStyle headingStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return AppTextStyles.heading(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    ).copyWith(letterSpacing: letterSpacing ?? 0);
  }

  static TextStyle interStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return AppTextStyles.body(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    ).copyWith(letterSpacing: letterSpacing ?? 0);
  }

  static TextStyle satoshiStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return AppTextStyles.heading(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    ).copyWith(letterSpacing: letterSpacing ?? 0);
  }
}
