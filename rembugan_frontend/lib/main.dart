import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/services/profile_service.dart';
import 'app/core/theme/theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProfileService(), permanent: true);
  runApp(
    GetMaterialApp(
      title: "Rembugan",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 260),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
