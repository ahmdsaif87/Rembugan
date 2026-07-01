import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_toast.dart';

class ProfileQrView extends StatefulWidget {
  const ProfileQrView({super.key});

  @override
  State<ProfileQrView> createState() => _ProfileQrViewState();
}

class _ProfileQrViewState extends State<ProfileQrView> {
  int _tabIndex = 0;
  final _api = Get.find<ApiClient>();
  String? _qrData;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  Future<void> _loadQr() async {
    try {
      final res = await _api.get('/qr/profile');
      final data = res.data as Map<String, dynamic>?;
      final qrData = data?['data']?['qr_data'] as String?;
      if (qrData != null) setState(() => _qrData = qrData);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final user = Get.find<AuthService>().currentUser.value;
    final profile = Get.find<ProfileService>().profile.value;
    final name = user?.fullName ?? 'User';
    final photoUrl = profile?.photoUrl;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: Icon(FluentIcons.chevron_left_24_regular, color: c.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'QR Code',
          style: AppFonts.satoshiStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabPill(label: 'QR Saya', index: 0, active: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                const SizedBox(width: 8),
                _TabPill(label: 'Scan QR', index: 1, active: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tabIndex == 0 ? _buildQrDisplay(c, name, photoUrl) : _buildScanner(c),
          ),
        ],
      ),
    );
  }

  Widget _buildQrDisplay(AppC c, String name, String? photoUrl) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _qrData == null
                  ? const SizedBox(
                      width: 220, height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.grey900),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.grey900),
                    ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primarySoft,
                border: Border.all(color: c.surface, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: photoUrl != null
                    ? Image.network(photoUrl, fit: BoxFit.cover, width: 60, height: 60)
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: AppFonts.satoshiStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary500),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppFonts.satoshiStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan kode ini untuk menambahkan saya\ndi Rembugan',
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(fontSize: 13, color: c.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  bool _hasScanResult = false;

  Widget _buildScanner(AppC c) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
            onDetect: (capture) {
              if (_hasScanResult) return;
              final barcode = capture.barcodes.firstOrNull;
              final raw = barcode?.rawValue;
              if (raw == null || raw.isEmpty) return;

              _hasScanResult = true;
              HapticFeedback.heavyImpact();

              final uri = Uri.tryParse(raw);
              if (uri == null) {
                AppToast.error('QR Code tidak valid.');
                _hasScanResult = false;
                return;
              }

              final segments = uri.pathSegments;
              if (segments.isNotEmpty) {
                final userId = segments.last;
                if (userId.isNotEmpty) {
                  Get.offNamed('/other-profile/$userId');
                  return;
                }
              }

              AppToast.error('QR Code tidak valid.');
              _hasScanResult = false;
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code profile',
              textAlign: TextAlign.center,
              style: AppFonts.satoshiStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.index, required this.active, required this.onTap});
  final String label;
  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary500 : c.grey100,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppFonts.satoshiStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.white : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
