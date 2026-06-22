import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'status_tone.dart';

class FeedMatchBadge extends StatelessWidget {
  const FeedMatchBadge({required this.label, super.key});

  final String label;

  StatusTone get tone {
    final value = label.toLowerCase();
    if (value.contains('cocok')) {
      return const StatusTone(
        background: AppColors.info50,
        border: AppColors.info50,
        foreground: AppColors.info700,
      );
    }
    if (value.contains('ditutup') || value.contains('deadline')) {
      return const StatusTone(
        background: AppColors.warning50,
        border: AppColors.warning100,
        foreground: AppColors.warning700,
      );
    }
    if (value.contains('penuh')) {
      return const StatusTone(
        background: AppColors.danger50,
        border: AppColors.danger100,
        foreground: AppColors.danger600,
      );
    }
    if (value.contains('trending')) {
      return const StatusTone(
        background: AppColors.info50,
        border: AppColors.info100,
        foreground: AppColors.info600,
      );
    }
    if (value.contains('baru')) {
      return const StatusTone(
        background: AppColors.primary50,
        border: AppColors.primary50,
        foreground: AppColors.primary400,
      );
    }
    return const StatusTone(
      background: AppColors.info50,
      border: AppColors.info50,
      foreground: AppColors.info700,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: style.background),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: style.foreground,
        ),
      ),
    );
  }
}
