import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_chrome.dart';
import '../../controllers/home_controller.dart';

class RecommendedPersonCard extends StatelessWidget {
  final RecommendedPerson person;
  final VoidCallback onFollow;

  const RecommendedPersonCard({required this.person, required this.onFollow, super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      width: 165,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppNetworkAvatar(radius: 24, imageUrl: person.avatarUrl),
            const SizedBox(height: 8),
            Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              person.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.satoshiStyle(
                fontSize: 10,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: person.tags
                  .take(2)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                      ),
                      child: Text(
                        tag,
                        style: AppFonts.satoshiStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: double.infinity,
                height: 28,
                child: TextButton(
                  onPressed: onFollow,
                  style: TextButton.styleFrom(
                    backgroundColor: person.isFollowing.value
                        ? c.grey100
                        : AppColors.primary,
                    foregroundColor: person.isFollowing.value
                        ? c.textSecondary
                        : AppColors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  child: Text(
                    person.isFollowing.value ? 'Mengikuti' : 'Ikuti',
                    style: AppFonts.satoshiStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: person.isFollowing.value
                          ? c.textSecondary
                          : AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
