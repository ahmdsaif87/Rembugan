import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/theme.dart';
import '../../../core/services/api_client.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/skeleton.dart';

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
    if (uri == null) {
      AppToast.error('QR Code tidak valid.', title: 'Gagal');
      _hasResult = false;
      return;
    }

    // Extract invite token from URL path: /join/{token}
    final segments = uri.pathSegments;
    final joinIdx = segments.indexOf('join');
    final token = joinIdx != -1 && joinIdx < segments.length - 1
        ? segments[joinIdx + 1]
        : null;

    _controller?.stop();

    Get.bottomSheet(
      _JoinPreview(token: token),
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

class _JoinPreview extends StatefulWidget {
  const _JoinPreview({this.token});

  final String? token;

  @override
  State<_JoinPreview> createState() => _JoinPreviewState();
}

class _JoinPreviewState extends State<_JoinPreview> {
  final _api = Get.find<ApiClient>();
  bool _isLoading = true;
  String? _error;
  String? _projectTitle;
  int? _projectId;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    if (widget.token == null) {
      setState(() => _error = 'QR Code tidak valid.');
      _isLoading = false;
      return;
    }
    try {
      final res = await _api.get('/qr/project/join/${widget.token}');
      final data = res.data as Map<String, dynamic>?;
      final d = data?['data'] as Map<String, dynamic>?;
      if (d != null) {
        _projectId = d['project_id'] as int?;
        _projectTitle = d['project_title'] as String?;
      }
    } catch (e) {
      _error = 'Undangan tidak valid atau sudah kadaluarsa.';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _join() async {
    if (_projectId == null || widget.token == null) return;
    setState(() => _isJoining = true);
    try {
      await _api.post('/qr/project/join/${widget.token}');
      if (mounted) {
        Navigator.pop(context);
        AppToast.success('Berhasil bergabung ke ${_projectTitle ?? "proyek"}!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error('Gagal bergabung. Coba lagi nanti.', title: 'Error');
      }
    }
    setState(() => _isJoining = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);
    final projectTitle = _projectTitle;

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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Skeleton(width: 200, height: 32),
              )
            else ...[
              Icon(
                projectTitle != null
                    ? FluentIcons.checkmark_circle_24_filled
                    : FluentIcons.error_circle_24_regular,
                size: 48,
                color: projectTitle != null
                    ? AppColors.success500
                    : AppColors.danger500,
              ),
              const SizedBox(height: 16),
              Text(
                projectTitle ?? (_error ?? 'Proyek Tidak Ditemukan'),
                style: AppFonts.interStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: projectTitle != null && !_isJoining
                      ? _join
                      : () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: _isJoining
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(projectTitle != null ? 'Gabung' : 'Tutup'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
