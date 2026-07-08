import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    syncFromRoute(Get.currentRoute, Get.arguments);
  }

  void syncFromRoute(String route, dynamic args) {
    if (args is int && args >= 0 && args < 4) {
      currentIndex.value = args;
      return;
    }
    currentIndex.value = switch (route) {
      Routes.EXPLORE => 1,
      Routes.TEAM => 2,
      Routes.PROFILE => 3,
      _ => 0,
    };
  }

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
  }
}
