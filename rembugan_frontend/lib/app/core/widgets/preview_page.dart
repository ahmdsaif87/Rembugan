import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../theme/theme.dart';
import '../utils/date_utils.dart';

class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({super.key, required this.url, this.filename});

  final String url;
  final String? filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(FluentIcons.more_horizontal_24_regular, color: Colors.white),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'download') _download(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'download', child: Text('Download')),
            ],
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.white54, size: 64),
          ),
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    try {
      await downloadFile(url, filename);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download berhasil')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal download file')),
        );
      }
    }
  }
}

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({super.key, required this.url, this.filename});

  final String url;
  final String? filename;

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final ext = widget.filename?.split('.').last ?? 'pdf';
      final file = File('${dir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.$ext');

      final dio = Dio();
      await dio.download(widget.url, file.path);

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: _totalPages > 0
            ? Text(
                '${_currentPage + 1} / $_totalPages',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )
            : null,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(FluentIcons.more_horizontal_24_regular, color: Colors.white),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'download') _download(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'download', child: Text('Download')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_error != null || _localPath == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal membuka PDF',
              style: AppFonts.satoshiStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _download(context),
              child: const Text('Download', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => openFile(widget.url, widget.filename),
              child: const Text('Buka di Aplikasi Lain', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }
    return PDFView(
      filePath: _localPath!,
      autoSpacing: true,
      enableSwipe: true,
      pageSnap: true,
      swipeHorizontal: false,
      onRender: (pages) {
        setState(() => _totalPages = pages ?? 0);
      },
      onViewCreated: (controller) {},
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onError: (error) {
        setState(() => _error = error);
      },
    );
  }

  Future<void> _download(BuildContext context) async {
    try {
      await downloadFile(widget.url, widget.filename);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download berhasil')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal download file')),
        );
      }
    }
  }
}