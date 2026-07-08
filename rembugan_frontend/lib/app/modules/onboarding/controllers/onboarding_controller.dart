import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/assets/img/onboarding1.png',
      'title': 'Cari Tim yang Sefrekuensi',
      'description':
          'Temukan kolaborator lintas prodi di kampus yang\npunya skill valid dan siap diajak kerja bareng.',
      'buttonText': 'Lanjut',
    },
    {
      'image': 'lib/assets/img/onboarding2.png',
      'title': 'Workspace Anti Ribet',
      'description':
          'Kelola to-do list kelompok dan pantau progres\nperkembangan proyekmu langsung dari satu aplikasi.',
      'buttonText': 'Mulai Sekarang',
    },
  ];

  Future<void> nextPage() async {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await Get.find<AuthService>().markOnboardingSeen();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> skipOnboarding() async {
    await Get.find<AuthService>().markOnboardingSeen();
    Get.offAllNamed(Routes.LOGIN);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
