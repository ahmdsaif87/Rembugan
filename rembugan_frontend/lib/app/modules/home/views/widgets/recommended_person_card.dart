import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_chrome.dart';
import '../../controllers/home_controller.dart';

class RecommendedPersonCard extends StatelessWidget {
  final RecommendedPerson person;
  final VoidCallback onFollow;
  final VoidCallback? onTapProfile;

  const RecommendedPersonCard({required this.person, required this.onFollow, this.onTapProfile, super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTapProfile,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
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
              () {
                final status = person.connectionStatus.value;
                final isPending = status == 'pending';
                final isConnected = status == 'accepted';
                final label = isConnected
                    ? 'Terhubung'
                    : isPending
                        ? 'Tertunda'
                        : 'Hubungkan';
                final borderColor = isConnected || isPending
                    ? c.grey300
                    : AppColors.primary;
                final textColor = isConnected || isPending
                    ? c.textSecondary
                    : AppColors.primary;
                return SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: OutlinedButton(
                    onPressed: onFollow,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: c.surface,
                      foregroundColor: textColor,
                      side: BorderSide(color: borderColor),
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
    ),
  );
  }
}
