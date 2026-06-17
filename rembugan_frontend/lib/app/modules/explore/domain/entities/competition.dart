import 'color_seed.dart';

class Competition {
  final String title;
  final String caption;
  final String category;
  final String organizer;
  final String deadline;
  final String badge;
  final ColorSeed color;
  final String registrationLink;
  final String campusTag;
  final String posterUrl;

  const Competition({
    required this.title,
    required this.caption,
    required this.category,
    required this.organizer,
    required this.deadline,
    required this.badge,
    required this.color,
    required this.registrationLink,
    required this.campusTag,
    this.posterUrl = '',
  });

  int? get daysLeft {
    final endDate = parseEndDate(deadline);
    if (endDate == null) return null;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  static DateTime? parseEndDate(String ddl) {
    try {
      final parts = ddl.split(' ');
      if (parts.length < 3) return null;

      String dayStr, monthStr, yearStr;
      final dashIdx = parts.indexOf('-');
      if (dashIdx >= 0 && dashIdx + 3 < parts.length) {
        dayStr = parts[dashIdx + 1];
        monthStr = parts[dashIdx + 2];
        yearStr = parts[dashIdx + 3];
      } else {
        dayStr = parts[0];
        monthStr = parts[1];
        yearStr = parts[2];
      }

      final day = int.parse(dayStr.replaceAll(RegExp(r'[^\d]'), ''));
      final year = int.parse(yearStr.replaceAll(RegExp(r'[^\d]'), ''));
      final month = _monthNumber(monthStr);

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  static int _monthNumber(String m) {
    const months = {
      'januari': 1, 'februari': 2, 'maret': 3, 'april': 4,
      'mei': 5, 'juni': 6, 'juli': 7, 'agustus': 8,
      'september': 9, 'oktober': 10, 'november': 11, 'desember': 12,
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
      'agu': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12,
    };
    final key = m.substring(0, 3).toLowerCase();
    return months[key] ?? 1;
  }
}
