class UserModel {
  final String id;
  final String nim;
  final String fullName;
  final String handle;
  final String? email;
  final bool emailVerified;
  final bool isOnboarded;

  const UserModel({
    required this.id,
    required this.nim,
    required this.fullName,
    required this.handle,
    this.email,
    this.emailVerified = false,
    this.isOnboarded = false,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      fullName: fullName ?? this.fullName,
      handle: handle ?? this.handle,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
