class UserModel {
  final String id;
  final String nim;
  final String fullName;
  final String handle;
  final String? email;
  final bool emailVerified;
  final bool isOnboarded;
<<<<<<< Updated upstream
=======
  final int connectionCount;
  final int projectCount;
  final String? nim;
  final String? faculty;
  final String? major;
>>>>>>> Stashed changes

  const UserModel({
    required this.id,
    required this.nim,
    required this.fullName,
    required this.handle,
    this.email,
    this.emailVerified = false,
    this.isOnboarded = false,
<<<<<<< Updated upstream
=======
    this.connectionCount = 0,
    this.projectCount = 0,
    this.nim,
    this.faculty,
    this.major,
>>>>>>> Stashed changes
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nim: json['nim'] as String,
      fullName: json['full_name'] as String,
      handle: json['handle'] as String? ?? '',
      email: json['email'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      isOnboarded: json['is_onboarded'] as bool? ?? false,
<<<<<<< Updated upstream
=======
      connectionCount: json['connection_count'] as int? ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
      nim: json['nim'] as String?,
      faculty: json['faculty'] as String?,
      major: json['major'] as String?,
>>>>>>> Stashed changes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'full_name': fullName,
      'handle': handle,
      'email': email,
      'email_verified': emailVerified,
      'is_onboarded': isOnboarded,
<<<<<<< Updated upstream
=======
      'connection_count': connectionCount,
      'project_count': projectCount,
      'nim': nim,
      'faculty': faculty,
      'major': major,
>>>>>>> Stashed changes
    };
  }

  UserModel copyWith({
    String? id,
    String? nim,
    String? fullName,
    String? handle,
    String? email,
    bool? emailVerified,
    bool? isOnboarded,
<<<<<<< Updated upstream
=======
    int? connectionCount,
    int? projectCount,
    String? nim,
    String? faculty,
    String? major,
>>>>>>> Stashed changes
  }) {
    return UserModel(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      fullName: fullName ?? this.fullName,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
<<<<<<< Updated upstream
=======
      connectionCount: connectionCount ?? this.connectionCount,
      projectCount: projectCount ?? this.projectCount,
      nim: nim ?? this.nim,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
>>>>>>> Stashed changes
    );
  }
}
