import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_toast.dart';

class ShareSheet extends StatefulWidget {
  const ShareSheet({
    required this.postId,
    required this.postType,
    super.key,
  });

  final String postId;
  final String postType;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final _api = Get.find<ApiClient>();
  final _auth = Get.find<AuthService>();

  String? _shareLink;
  String? _whatsappUrl;
  String? _telegramUrl;
  List<Map<String, dynamic>> _friends = [];
  bool _loadingLinks = true;
  bool _loadingFriends = true;

  @override
  void initState() {
    super.initState();
    _fetchShareLinks();
    _fetchFriends();
  }

  Future<void> _fetchShareLinks() async {
    try {
      final res = await _api.get('/posts/share-links/${widget.postType}/${widget.postId}');
      final data = res.data;
      if (data is Map && data['status'] == 'success' && data['data'] != null) {
        final links = data['data'] as Map<String, dynamic>;
        _shareLink = links['share_link'] as String?;
        _whatsappUrl = links['whatsapp_url'] as String?;
        _telegramUrl = links['telegram_url'] as String?;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingLinks = false);
  }

  Future<void> _fetchFriends() async {
    try {
      final currentUid = _auth.currentUser.value?.id ?? '';
      final res = await _api.get('/connections/$currentUid');
      final data = res.data;
      if (data is Map && data['status'] == 'success' && data['data'] != null) {
        final raw = data['data'] as List? ?? [];
        _friends = raw.map((f) => <String, dynamic>{
          'user_id': f['user_id'] as String? ?? '',
          'full_name': f['full_name'] as String? ?? '',
          'handle': f['handle'] as String? ?? '',
          'photo_url': f['photo_url'] as String?,
          'sent': false,
        }).toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingFriends = false);
  }

  Future<void> _shareToFriend(Map<String, dynamic> friend) async {
    if (friend['sent']) return;

    setState(() => friend['sent'] = true);

    try {
      await _api.post('/posts/share', data: {
        'post_id': widget.postId,
        'post_type': widget.postType,
        'friend_ids': [friend['user_id']],
      });
      AppToast.success('Postingan dibagikan ke ${friend['full_name']}', title: 'Terkirim');
    } catch (e) {
      setState(() => friend['sent'] = false);
      AppToast.error('Gagal membagikan ke ${friend['full_name']}', title: 'Gagal');
    }
  }

  Future<void> _openUrl(String? url, String label) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppToast.error('Tidak dapat membuka $label', title: 'Gagal');
    }
  }

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
            readOnly: true,
            style: AppFonts.satoshiStyle(fontSize: 13, color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari teman...',
              hintStyle: AppFonts.satoshiStyle(fontSize: 12, color: c.textTertiary),
              prefixIcon: Icon(FluentIcons.search_24_regular, size: 18, color: c.textTertiary),
              filled: true,
              fillColor: c.grey50,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: _loadingFriends
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada koneksi teman',
                          style: AppFonts.satoshiStyle(fontSize: 13, color: c.textTertiary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Row(
                              children: [
                                AppAvatar(
                                  photoUrl: friend['photo_url'] as String?,
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    friend['full_name'] as String? ?? '',
                                    style: AppFonts.satoshiStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: friend['sent'] ? null : () => _shareToFriend(friend),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: friend['sent'] ? c.grey100 : AppColors.primary,
                                    foregroundColor: friend['sent'] ? c.textTertiary : AppColors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                  if (_shareLink != null) {
                    Clipboard.setData(ClipboardData(text: _shareLink!));
                    AppToast.success('Link disalin ke clipboard', title: 'Tersalin');
                  }
                  Navigator.pop(context);
                },
              ),
              _buildShareAction(
                icon: FluentIcons.chat_24_regular,
                label: 'WhatsApp',
                onTap: () {
                  _openUrl(_whatsappUrl, 'WhatsApp');
                  Navigator.pop(context);
                },
              ),
              _buildShareAction(
                icon: FluentIcons.send_24_regular,
                label: 'Telegram',
                onTap: () {
                  _openUrl(_telegramUrl, 'Telegram');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          if (_loadingLinks)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: c.textTertiary),
                ),
              ),
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
