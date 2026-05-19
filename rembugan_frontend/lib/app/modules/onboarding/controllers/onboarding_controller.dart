import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/assets/img/onboarding 1.png',
      'title': 'Eksplorasi Proyek\nKeren',
      'description':
          'Jelajahi berbagai kolaborasi yang pas dengan skill-mu. Temukan kesempatan bagus untuk portofolio atau tugas akhir.',
      'buttonText': 'Lanjut',
    },
    {
      'image': 'lib/assets/img/onboarding 2.png',
      'title': 'Cari Rekan yang Tepat',
      'description':
          'Temukan talenta dengan berbagai keahlian untuk bantu wujudkan ide proyekmu menjadi nyata.',
      'buttonText': 'Lanjut',
    },
    {
      'image': 'lib/assets/img/onboarding3.png',
      'title': 'Satu Workspace\nTerintegrasi',
      'description':
          'Kelola pembagian tugas, diskusi dengan tim, dan pantau perkembangan proyek dari satu aplikasi.',
      'buttonText': 'Mulai Sekarang',
    },
  ];

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigasi ke halaman utama
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void skipOnboarding() {
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
