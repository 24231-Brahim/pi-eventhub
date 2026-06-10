import 'package:eventhub/features/events/domain/entities/event_invitation.dart';

class EventInvitationModel extends EventInvitation {
  const EventInvitationModel({
    required super.id,
    required super.eventId,
    required super.email,
    super.name,
    super.status,
    super.createdAt,
  });

  factory EventInvitationModel.fromJson(Map<String, dynamic> json) {
    return EventInvitationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'email': email,
      'name': name,
      'status': status.name,
    };
  }

  static InvitationStatus _parseStatus(String value) {
    return InvitationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}
