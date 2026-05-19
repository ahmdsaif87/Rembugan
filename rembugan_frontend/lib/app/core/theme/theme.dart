import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F1F1F);
  static const Color primaryHover = Color(0xFF2B2B2B);
  static const Color primaryPressed = Color(0xFF000000);
  static const Color primarySoft = Color(0xFFF7F7F7);
  static const Color primaryTint = Color(0xFFE5E5E5);
  static const Color brandAccent = Color(0xFF681726);

  static const Color secondary = Color(0xFFE8D8CE);
  static const Color accentBlue = Color(0xFF315BD6);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentPink = Color(0xFFDB2777);
  static const Color accentOrange = Color(0xFFFF6B2C);

  static const Color success50 = Color(0xFFEAF7EE);
  static const Color success100 = Color(0xFFC7EBD1);
  static const Color success200 = Color(0xFFA3DCAF);
  static const Color success300 = Color(0xFF7DCD8E);
  static const Color success400 = Color(0xFF5DBF72);
  static const Color success500 = Color(0xFF3FB45A);
  static const Color success600 = Color(0xFF2FA34D);
  static const Color success700 = Color(0xFF25883F);
  static const Color success800 = Color(0xFF1E6C35);
  static const Color success900 = Color(0xFF19552D);

  static const Color danger50 = Color(0xFFFDECEC);
  static const Color danger100 = Color(0xFFF8C8C8);
  static const Color danger200 = Color(0xFFF3A0A0);
  static const Color danger300 = Color(0xFFEE7979);
  static const Color danger400 = Color(0xFFE85C5C);
  static const Color danger500 = Color(0xFFEF4444);
  static const Color danger600 = Color(0xFFDC2626);
  static const Color danger700 = Color(0xFFB91C1C);
  static const Color danger800 = Color(0xFF8F1D1D);
  static const Color danger900 = Color(0xFF711B1B);

  static const Color warning50 = Color(0xFFFFF7E6);
  static const Color warning100 = Color(0xFFFFE4B3);
  static const Color warning200 = Color(0xFFFFD180);
  static const Color warning300 = Color(0xFFFFBF52);
  static const Color warning400 = Color(0xFFFFB229);
  static const Color warning500 = Color(0xFFFFA600);
  static const Color warning600 = Color(0xFFF59E0B);
  static const Color warning700 = Color(0xFFD97706);
  static const Color warning800 = Color(0xFFA86600);
  static const Color warning900 = Color(0xFF875300);

  static const Color info50 = Color(0xFFEAF6FF);
  static const Color info100 = Color(0xFFCFEAFF);
  static const Color info200 = Color(0xFFA9D8FA);
  static const Color info300 = Color(0xFF7FC5F5);
  static const Color info400 = Color(0xFF45AAED);
  static const Color info500 = Color(0xFF1698E8);
  static const Color info600 = Color(0xFF0E8BD8);
  static const Color info700 = Color(0xFF0874B8);
  static const Color info800 = Color(0xFF075D94);
  static const Color info900 = Color(0xFF064A75);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF7F7F7);
  static const Color surfaceWarm = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF626A73);
  static const Color textTertiary = Color(0xFF8E949D);

  static const Color border = Color(0xFFEAEAEA);
  static const Color borderStrong = Color(0xFFDADADA);

  static const Color success = success600;
  static const Color warning = warning600;
  static const Color error = danger600;
  static const Color danger = danger600;
  static const Color info = info600;

  // Aliases used in views
  static const Color primaryNormal = primary;
  static const Color neutralDarker = textPrimary;
  static const Color neutralDark = textSecondary;
  static const Color neutralLight = surfaceSecondary;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.018),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get brand => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.16),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppFonts {
  static const String satoshi = 'Satoshi';
  static const String inter = 'Inter';

  static TextStyle headingStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: satoshi,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle interStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: inter,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle satoshiStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: satoshi,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
    );

    final textTheme = TextTheme(
      displayLarge: AppFonts.headingStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.08,
      ),
      headlineLarge: AppFonts.headingStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.15,
      ),
      titleLarge: AppFonts.headingStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: AppFonts.interStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: AppFonts.interStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: AppFonts.interStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.45,
      ),
      bodySmall: AppFonts.interStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: AppFonts.interStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.inter,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
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

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          minimumSize: const Size(48, 48),
          textStyle: AppFonts.interStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          minimumSize: const Size(48, 48),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        hintStyle: AppFonts.interStyle(
          fontSize: 14,
          color: AppColors.textTertiary.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF2F333A),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerColor: AppColors.border,
    );
  }
}
