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
      role: json['role'] == 'organizer'
          ? UserRole.organizer
          : UserRole.participant,
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
      'role': role == UserRole.organizer ? 'organizer' : 'participant',
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
