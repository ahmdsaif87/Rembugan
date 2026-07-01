import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/app_toast.dart';

class QrCodeSheet extends StatefulWidget {
  const QrCodeSheet({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  final String workspaceId;
  final String workspaceName;

  static void show({
    required String workspaceId,
    required String workspaceName,
  }) {
    Get.bottomSheet(
      QrCodeSheet(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  State<QrCodeSheet> createState() => _QrCodeSheetState();
}

class _QrCodeSheetState extends State<QrCodeSheet> {
  final _api = Get.find<ApiClient>();
  String? _inviteUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvite();
  }

  Future<void> _loadInvite() async {
    try {
      final res = await _api.post('/qr/project/${widget.workspaceId}/invite');
      final data = res.data as Map<String, dynamic>?;
      final qrData = data?['data']?['qr_data'] as String?;
      if (qrData != null) {
        setState(() => _inviteUrl = qrData);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final url = _inviteUrl ?? 'https://rembugan.app/join/workspace/${widget.workspaceId}';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bagikan Proyek',
              style: AppFonts.interStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scan untuk bergabung ke "$widget.workspaceName".',
              textAlign: TextAlign.center,
              style: AppFonts.interStyle(
                fontSize: 13,
                height: 1.4,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.grey900,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.grey900,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: AppFonts.interStyle(
                        fontSize: 11,
                        color: AppColors.primary500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      AppToast.success('Link disalin.', title: 'Tersalin');
                    },
                    child: Icon(
                      FluentIcons.copy_24_regular,
                      size: 18,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: Get.back,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
