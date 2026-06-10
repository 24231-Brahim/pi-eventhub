import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/tickets/data/datasources/ticket_supabase_datasource.dart';
import 'package:eventhub/features/tickets/data/repositories/ticket_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockTicketSupabaseDataSource extends Mock
    implements TicketSupabaseDataSource {}

void main() {
  late MockTicketSupabaseDataSource mockDataSource;
  late TicketRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockTicketSupabaseDataSource();
    repository = TicketRepositoryImpl(
      dataSource: mockDataSource,
      supabase: SupabaseMock(),
    );
  });

  group('TicketRepositoryImpl', () {
    group('getUserTickets', () {
      test('should return list of tickets on success', () async {
        when(() => mockDataSource.getUserTickets(any()))
            .thenAnswer((_) async => [
                  {
                    'id': '1',
                    'eventId': '1',
                    'userId': '1',
                    'bookingId': '1',
                    'eventTitle': 'Test Event',
                    'eventDate': '2026-12-25',
                    'eventLocation': 'Test Location',
                    'qrCode': 'qr-test-123',
                    'status': 'active',
                    'createdAt': '2026-06-08T00:00:00.000',
                  }
                ]);

        final result = await repository.getUserTickets();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (tickets) {
            expect(tickets.length, 1);
            expect(tickets.first.qrCode, 'qr-test-123');
          },
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.getUserTickets(any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getUserTickets();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('validateTicket', () {
      test('should return ticket on successful validation', () async {
        when(() => mockDataSource.validateTicket('qr-test-123'))
            .thenAnswer((_) async => {
                  'id': '1',
                  'eventId': '1',
                  'userId': '1',
                  'bookingId': '1',
                  'eventTitle': 'Test Event',
                  'eventDate': '2026-12-25',
                  'eventLocation': 'Test Location',
                  'qrCode': 'qr-test-123',
                  'status': 'used',
                  'createdAt': '2026-06-08T00:00:00.000',
                });

        final result = await repository.validateTicket('qr-test-123');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (ticket) => expect(ticket.status.name, 'used'),
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.validateTicket('qr-test-123'))
            .thenThrow(Exception('Validation error'));

        final result = await repository.validateTicket('qr-test-123');

        expect(result.isLeft(), true);
      });
    });

    group('createTicket', () {
      test('should create and return ticket on success', () async {
        when(() => mockDataSource.createTicket(
              eventId: any(named: 'eventId'),
              userId: any(named: 'userId'),
              bookingId: any(named: 'bookingId'),
              qrCode: any(named: 'qrCode'),
            )).thenAnswer((_) async => {
              'id': '2',
              'eventId': '1',
              'userId': '1',
              'bookingId': '1',
              'eventTitle': 'Test Event',
              'eventDate': '2026-12-25',
              'eventLocation': 'Test Location',
              'qrCode': 'qr-new-456',
              'status': 'active',
              'createdAt': '2026-06-08T00:00:00.000',
            });

        final result = await repository.createTicket(
          eventId: '1',
          bookingId: '1',
          qrCode: 'qr-new-456',
        );

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (ticket) => expect(ticket.qrCode, 'qr-new-456'),
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.createTicket(
              eventId: any(named: 'eventId'),
              userId: any(named: 'userId'),
              bookingId: any(named: 'bookingId'),
              qrCode: any(named: 'qrCode'),
            )).thenThrow(Exception('Creation error'));

        final result = await repository.createTicket(
          eventId: '1',
          bookingId: '1',
          qrCode: 'qr-new-456',
        );

        expect(result.isLeft(), true);
      });
    });
  });
}
