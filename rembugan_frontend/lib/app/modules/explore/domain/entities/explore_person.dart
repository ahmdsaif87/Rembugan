class ExplorePerson {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> tags;
  final String matchLabel;
  final int matchScore;
  final String matchType;

  const ExplorePerson({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.tags,
    required this.matchLabel,
    this.matchScore = 0,
    this.matchType = '',
  });
}
