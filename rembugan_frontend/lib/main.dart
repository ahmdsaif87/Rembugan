import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/services/api_client.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/chat_socket_service.dart';
import 'app/core/services/fcm_service.dart';
import 'app/core/services/profile_service.dart';
import 'app/core/services/theme_service.dart';
import 'app/core/theme/theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Get.put(ApiClient(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(ProfileService(), permanent: true);
  Get.put(ThemeService(), permanent: true);
  Get.put(ChatSocketService(), permanent: true);
  Get.put(FcmService(), permanent: true);

  await Get.find<AuthService>().init();
  if (Get.find<AuthService>().isLoggedIn.value) {
    Get.find<FcmService>().init();
  }

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
        initialRoute: Get.find<AuthService>().isLoggedIn.value
            ? Routes.HOME
            : (Get.find<AuthService>().hasSeenOnboarding.value
                ? Routes.LOGIN
                : Routes.ONBOARDING),
        getPages: AppPages.routes,
      ),
    );
  }
}
