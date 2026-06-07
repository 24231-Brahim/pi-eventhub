import 'package:eventhub/features/tickets/domain/entities/ticket.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.bookingId,
    super.eventTitle,
    super.eventDate,
    super.eventLocation,
    required super.qrCode,
    super.status,
    super.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String,
      eventTitle: json['eventTitle'] as String?,
      eventDate: json['eventDate'] as String?,
      eventLocation: json['eventLocation'] as String?,
      qrCode: json['qrCode'] as String,
      status: _parseStatus(json['status'] as String? ?? 'active'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'bookingId': bookingId,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventLocation': eventLocation,
      'qrCode': qrCode,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static TicketStatus _parseStatus(String value) {
    return TicketStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TicketStatus.active,
    );
  }
}
