import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/payments/domain/usecases/create_payment_intent_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPaymentRepository mockRepository;
  late CreatePaymentIntentUseCase useCase;

  setUp(() {
    mockRepository = MockPaymentRepository();
    useCase = CreatePaymentIntentUseCase(repository: mockRepository);
  });

  group('CreatePaymentIntentUseCase', () {
    test('should return payment intent id on success', () async {
      when(() => mockRepository.createPaymentIntent(50.0, 'TND', '1'))
          .thenAnswer((_) async => const Right('payment-id-1'));

      final result = await useCase(50.0, 'TND', '1');

      expect(result, const Right('payment-id-1'));
      verify(() => mockRepository.createPaymentIntent(50.0, 'TND', '1'))
          .called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.createPaymentIntent(50.0, 'TND', '1'))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(50.0, 'TND', '1');

      expect(result, const Left(tFailure));
    });
  });
}
