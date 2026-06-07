import 'package:eventhub/features/bookings/domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.eventId,
    required super.userId,
    super.eventTitle,
    super.eventImageUrl,
    super.eventDate,
    super.eventLocation,
    super.quantity,
    super.totalAmount,
    super.status,
    super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      eventTitle: json['eventTitle'] as String?,
      eventImageUrl: json['eventImageUrl'] as String?,
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'] as String)
          : null,
      eventLocation: json['eventLocation'] as String?,
      quantity: (json['quantity'] as int?) ?? 1,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
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
      'userId': userId,
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'eventDate': eventDate?.toIso8601String(),
      'eventLocation': eventLocation,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static BookingStatus _parseStatus(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => BookingStatus.pending,
    );
  }
}
