import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.photoUrl,
    this.radius = 20,
    this.borderWidth = 0,
  });

  final String? photoUrl;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.grey200,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Icon(
              FluentIcons.person_24_regular,
              size: radius * 0.65,
              color: AppColors.grey500,
            ),
    );
  }
}

class AppCoverPlaceholder extends StatelessWidget {
  const AppCoverPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.grey200);
  }
}
