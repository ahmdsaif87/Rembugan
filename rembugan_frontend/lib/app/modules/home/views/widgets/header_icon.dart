import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class HeaderIcon extends StatelessWidget {
  const HeaderIcon({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badgeCount,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badgeCount;

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, size: 24, color: c.grey900)),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                    child: Text(
                      badgeCount! > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
