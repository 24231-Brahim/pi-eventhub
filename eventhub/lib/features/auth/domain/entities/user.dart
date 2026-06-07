import 'package:equatable/equatable.dart';

enum UserRole { admin, organizer, participant }

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    this.role = UserRole.participant,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, phone, photoUrl, role, createdAt];
}
