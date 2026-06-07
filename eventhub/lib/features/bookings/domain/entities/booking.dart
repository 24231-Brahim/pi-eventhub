import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, refunded }

class Booking extends Equatable {
  final String id;
  final String eventId;
  final String userId;
  final String? eventTitle;
  final String? eventImageUrl;
  final DateTime? eventDate;
  final String? eventLocation;
  final int quantity;
  final double totalAmount;
  final BookingStatus status;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.eventId,
    required this.userId,
    this.eventTitle,
    this.eventImageUrl,
    this.eventDate,
    this.eventLocation,
    this.quantity = 1,
    this.totalAmount = 0,
    this.status = BookingStatus.pending,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, eventId, userId, eventTitle, eventImageUrl, eventDate,
        eventLocation, quantity, totalAmount, status, createdAt,
      ];
}
