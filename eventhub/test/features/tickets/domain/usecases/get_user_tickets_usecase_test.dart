import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/features/tickets/domain/usecases/get_user_tickets_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTicketRepository mockRepository;
  late GetUserTicketsUseCase useCase;

  setUp(() {
    mockRepository = MockTicketRepository();
    useCase = GetUserTicketsUseCase(repository: mockRepository);
  });

  group('GetUserTicketsUseCase', () {
    test('should return list of tickets', () async {
      when(() => mockRepository.getUserTickets())
          .thenAnswer((_) async => const Right([tTicket]));

      final result = await useCase();

      expect(result, const Right([tTicket]));
      verify(() => mockRepository.getUserTickets()).called(1);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.getUserTickets())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase();

      expect(result, const Left(tFailure));
    });
  });
}
