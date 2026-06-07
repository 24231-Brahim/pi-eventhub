import 'package:equatable/equatable.dart';
import 'package:eventhub/features/auth/domain/entities/user.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    this.role = UserRole.participant,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, email, name, phone, photoUrl, role, createdAt];
}
