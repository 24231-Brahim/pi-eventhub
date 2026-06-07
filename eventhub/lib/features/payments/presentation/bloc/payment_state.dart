part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentIntentCreated extends PaymentState {
  final String clientSecret;
  const PaymentIntentCreated({required this.clientSecret});

  @override
  List<Object?> get props => [clientSecret];
}

class PaymentConfirmed extends PaymentState {
  final Payment payment;
  const PaymentConfirmed({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}
