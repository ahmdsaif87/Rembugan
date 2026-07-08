import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../controllers/team_controller.dart';

class JoinWorkspaceSheet extends StatefulWidget {
  const JoinWorkspaceSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const JoinWorkspaceSheet(),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  State<JoinWorkspaceSheet> createState() => _JoinWorkspaceSheetState();
}

class _JoinWorkspaceSheetState extends State<JoinWorkspaceSheet> {
  final _tokenCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  String? _extractToken(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.isNotEmpty) {
      final segments = uri.pathSegments;
      final joinIdx = segments.indexOf('join');
      if (joinIdx != -1 && joinIdx < segments.length - 1) {
        return segments[joinIdx + 1];
      }
    }
    return trimmed;
  }

  Future<void> _submit() async {
    final token = _extractToken(_tokenCtrl.text);
    if (token == null || token.isEmpty) {
      AppToast.warning('Masukkan token undangan atau link yang valid.');
      return;
    }

    setState(() => _isSubmitting = true);

    final ctrl = Get.find<TeamController>();
    final ok = await ctrl.joinProject(token);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.pop(context);
        AppToast.success('Berhasil bergabung ke workspace!');
      } else {
        AppToast.error(
          'Token tidak valid atau sudah kadaluarsa.',
          title: 'Gagal',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppC.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              FluentIcons.link_24_regular,
              size: 40,
              color: AppColors.primary500,
            ),
            const SizedBox(height: 12),
            Text(
              'Gabung Workspace',
              style: AppFonts.interStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Masukkan token undangan atau link\nuntuk bergabung ke workspace.',
              textAlign: TextAlign.center,
              style: AppFonts.interStyle(
                fontSize: 13,
                height: 1.4,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _tokenCtrl,
              decoration: InputDecoration(
                hintText: 'Token undangan atau link...',
                hintStyle: AppFonts.interStyle(
                  fontSize: 14,
                  color: c.textTertiary,
                ),
                prefixIcon: Icon(
                  FluentIcons.key_24_regular,
                  size: 20,
                  color: c.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2,
                        ),
                      )
                    : const Text('Gabung'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
