import 'package:dio/dio.dart' as dio;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../routes/app_pages.dart';
import 'social_components.dart';

class ConnectionsListView extends StatefulWidget {
  const ConnectionsListView({super.key});

  @override
  State<ConnectionsListView> createState() => _ConnectionsListViewState();
}

class _ConnectionsListViewState extends State<ConnectionsListView> {
  final _api = Get.find<ApiClient>();
  List<Map<String, dynamic>> _connections = [];
  bool _loading = true;
  late final String _userId;
  late final String _userName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _userId = args?['userId'] as String? ?? '';
    _userName = args?['userName'] as String? ?? '';
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await _api.get('/connections/$_userId');
      final body = res.data;
      if (body is Map && body['data'] is List) {
        setState(() {
          _connections = (body['data'] as List).cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } on dio.DioException {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return SocialScaffold(
      title: 'Koneksi $_userName',
      subtitle: '${_connections.length} koneksi',
      child: _loading
          ? const SkeletonChatList()
          : _connections.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Belum memiliki koneksi',
                      style: AppFonts.satoshiStyle(
                        fontSize: 14,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _connections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conn = _connections[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: c.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 4,
                        ),
                        leading: AppAvatar(
                          photoUrl: conn['photo_url'] as String?,
                          radius: 22,
                        ),
                        title: Text(
                          conn['full_name'] as String? ?? '',
                          style: AppFonts.satoshiStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '@${conn['handle'] as String? ?? ''}',
                          style: AppFonts.satoshiStyle(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          FluentIcons.chevron_right_24_regular,
                          size: 16,
                        ),
                        onTap: () {
                          final currentUid = Get.find<AuthService>().currentUser.value?.id;
                          final targetId = conn['user_id'] as String?;
                          if (targetId != null) {
                            if (targetId == currentUid) {
                              Get.toNamed(Routes.PROFILE);
                            } else {
                              Get.toNamed(Routes.otherProfileRoute(targetId));
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
