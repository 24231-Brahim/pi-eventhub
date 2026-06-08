import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingConfirmation,
  paymentConfirmed,
  eventCancelled,
  eventReminder,
  general,
}

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? data;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = NotificationType.general,
    this.data,
    this.isRead = false,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, title, body, type, data, isRead, createdAt];
}
