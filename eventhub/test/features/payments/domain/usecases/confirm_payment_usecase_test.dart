import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/payments/domain/usecases/confirm_payment_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockPaymentRepository mockRepository;
  late ConfirmPaymentUseCase useCase;

  setUp(() {
    mockRepository = MockPaymentRepository();
    useCase = ConfirmPaymentUseCase(repository: mockRepository);
  });

  group('ConfirmPaymentUseCase', () {
    test('should confirm payment successfully', () async {
      when(() => mockRepository.confirmPayment('pi-1', 'booking-1'))
          .thenAnswer((_) async => const Right(tPayment));

      final result = await useCase('pi-1', 'booking-1');

      expect(result, const Right(tPayment));
      verify(() => mockRepository.confirmPayment('pi-1', 'booking-1'))
          .called(1);
    });

    test('should return failure when confirmation fails', () async {
      when(() => mockRepository.confirmPayment('pi-1', 'booking-1'))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase('pi-1', 'booking-1');

      expect(result, const Left(tFailure));
    });
  });
}
