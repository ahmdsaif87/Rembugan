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
    final dt = DateTime.parse(iso);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit';
    if (diff.inHours < 24) return '${diff.inHours} jam';
    if (diff.inDays < 7) return '${diff.inDays} hari';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu';
    return formatDateShort(iso);
  } catch (_) {
    return '';
  }
}

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _pad(int n) => n.toString().padLeft(2, '0');
