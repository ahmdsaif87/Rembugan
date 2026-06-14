import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/services/profile_service.dart';
import 'app/core/services/theme_service.dart';
import 'app/core/theme/theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProfileService(), permanent: true);
  Get.put(ThemeService(), permanent: true);
  runApp(const RembuganApp());
}

class RembuganApp extends StatelessWidget {
  const RembuganApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        title: "Rembugan",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeService.themeMode,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 260),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  }
}
