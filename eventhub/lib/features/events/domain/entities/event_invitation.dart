import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined }

class EventInvitation extends Equatable {
  final String id;
  final String eventId;
  final String email;
  final String name;
  final InvitationStatus status;
  final DateTime? createdAt;

  const EventInvitation({
    required this.id,
    required this.eventId,
    required this.email,
    this.name = '',
    this.status = InvitationStatus.pending,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, eventId, email, name, status, createdAt];
}
