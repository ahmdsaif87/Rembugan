import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso);
    return '${_pad(dt.day)} ${_months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return iso;
  }
}

String formatDateShort(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso);
    return '${_pad(dt.day)} ${_monthsShort[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return iso;
  }
}

String formatDateRange(String? startIso, String? endIso) {
  final start = formatDateShort(startIso);
  final end = endIso != null && endIso.isNotEmpty ? formatDateShort(endIso) : 'Sekarang';
  if (start.isEmpty) return end;
  return '$start - $end';
}

String relativeTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) {
      if (now.difference(dt).inMinutes < 1) return 'Baru saja';
      return '${_pad(dt.hour)}.${_pad(dt.minute)}';
    }

    if (msgDate == yesterday) return 'Kemarin';

    if (today.difference(msgDate).inDays < 7) return _dayNames[dt.weekday];

    if (dt.year == now.year) return '${dt.day} ${_monthsShort[dt.month - 1]}';
    return '${dt.day} ${_monthsShort[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return '';
  }
}

String formatTimeOnly(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return '${_pad(dt.hour)}.${_pad(dt.minute)}';
  } catch (_) {
    return '';
  }
}

String dateSeparator(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'Hari Ini';
    if (msgDate == yesterday) return 'Kemarin';
    return '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';
  } catch (_) {
    return '';
  }
}

bool isImageUrl(String url) {
  final lower = url.toLowerCase();
  final ext = lower.split('?')[0].split('.').last;
  if (ext == 'pdf') return false;
  if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(ext)) return true;
  if (lower.contains('/image/upload/')) return true;
  return false;
}

Future<void> openFile(String url, String? filename) async {
  String downloadUrl = url;
  if (url.contains('res.cloudinary.com')) {
    if (url.contains('/raw/upload/')) {
      downloadUrl = url.replaceAll('/raw/upload/', '/raw/upload/fl_attachment/');
    } else if (url.contains('/video/upload/')) {
      downloadUrl = url.replaceAll('/video/upload/', '/video/upload/fl_attachment/');
    }
  }
  final uri = Uri.parse(downloadUrl);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

const _dayNames = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _pad(int n) => n.toString().padLeft(2, '0');

String formatBytes(int? bytes) {
  if (bytes == null || bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

Future<String> downloadFile(String url, String? filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final name = filename ?? url.split('/').last;
  final savePath = '${dir.path}/$name';

  try {
    final dio = Dio();
    await dio.download(url, savePath);
    return savePath;
  } catch (e) {
    // fallback: buka di browser
    String downloadUrl = url;
    if (url.contains('res.cloudinary.com')) {
      if (url.contains('/image/upload/')) {
        downloadUrl = url.replaceAll('/image/upload/', '/image/upload/fl_attachment/');
      } else if (url.contains('/raw/upload/')) {
        downloadUrl = url.replaceAll('/raw/upload/', '/raw/upload/fl_attachment/');
      } else if (url.contains('/video/upload/')) {
        downloadUrl = url.replaceAll('/video/upload/', '/video/upload/fl_attachment/');
      }
    }
    final uri = Uri.parse(downloadUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return name;
  }
}
