import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralLight,
      body: SafeArea(
        child: Column(
          children: [
            // Logo di atas
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.md,
              ),
              child: Text(
                'Rembugan.',
                style: AppFonts.satoshiStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  final data = controller.onboardingData[index];
                  return _OnboardingPage(
                    imagePath: data['image']!,
                    title: data['title']!,
                    description: data['description']!,
                  );
                },
              ),
            ),

            // Dot indicator
            Obx(
              () => _DotIndicator(
                currentPage: controller.currentPage.value,
                totalPages: controller.onboardingData.length,
              ),
            ),

            const SizedBox(height: 24), // Jarak dari dot ke tombol
            // Button
            Obx(() {
              final data =
                  controller.onboardingData[controller.currentPage.value];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ), // Disesuaikan agar selebar teks
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNormal,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Mengikuti standar modern
                      ),
                    ),
                    child: Center(
                      child: Text(
                        data['buttonText']!,
                        style: AppFonts.satoshiStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Lewati button (hidden on last page)
            Obx(() {
              final isLastPage =
                  controller.currentPage.value ==
                  controller.onboardingData.length - 1;
              return AnimatedOpacity(
                opacity: isLastPage ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: isLastPage ? null : controller.skipOnboarding,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      'Lewati',
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors
                            .primaryNormal, // Diberi warna utama agar jelas bisa di-klik
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24), // Jarak aman layar bawah
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Widget: Halaman Onboarding (Gambar + Teks)
// ────────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // 1. Berikan sedikit jarak aman dari header/logo
          const SizedBox(height: 20),

          // 2. Gambar ilustrasi diberi flex agar proporsinya pas
          Expanded(flex: 6, child: Image.asset(imagePath, fit: BoxFit.contain)),

          // Jarak fix dari gambar ke judul
          const SizedBox(height: 32),

          // Judul
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.satoshiStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),

          // Jarak fix dari judul ke deskripsi
          const SizedBox(height: 12),

          // Deskripsi
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppFonts.satoshiStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.neutralDarker,
              height: 1.5,
            ),
          ),

          // 3. INI KUNCINYA: Spacer di bawah teks akan mendorong teks ke atas
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Widget: Dot Indicator (Page Indicator)
// ────────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _DotIndicator({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: isActive ? 24 : 8, // Sedikit dihaluskan dimensinya
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryNormal
                : AppColors.primaryNormal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.xxs),
          ),
        );
      }),
    );
  }
}
