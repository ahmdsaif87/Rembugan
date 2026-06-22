import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class FeedMiniChip extends StatelessWidget {
  const FeedMiniChip({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: c.grey700,
        ),
      ),
    );
  }
}
