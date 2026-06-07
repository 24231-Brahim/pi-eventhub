import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/payments/domain/entities/payment.dart';
import 'package:eventhub/features/payments/domain/usecases/create_payment_intent_usecase.dart';
import 'package:eventhub/features/payments/domain/usecases/confirm_payment_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentIntentUseCase createPaymentIntentUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  PaymentBloc({
    required this.createPaymentIntentUseCase,
    required this.confirmPaymentUseCase,
  }) : super(PaymentInitial()) {
    on<CreatePaymentIntentEvent>(_onCreatePaymentIntent);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
  }

  Future<void> _onCreatePaymentIntent(
      CreatePaymentIntentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result =
        await createPaymentIntentUseCase.call(event.amount, event.currency);
    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (clientSecret) =>
          emit(PaymentIntentCreated(clientSecret: clientSecret)),
    );
  }

  Future<void> _onConfirmPayment(
      ConfirmPaymentEvent event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    final result = await confirmPaymentUseCase.call(event.paymentIntentId);
    result.fold(
      (failure) => emit(PaymentError(message: failure.message)),
      (payment) => emit(PaymentConfirmed(payment: payment)),
    );
  }
}
