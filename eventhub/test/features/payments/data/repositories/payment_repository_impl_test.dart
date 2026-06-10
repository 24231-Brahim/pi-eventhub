import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/payments/data/datasources/payment_supabase_datasource.dart';
import 'package:eventhub/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockPaymentSupabaseDataSource extends Mock
    implements PaymentSupabaseDataSource {}

void main() {
  late MockPaymentSupabaseDataSource mockDataSource;
  late PaymentRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockPaymentSupabaseDataSource();
    repository = PaymentRepositoryImpl(
      dataSource: mockDataSource,
      supabase: SupabaseMock(),
    );
  });

  group('PaymentRepositoryImpl', () {
    group('createPaymentIntent', () {
      test('should return payment id on success', () async {
        when(() => mockDataSource.createPaymentIntent(50.0, 'TND', '1'))
            .thenAnswer((_) async => {
                  'id': 'payment-1',
                  'bookingId': '1',
                  'amount': 50.0,
                  'currency': 'TND',
                  'status': 'pending',
                  'stripePaymentIntentId': null,
                  'createdAt': '2026-06-08T00:00:00.000',
                });

        final result = await repository.createPaymentIntent(50.0, 'TND', '1');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (id) => expect(id, 'payment-1'),
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.createPaymentIntent(50.0, 'TND', '1'))
            .thenThrow(Exception('API error'));

        final result = await repository.createPaymentIntent(50.0, 'TND', '1');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('confirmPayment', () {
      test('should return confirmed payment on success', () async {
        when(() => mockDataSource.confirmPayment('pi-1', 'booking-1'))
            .thenAnswer((_) async => {
                  'id': 'payment-1',
                  'bookingId': '1',
                  'amount': 50.0,
                  'currency': 'TND',
                  'status': 'completed',
                  'stripePaymentIntentId': 'pi-1',
                  'createdAt': '2026-06-08T00:00:00.000',
                });

        final result =
            await repository.confirmPayment('pi-1', 'booking-1');

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected Right'),
          (payment) {
            expect(payment.status.name, 'completed');
            expect(payment.stripePaymentIntentId, 'pi-1');
          },
        );
      });

      test('should return ServerFailure on exception', () async {
        when(() => mockDataSource.confirmPayment('pi-1', 'booking-1'))
            .thenThrow(Exception('Confirm error'));

        final result =
            await repository.confirmPayment('pi-1', 'booking-1');

        expect(result.isLeft(), true);
      });
    });
  });
}
