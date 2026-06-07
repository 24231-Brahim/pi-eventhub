part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentIntentEvent extends PaymentEvent {
  final double amount;
  final String currency;
  const CreatePaymentIntentEvent({
    required this.amount,
    this.currency = 'TND',
  });

  @override
  List<Object?> get props => [amount, currency];
}

class ConfirmPaymentEvent extends PaymentEvent {
  final String paymentIntentId;
  const ConfirmPaymentEvent({required this.paymentIntentId});

  @override
  List<Object?> get props => [paymentIntentId];
}
