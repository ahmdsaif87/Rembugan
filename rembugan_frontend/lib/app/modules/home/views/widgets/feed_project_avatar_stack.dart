import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class FeedProjectAvatarStack extends StatelessWidget {
  const FeedProjectAvatarStack({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final visibleCount = count.clamp(1, 2);

    return SizedBox(
      width: 57,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visibleCount; i++)
            Positioned(
              left: i * 15,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 1.4),
                ),
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: AssetImage('lib/assets/img/avatar.png'),
                ),
              ),
            ),
          Positioned(
            left: visibleCount * 15,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: c.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentIcons.add_24_regular,
                size: 14,
                color: c.grey500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
