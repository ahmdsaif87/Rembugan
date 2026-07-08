class Project {
  final int projectId;
  final String title;
  final String description;
  final String postedBy;
  final String posterRole;
  final String avatarUrl;
  final String posterId;
  final String deadline;
  final String university;
  final String postedAgo;
  final int totalSlots;
  final int filledSlots;
  final int matchScore;
  final bool hasApplied;
  final bool isMember;
  final bool isOwner;
  final List<String> skills;
  final List<String> memberAvatars;
  final List<String> memberNames;

  const Project({
    this.projectId = 0,
    required this.title,
    required this.description,
    required this.postedBy,
    required this.posterRole,
    required this.avatarUrl,
    this.posterId = '',
    required this.deadline,
    required this.university,
    required this.postedAgo,
    required this.totalSlots,
    required this.filledSlots,
    this.matchScore = 0,
    this.hasApplied = false,
    this.isMember = false,
    this.isOwner = false,
    required this.skills,
    required this.memberAvatars,
    required this.memberNames,
  });

  int get openSlots => totalSlots - filledSlots;
}
