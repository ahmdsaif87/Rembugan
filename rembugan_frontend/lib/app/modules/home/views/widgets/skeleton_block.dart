import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: c.grey100,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}
