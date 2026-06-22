import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../explore/domain/entities/competition.dart';

class RecommendedCompetitionCard extends StatelessWidget {
  final Competition competition;
  final int index;
  final VoidCallback onTap;

  const RecommendedCompetitionCard({
    required this.competition,
    required this.index,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final posterAsset = switch (index % 4) {
      0 => 'lib/assets/img/contoh poster1.jpeg',
      1 => 'lib/assets/img/contoh poster2.jpeg',
      2 => 'lib/assets/img/contoh poster3.jpeg',
      _ => 'lib/assets/img/contoh poster4.jpeg',
    };

    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
        image: DecorationImage(
          image: AssetImage(posterAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0.08),
                  AppColors.black.withValues(alpha: 0.35),
                  AppColors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        competition.category.toUpperCase(),
                        style: AppFonts.satoshiStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning500,
                        borderRadius: BorderRadius.circular(AppRadius.xxs),
                      ),
                      child: Text(
                        competition.badge,
                        style: AppFonts.satoshiStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            competition.organizer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.satoshiStyle(
                              fontSize: 10.5,
                              color: AppColors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                        Icon(
                          FluentIcons.calendar_24_regular,
                          size: 10,
                          color: AppColors.white.withValues(alpha: 0.72),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          competition.deadline,
                          style: AppFonts.satoshiStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
