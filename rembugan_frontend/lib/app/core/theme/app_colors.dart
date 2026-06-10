import 'package:flutter/material.dart';

class AppColors {
  static const Color primary50 = Color(0xFFEDEFFE);
  static const Color primary100 = Color(0xFFC8CEFC);
  static const Color primary200 = Color(0xFFAEB6FB);
  static const Color primary300 = Color(0xFF8895F9);
  static const Color primary400 = Color(0xFF7181F8);
  static const Color primary500 = Color(0xFF4E61F6);
  static const Color primary600 = Color(0xFF4758E0);
  static const Color primary700 = Color(0xFF3745AF);
  static const Color primary800 = Color(0xFF2B3587);
  static const Color primary900 = Color(0xFF212967);

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EA);
  static const Color grey300 = Color(0xFFD2D5DB);
  static const Color grey400 = Color(0xFF9EA2AE);
  static const Color grey500 = Color(0xFF6D717F);
  static const Color grey600 = Color(0xFF4D5461);
  static const Color grey700 = Color(0xFF394050);
  static const Color grey800 = Color(0xFF212936);
  static const Color grey900 = Color(0xFF131927);

  static const Color success500 = Color(0xFF43B75D);
  static const Color error500 = Color(0xFFEE443F);
  static const Color warning500 = Color(0xFFFFAA00);
  static const Color info500 = Color(0xFF0095FF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color black87 = Color(0xDE000000);
  static const Color black12 = Color(0x1F000000);

  static const Color primary = primary500;
  static const Color primaryHover = primary500;
  static const Color primaryPressed = primary600;
  static const Color primarySoft = primary50;
  static const Color primaryTint = primary100;
  static const Color brandAccent = primary500;

  static const Color secondary = primary50;
  static const Color accentBlue = info500;
  static const Color accentGreen = success500;
  static const Color accentPink = primary400;
  static const Color accentOrange = warning500;

  static const Color background = white;
  static const Color surface = white;
  static const Color surfaceElevated = white;
  static const Color surfaceSecondary = grey50;
  static const Color surfaceWarm = grey50;
  static const Color input = grey100;

  static const Color textPrimary = grey900;
  static const Color textSecondary = grey500;
  static const Color textTertiary = grey400;
  static const Color placeholder = grey400;
  static const Color icon = grey700;
  static const Color iconActive = primary500;

  static const Color border = grey200;
  static const Color borderStrong = grey300;
  static const Color disabled = grey300;

  static const Color success = success500;
  static const Color warning = warning500;
  static const Color error = error500;
  static const Color danger = error500;
  static const Color info = info500;

  static const Color success50 = Color(0xFFEAF8EE);
  static const Color success100 = Color(0xFFD8F1DE);
  static const Color success200 = Color(0xFFB4E5BF);
  static const Color success300 = Color(0xFF8FD99F);
  static const Color success400 = Color(0xFF69C97C);
  static const Color success600 = Color(0xFF37994D);
  static const Color success700 = Color(0xFF2D7A40);
  static const Color success800 = Color(0xFF245F34);
  static const Color success900 = Color(0xFF1D4C2B);

  static const Color danger50 = Color(0xFFFEEDEC);
  static const Color danger100 = Color(0xFFFCDAD9);
  static const Color danger200 = Color(0xFFF8B6B3);
  static const Color danger300 = Color(0xFFF48F8C);
  static const Color danger400 = Color(0xFFF06A66);
  static const Color danger500 = error500;
  static const Color danger600 = Color(0xFFD83C38);
  static const Color danger700 = Color(0xFFAE302D);
  static const Color danger800 = Color(0xFF842522);
  static const Color danger900 = Color(0xFF651D1A);

  static const Color warning50 = Color(0xFFFFF7E6);
  static const Color warning100 = Color(0xFFFFEAC2);
  static const Color warning200 = Color(0xFFFFD98F);
  static const Color warning300 = Color(0xFFFFC75C);
  static const Color warning400 = Color(0xFFFFB933);
  static const Color warning600 = Color(0xFFE59600);
  static const Color warning700 = Color(0xFFB87700);
  static const Color warning800 = Color(0xFF8F5C00);
  static const Color warning900 = Color(0xFF6B4500);

  static const Color info50 = Color(0xFFEAF6FF);
  static const Color info100 = Color(0xFFD5ECFF);
  static const Color info200 = Color(0xFFAAD9FF);
  static const Color info300 = Color(0xFF80C6FF);
  static const Color info400 = Color(0xFF55ADFF);
  static const Color info600 = Color(0xFF007BD1);
  static const Color info700 = Color(0xFF0063A8);
  static const Color info800 = Color(0xFF004B80);
  static const Color info900 = Color(0xFF003A63);

  static const Color primaryNormal = primary500;
  static const Color neutralDarker = grey900;
  static const Color neutralDark = grey500;
  static const Color neutralLight = grey50;
}

class AppTextColors {
  static const Color textPrimaryWhite = AppColors.white;
  static const Color textSecondaryWhite = AppColors.white60;
  static const Color textPrimaryBlack = AppColors.grey900;
  static const Color textSecondaryDarkGrey = AppColors.grey500;
  static const Color textGrey = AppColors.grey400;
  static const Color textLightGrey = AppColors.grey300;
  static const Color textDisabled = AppColors.grey400;
  static const Color textAccent = AppColors.primary500;
  static const Color textLinks = AppColors.primary500;
  static const Color textSuccess = AppColors.success500;
  static const Color textInfo = AppColors.info500;
  static const Color textWarning = AppColors.warning500;
  static const Color textError = AppColors.error500;
}

class AppIconColors {
  static const Color iconWhite = AppColors.white;
  static const Color iconBlack = AppColors.grey900;
  static const Color iconGrey = AppColors.grey400;
  static const Color iconLightGrey = AppColors.grey300;
  static const Color iconAccent = AppColors.primary500;
  static const Color iconSuccess = AppColors.success500;
  static const Color iconInfo = AppColors.info500;
  static const Color iconWarning = AppColors.warning500;
  static const Color iconError = AppColors.error500;
}

class AppSurfaceColors {
  static const Color surfaceWhite = AppColors.white;
  static const Color surfaceBlack = AppColors.grey900;
  static const Color surfaceGrey = AppColors.grey50;
  static const Color surfaceAccent = AppColors.primary50;
}

class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get brand => [
    BoxShadow(
      color: AppColors.primary500.withValues(alpha: 0.14),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
