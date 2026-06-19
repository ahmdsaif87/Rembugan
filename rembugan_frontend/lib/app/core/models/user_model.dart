class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String handle;
  final String? interest;
  final bool emailVerified;
  final bool isOnboarded;
  final int connectionCount;
  final int projectCount;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.handle,
    this.interest,
    this.emailVerified = false,
    this.isOnboarded = false,
    this.connectionCount = 0,
    this.projectCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String,
      handle: json['handle'] as String? ?? '',
      interest: json['interest'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      isOnboarded: json['is_onboarded'] as bool? ?? false,
      connectionCount: json['connection_count'] as int? ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'handle': handle,
      'interest': interest,
      'email_verified': emailVerified,
      'is_onboarded': isOnboarded,
      'connection_count': connectionCount,
      'project_count': projectCount,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? handle,
    String? interest,
    bool? emailVerified,
    bool? isOnboarded,
    int? connectionCount,
    int? projectCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      handle: handle ?? this.handle,
      interest: interest ?? this.interest,
      emailVerified: emailVerified ?? this.emailVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      connectionCount: connectionCount ?? this.connectionCount,
      projectCount: projectCount ?? this.projectCount,
    );
  }
}
