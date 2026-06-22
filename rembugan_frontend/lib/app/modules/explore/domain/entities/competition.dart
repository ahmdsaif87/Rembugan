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
<<<<<<< Updated upstream
=======
  final String posterUrl;
  final int matchScore;
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
=======
    this.posterUrl = '',
    this.matchScore = 0,
>>>>>>> Stashed changes
  });

  int? get daysLeft {
    try {
      final parts = deadline.split(' ');
      if (parts.length < 3) return null;
      final day = int.parse(parts[0]);
      final monthStr = parts[1].toLowerCase();
      final year = int.parse(parts[2]);

      const months = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'mei': 5,
        'jun': 6,
        'jul': 7,
        'agu': 8,
        'sep': 9,
        'okt': 10,
        'nov': 11,
        'des': 12,
        'may': 5,
        'aug': 8,
        'oct': 10,
        'dec': 12,
      };

      final month = months[monthStr.substring(0, 3)] ?? 1;
      final deadlineDate = DateTime(year, month, day);
      final now = DateTime(2026, 6, 3); // Simulated base date: June 3, 2026
      return deadlineDate.difference(now).inDays;
    } catch (e) {
      return null;
    }
  }
}
