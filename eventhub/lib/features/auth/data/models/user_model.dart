import 'package:eventhub/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    super.role,
    super.isActive,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: parseRole(json['role'] as String?),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  factory UserModel.fromSupabase(Map<String, dynamic> profile) {
    return UserModel(
      id: profile['id'] as String,
      email: profile['email'] as String? ?? '',
      name: profile['name'] as String? ?? '',
      phone: profile['phone'] as String?,
      photoUrl: profile['photo_url'] as String?,
      role: parseRole(profile['role'] as String?),
      isActive: profile['is_active'] as bool? ?? true,
      createdAt: profile['created_at'] != null
          ? DateTime.parse(profile['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': _roleToString(role),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static UserRole parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'organizer':
        return UserRole.organizer;
      default:
        return UserRole.participant;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.organizer:
        return 'organizer';
      case UserRole.participant:
        return 'participant';
    }
  }
}
