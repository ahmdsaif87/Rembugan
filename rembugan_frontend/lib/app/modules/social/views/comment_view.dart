import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';

void showCommentsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.75,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        child: CommentView(),
      ),
    ),
  );
}

class CommentView extends StatelessWidget {
  const CommentView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.borderStrong,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: const Icon(FluentIcons.chevron_down_24_regular),
                      ),
                      Expanded(
                        child: Text(
                          'Komentar',
                          textAlign: TextAlign.center,
                          style: AppFonts.headingStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border.withValues(alpha: 0.4)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                children: [
                  const _CommentTile(
                    name: 'Dede Fernanda',
                    avatarUrl: 'https://i.pravatar.cc/100?img=60',
                    body:
                        'Aku tertarik. Bisa bantu di side UI dan state management. Scope-nya sudah ada?',
                    replies: [
                      _ReplyTile(
                        name: 'Cameron',
                        avatarUrl: 'https://i.pravatar.cc/100?img=15',
                        body: 'Sudah. Nanti aku share board task-nya.',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 72),
                    child: Divider(height: 1, color: c.border.withValues(alpha: 0.3)),
                  ),
                  const _CommentTile(
                    name: 'Raka Pratama',
                    avatarUrl: 'https://i.pravatar.cc/100?img=47',
                    body:
                        'Kalau butuh review UX, aku bisa bantu cek heuristic dan microcopy.',
                  ),
                ],
              ),
            ),
            const _ReplyComposer(),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.name,
    required this.avatarUrl,
    required this.body,
    this.replies = const [],
  });

  final String name;
  final String avatarUrl;
  final String body;
  final List<Widget> replies;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatarUrl),
              ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppFonts.satoshiStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '12m',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: AppFonts.satoshiStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CommentAction(
                      icon: FluentIcons.arrow_reply_24_regular,
                      label: 'Balas',
                      onTap: () {},
                    ),
                    const SizedBox(width: 16),
                    _CommentAction(
                      icon: FluentIcons.heart_24_regular,
                      label: '8',
                      onTap: () {},
                    ),
                  ],
                ),
                if (replies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(children: replies),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.name,
    required this.body,
    this.avatarUrl,
  });

  final String name;
  final String body;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 44,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 10),
          if (avatarUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(avatarUrl!),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: c.grey100,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: AppFonts.satoshiStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$name ',
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: body,
                      style: AppFonts.satoshiStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentAction extends StatelessWidget {
  const _CommentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer();

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: c.surface,
      ),
      child: Row(
        children: [
          const AppAvatar(radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: c.surfaceSecondary,
                hintText: 'Tulis komentar...',
                hintStyle: AppFonts.satoshiStyle(
                  fontSize: 13.5,
                  color: c.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 13.5,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(
                    color: c.border.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(
                    color: c.textPrimary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(
                    color: c.border.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
              ),
              style: AppFonts.satoshiStyle(
                fontSize: 13.5,
                color: c.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Icon(
                    FluentIcons.send_24_filled,
                    size: 16,
                    color: c.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
