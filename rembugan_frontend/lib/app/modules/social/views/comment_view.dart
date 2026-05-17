import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_chrome.dart';
import 'social_components.dart';

void showCommentsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.94,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        child: CommentView(),
      ),
    ),
  );
}

class CommentView extends StatelessWidget {
  const CommentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      color: AppColors.borderStrong,
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
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: SocialPostCard(
                      name: 'Cameron Williamson',
                      handle: '@cameron - 2j',
                      avatarUrl: 'https://i.pravatar.cc/100?img=33',
                      body:
                          'Kami sedang mencari Flutter dev untuk bantu polishing flow onboarding dan chat. Ada yang tertarik kolaborasi minggu ini?',
                    ),
                  ),
                  Divider(height: 1, color: AppColors.border),
                  _CommentTile(
                    name: 'Dede Fernanda',
                    avatarUrl: 'https://i.pravatar.cc/100?img=60',
                    body:
                        'Aku tertarik. Bisa bantu di side UI dan state management. Scope-nya sudah ada?',
                    replies: [
                      _ReplyTile(
                        name: 'Cameron',
                        body: 'Sudah. Nanti aku share board task-nya.',
                      ),
                    ],
                  ),
                  Divider(height: 1, indent: 64, color: AppColors.border),
                  _CommentTile(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppFonts.generalSansStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '12m',
                      style: AppFonts.generalSansStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: AppFonts.generalSansStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CommentAction(
                      icon: FluentIcons.arrow_reply_24_regular,
                      label: 'Balas',
                      onTap: () {
                        if (GuestGuard.blockIfGuest('membalas komentar')) {
                          return;
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _CommentAction(
                      icon: FluentIcons.heart_24_regular,
                      label: '8',
                      onTap: () {
                        if (GuestGuard.blockIfGuest('menyukai komentar')) {
                          return;
                        }
                      },
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
  const _ReplyTile({required this.name, required this.body});

  final String name;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 1, height: 42, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$name ',
                    style: AppFonts.generalSansStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: body,
                    style: AppFonts.generalSansStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppFonts.generalSansStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
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
    final locked = GuestGuard.isGuest;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=60'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              readOnly: locked,
              onTap: () {
                if (GuestGuard.blockIfGuest('membalas komentar')) return;
              },
              decoration: InputDecoration(
                hintText: locked
                    ? 'Masuk untuk membalas komentar'
                    : 'Tulis komentar...',
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppIconButton(
            icon: FluentIcons.send_24_filled,
            isPrimary: true,
            onTap: () {
              if (GuestGuard.blockIfGuest('membalas komentar')) return;
            },
          ),
        ],
      ),
    );
  }
}
