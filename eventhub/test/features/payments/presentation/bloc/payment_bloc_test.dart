import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCreatePaymentIntentUseCase mockCreatePaymentIntentUseCase;
  late MockConfirmPaymentUseCase mockConfirmPaymentUseCase;

  setUp(() {
    mockCreatePaymentIntentUseCase = MockCreatePaymentIntentUseCase();
    mockConfirmPaymentUseCase = MockConfirmPaymentUseCase();
  });

  PaymentBloc createBloc() => PaymentBloc(
        createPaymentIntentUseCase: mockCreatePaymentIntentUseCase,
        confirmPaymentUseCase: mockConfirmPaymentUseCase,
      );

  group('PaymentBloc', () {
    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentIntentCreated] when createPaymentIntent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreatePaymentIntentUseCase.call(50.0, 'TND', '1'))
            .thenAnswer((_) async => const Right('client-secret-1'));
        bloc.add(const CreatePaymentIntentEvent(
            amount: 50.0, bookingId: '1'));
      },
      expect: () =>
          [isA<PaymentLoading>(), isA<PaymentIntentCreated>()],
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentError] when createPaymentIntent fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreatePaymentIntentUseCase.call(50.0, 'TND', '1'))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const CreatePaymentIntentEvent(
            amount: 50.0, bookingId: '1'));
      },
      expect: () => [isA<PaymentLoading>(), isA<PaymentError>()],
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentConfirmed] when confirmPayment succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockConfirmPaymentUseCase.call('pi-1', 'booking-1'))
            .thenAnswer((_) async => const Right(tPayment));
        bloc.add(const ConfirmPaymentEvent(
            paymentIntentId: 'pi-1', bookingId: 'booking-1'));
      },
      expect: () => [isA<PaymentLoading>(), isA<PaymentConfirmed>()],
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [PaymentLoading, PaymentError] when confirmPayment fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockConfirmPaymentUseCase.call('pi-1', 'booking-1'))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const ConfirmPaymentEvent(
            paymentIntentId: 'pi-1', bookingId: 'booking-1'));
      },
      expect: () => [isA<PaymentLoading>(), isA<PaymentError>()],
    );
  });
}
