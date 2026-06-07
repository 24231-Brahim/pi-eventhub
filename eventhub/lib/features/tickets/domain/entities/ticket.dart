import 'package:equatable/equatable.dart';

enum TicketStatus { active, used, cancelled }

class Ticket extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String bookingId;
  final String? eventTitle;
  final String? eventDate;
  final String? eventLocation;
  final String qrCode;
  final TicketStatus status;
  final DateTime? createdAt;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.bookingId,
    this.eventTitle,
    this.eventDate,
    this.eventLocation,
    required this.qrCode,
    this.status = TicketStatus.active,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, eventId, userId, bookingId, eventTitle, eventDate,
        eventLocation, qrCode, status, createdAt,
      ];
}
