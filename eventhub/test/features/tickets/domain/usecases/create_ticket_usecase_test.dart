import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/tickets/domain/usecases/create_ticket_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTicketRepository mockRepository;
  late CreateTicketUseCase useCase;

  setUp(() {
    mockRepository = MockTicketRepository();
    useCase = CreateTicketUseCase(repository: mockRepository);
  });

  group('CreateTicketUseCase', () {
    test('should create ticket successfully', () async {
      when(() => mockRepository.createTicket(
            eventId: any(named: 'eventId'),
            bookingId: any(named: 'bookingId'),
            qrCode: any(named: 'qrCode'),
          )).thenAnswer((_) async => const Right(tTicket));

      final result = await useCase(
        eventId: '1',
        bookingId: '1',
        qrCode: 'qr-test-123',
      );

      expect(result, const Right(tTicket));
      verify(() => mockRepository.createTicket(
            eventId: '1',
            bookingId: '1',
            qrCode: 'qr-test-123',
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.createTicket(
            eventId: any(named: 'eventId'),
            bookingId: any(named: 'bookingId'),
            qrCode: any(named: 'qrCode'),
          )).thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(
        eventId: '1',
        bookingId: '1',
        qrCode: 'qr-test-123',
      );

      expect(result, const Left(tFailure));
    });
  });
}
