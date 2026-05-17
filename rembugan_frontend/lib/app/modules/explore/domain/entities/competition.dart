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
  });
}
