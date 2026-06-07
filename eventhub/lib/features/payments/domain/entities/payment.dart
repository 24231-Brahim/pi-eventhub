import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, completed, failed, refunded }

class Payment extends Equatable {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? stripePaymentIntentId;
  final DateTime? createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    this.currency = 'TND',
    this.status = PaymentStatus.pending,
    this.stripePaymentIntentId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, bookingId, amount, currency, status,
        stripePaymentIntentId, createdAt,
      ];
}
