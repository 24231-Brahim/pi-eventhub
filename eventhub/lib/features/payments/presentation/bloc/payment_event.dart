part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentIntentEvent extends PaymentEvent {
  final double amount;
  final String currency;
  final String bookingId;
  const CreatePaymentIntentEvent({
    required this.amount,
    required this.bookingId,
    this.currency = 'TND',
  });

  @override
  List<Object?> get props => [amount, currency, bookingId];
}

class ConfirmPaymentEvent extends PaymentEvent {
  final String paymentIntentId;
  final String bookingId;
  const ConfirmPaymentEvent({
    required this.paymentIntentId,
    required this.bookingId,
  });

  @override
  List<Object?> get props => [paymentIntentId, bookingId];
}
