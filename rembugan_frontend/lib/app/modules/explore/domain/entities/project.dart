class Project {
  final String title;
  final String description;
  final String category;
  final String faculty;
  final String postedBy;
  final String posterRole;
  final String avatarUrl;
  final String deadline;
  final String university;
  final String postedAgo;
  final int totalSlots;
  final int filledSlots;
  final List<String> skills;
  final List<String> memberAvatars;
  final List<String> memberNames;

  const Project({
    required this.title,
    required this.description,
    required this.category,
    required this.faculty,
    required this.postedBy,
    required this.posterRole,
    required this.avatarUrl,
    required this.deadline,
    required this.university,
    required this.postedAgo,
    required this.totalSlots,
    required this.filledSlots,
    required this.skills,
    required this.memberAvatars,
    required this.memberNames,
  });

  int get openSlots => totalSlots - filledSlots;
}
