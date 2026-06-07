import 'package:eventhub/features/payments/domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    super.currency,
    super.status,
    super.stripePaymentIntentId,
    super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TND',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'stripePaymentIntentId': stripePaymentIntentId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static PaymentStatus _parseStatus(String value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
