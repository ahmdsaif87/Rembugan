import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key});

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Aisyah', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Nadia', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Raka', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
    {'name': 'Dede', 'avatar': 'lib/assets/img/avatar.png', 'sent': false},
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: c.grey200,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Bagikan ke Teman',
            style: AppFonts.headingStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            style: AppFonts.satoshiStyle(
              fontSize: 13,
              color: c.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Cari teman...',
              hintStyle: AppFonts.satoshiStyle(
                fontSize: 12,
                color: c.textTertiary,
              ),
              prefixIcon: Icon(
                FluentIcons.search_24_regular,
                size: 18,
                color: c.textTertiary,
              ),
              filled: true,
              fillColor: c.grey50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      const AppAvatar(radius: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          friend['name'],
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: friend['sent']
                            ? null
                            : () {
                                setState(() {
                                  friend['sent'] = true;
                                });
                                AppToast.success('Postingan dibagikan ke ${friend['name']}', title: 'Terkirim');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: friend['sent']
                              ? c.grey100
                              : AppColors.primary,
                          foregroundColor: friend['sent']
                              ? c.textTertiary
                              : AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        child: Text(
                          friend['sent'] ? 'Terkirim' : 'Kirim',
                          style: AppFonts.satoshiStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: friend['sent'] ? c.textTertiary : AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(color: c.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareAction(
                icon: FluentIcons.copy_24_regular,
                label: 'Salin Link',
                onTap: () {
                  Clipboard.setData(
                    const ClipboardData(text: 'https://rembugan.app/post/1'),
                  );
                  Navigator.pop(context);
                  AppToast.success('Link postingan berhasil disalin ke clipboard.', title: 'Tautan disalin');
                },
              ),
              _buildShareAction(
                icon: FluentIcons.chat_24_regular,
                label: 'WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  AppToast.info('Membuka WhatsApp...', title: 'WhatsApp');
                },
              ),
              _buildShareAction(
                icon: FluentIcons.send_24_regular,
                label: 'Telegram',
                onTap: () {
                  Navigator.pop(context);
                  AppToast.info('Membuka Telegram...', title: 'Telegram');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final c = AppC.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c.textPrimary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppFonts.satoshiStyle(
                fontSize: 10.5,
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
