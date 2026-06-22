import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class HeaderIcon extends StatelessWidget {
  const HeaderIcon({required this.icon, required this.onTap, this.tooltip, super.key});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final btn = Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 24, color: c.grey900),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
