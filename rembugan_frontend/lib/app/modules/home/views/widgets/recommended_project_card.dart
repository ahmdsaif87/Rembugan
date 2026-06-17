import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../explore/domain/entities/project.dart';
import 'feed_match_badge.dart';
import 'feed_mini_chip.dart';
import 'feed_project_avatar_stack.dart';

class RecommendedProjectCard extends StatefulWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;

  const RecommendedProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
    super.key,
  });

  @override
  State<RecommendedProjectCard> createState() => _RecommendedProjectCardState();
}

class _RecommendedProjectCardState extends State<RecommendedProjectCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final visibleSkills = widget.project.skills.take(2).toList();

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _isPressed = v),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 280,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: _isPressed ? AppColors.primary200 : c.border,
              ),
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.project.matchScore > 0)
                  FeedMatchBadge(label: 'Sesuai skill'),
                const SizedBox(height: 10),
                Text(
                  widget.project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 14,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.project.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.satoshiStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: c.grey600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: visibleSkills
                      .map(
                        (skill) => FeedMiniChip(label: skill, color: c.grey100),
                      )
                      .toList(),
                ),
                const Spacer(),
                Row(
                  children: [
                    FeedProjectAvatarStack(
                      count: widget.project.memberAvatars.length,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.project.postedAgo,
                      style: AppFonts.satoshiStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: c.grey500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      FluentIcons.people_team_24_filled,
                      size: 16,
                      color: c.grey700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.project.filledSlots}/${widget.project.totalSlots}',
                      style: AppFonts.satoshiStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success500,
                      ),
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
