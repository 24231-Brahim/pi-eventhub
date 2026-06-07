import 'package:eventhub/features/auth/domain/entities/user.dart';
import 'package:eventhub/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    super.role,
    super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: parseRole(json['role'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
