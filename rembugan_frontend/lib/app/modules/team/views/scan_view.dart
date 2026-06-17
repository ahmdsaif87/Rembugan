import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../controllers/team_controller.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  MobileScannerController? _controller;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    _hasResult = true;
    HapticFeedback.heavyImpact();

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.pathSegments.contains('workspace')) {
      AppToast.error('QR Code tidak valid.', title: 'Gagal');
      _hasResult = false;
      return;
    }

    final id = uri.pathSegments.last;
    _controller?.stop();

    Get.bottomSheet(
      _JoinPreview(workspaceId: id),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    ).whenComplete(() {
      _hasResult = false;
      _controller?.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: Get.back,
        ),
        title: Text(
          'Scan QR Proyek',
          style: AppFonts.interStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller = MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: _onDetect,
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
              'Arahkan kamera ke QR Code proyek',
              textAlign: TextAlign.center,
              style: AppFonts.interStyle(
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

class _JoinPreview extends StatelessWidget {
  const _JoinPreview({required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final ctrl = Get.find<TeamController>();
    final workspace = ctrl.workspaces.firstWhereOrNull(
      (w) => w.id == workspaceId,
    );

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
            Icon(
              workspace != null
                  ? FluentIcons.checkmark_circle_24_filled
                  : FluentIcons.question_24_regular,
              size: 48,
              color: workspace != null
                  ? AppColors.success500
                  : c.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              workspace?.name ?? 'Proyek Tidak Ditemukan',
              style: AppFonts.interStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            if (workspace != null) ...[
              const SizedBox(height: 6),
              Text(
                workspace.description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.interStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${workspace.memberCount} anggota · ${workspace.category}',
                style: AppFonts.interStyle(
                  fontSize: 12,
                  color: c.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: workspace != null ? Get.back : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(workspace != null ? 'Gabung' : 'Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
