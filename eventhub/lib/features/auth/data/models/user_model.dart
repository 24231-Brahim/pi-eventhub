import 'package:eventhub/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    super.role,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] == 'organizer'
          ? UserRole.organizer
          : UserRole.participant,
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
      role: profile['role'] == 'organizer'
          ? UserRole.organizer
          : UserRole.participant,
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
      'role': role == UserRole.organizer ? 'organizer' : 'participant',
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
