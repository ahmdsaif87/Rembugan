import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../theme/theme.dart';

enum AppNavDestination { home, explore, team, profile, none }

class AppLayeredBackground extends StatelessWidget {
  const AppLayeredBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: child,
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.md,
    this.color,
    this.borderColor,
    this.shadow,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final resolvedColor = color ?? c.card;
    final resolvedBorder = borderColor ?? c.border;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: resolvedBorder),
        boxShadow: shadow ?? const [],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.onTap,
    this.isPrimary = false,
    this.badge = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final background = isPrimary
        ? AppColors.primary500
        : c.primarySoft;
    final foreground = isPrimary
        ? AppTextColors.textPrimaryWhite
        : AppIconColors.iconAccent;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isPrimary ? AppColors.primary500 : c.border,
            ),
            boxShadow: isPrimary ? AppShadows.soft : const [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: foreground, size: 22),
              if (badge)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.card, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNetworkAvatar extends StatelessWidget {
  const AppNetworkAvatar({required this.imageUrl, this.radius = 24, super.key});

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final size = radius * 2;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: c.primarySoft,
            child: Icon(
              FluentIcons.person_24_regular,
              color: AppColors.primary500,
              size: radius,
            ),
          ),
        ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.satoshiStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: AppFonts.satoshiStyle(
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTextColors.textLinks,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText!,
              style: AppFonts.satoshiStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTextColors.textLinks,
              ),
            ),
          ),
      ],
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppSurface(
          shadow: const [],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      c.primarySoft,
                      AppColors.primary100.withValues(alpha: 0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border),
                ),
                child: Icon(icon, color: AppIconColors.iconAccent, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.satoshiStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.satoshiStyle(
                  fontSize: 13,
                  color: c.textSecondary,
                  height: 1.4,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                AppButton(
                  label: actionLabel!,
                  onTap: onAction,
                  width: 180,
                  height: 42,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.current, this.onTap, super.key});

  final AppNavDestination current;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final c = AppC.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 7, 16, bottomPadding + 8),
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: current == AppNavDestination.home
                ? FluentIcons.home_24_filled
                : FluentIcons.home_24_regular,
            label: 'Beranda',
            active: current == AppNavDestination.home,
            onTap: () => onTap?.call(0),
          ),
          _NavItem(
            icon: current == AppNavDestination.explore
                ? FluentIcons.globe_24_filled
                : FluentIcons.globe_24_regular,
            label: 'Jelajah',
            active: current == AppNavDestination.explore,
            onTap: () => onTap?.call(1),
          ),
          _CreateButton(),
          _NavItem(
            icon: current == AppNavDestination.team
                ? FluentIcons.apps_24_filled
                : FluentIcons.apps_24_regular,
            label: 'Proyek',
            active: current == AppNavDestination.team,
            onTap: () => onTap?.call(2),
          ),
          _NavItem(
            icon: current == AppNavDestination.profile
                ? FluentIcons.person_24_filled
                : FluentIcons.person_24_regular,
            label: 'Profil',
            active: current == AppNavDestination.profile,
            onTap: () => onTap?.call(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final color = active ? AppColors.primary500 : c.grey400;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.satoshiStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.CREATE_POST);
        },
        child: Container(
          width: 62,
          height: 46,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary500.withValues(alpha: 0.2)
                : AppColors.primary200.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            FluentIcons.add_24_regular,
            color: isDark ? AppColors.primary300 : AppColors.primary500,
            size: 33,
          ),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.isOutline = false,
    this.icon,
    this.width = double.infinity,
    this.height = 48,
    this.child,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isOutline;
  final IconData? icon;
  final double width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    Color bg;
    Color fg;
    Border? border;

    if (onTap == null) {
      bg = c.grey300;
      fg = c.grey500;
    } else if (isOutline) {
      bg = c.card;
      fg = AppColors.primary500;
      border = Border.all(color: c.grey200);
    } else if (isPrimary) {
      bg = AppColors.primary500;
      fg = AppColors.white;
    } else {
      bg = c.primarySoft;
      fg = AppColors.primary500;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: border,
        ),
        child: child ?? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: AppTextStyles.button(fontSize: 14, color: fg)),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'controller and initialValue cannot be used together',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyles.button(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textAlign: textAlign,
          focusNode: focusNode,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          validator: validator,
          style: AppTextStyles.bodyMedium(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            counterText: maxLength == null ? null : '',
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 0,
            ),
            filled: true,
            fillColor: c.input,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: c.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.primary500,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.error500,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(
                color: AppColors.error500,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: padding,
      radius: AppRadius.md,
      shadow: AppShadows.soft,
      onTap: onTap,
      child: child,
    );
  }
}

class AppListItem extends StatelessWidget {
  const AppListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.md,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppFonts.satoshiStyle(
                      fontSize: 12,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? c.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.satoshiStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppTextColors.textAccent,
        ),
      ),
    );
  }
}
