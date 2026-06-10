import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/tickets/domain/usecases/validate_ticket_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTicketRepository mockRepository;
  late ValidateTicketUseCase useCase;

  setUp(() {
    mockRepository = MockTicketRepository();
    useCase = ValidateTicketUseCase(repository: mockRepository);
  });

  group('ValidateTicketUseCase', () {
    test('should validate ticket successfully', () async {
      when(() => mockRepository.validateTicket('qr-test-123'))
          .thenAnswer((_) async => const Right(tTicket));

      final result = await useCase('qr-test-123');

      expect(result, const Right(tTicket));
      verify(() => mockRepository.validateTicket('qr-test-123')).called(1);
    });

    test('should return failure when validation fails', () async {
      when(() => mockRepository.validateTicket('qr-test-123'))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase('qr-test-123');

      expect(result, const Left(tFailure));
    });
  });
}
