import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetUserTicketsUseCase mockGetUserTicketsUseCase;
  late MockValidateTicketUseCase mockValidateTicketUseCase;

  setUp(() {
    mockGetUserTicketsUseCase = MockGetUserTicketsUseCase();
    mockValidateTicketUseCase = MockValidateTicketUseCase();
  });

  TicketBloc createBloc() => TicketBloc(
        getUserTicketsUseCase: mockGetUserTicketsUseCase,
        validateTicketUseCase: mockValidateTicketUseCase,
      );

  group('TicketBloc', () {
    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, UserTicketsLoaded] when getUserTickets succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetUserTicketsUseCase.call())
            .thenAnswer((_) async => const Right([tTicket]));
        bloc.add(const GetUserTicketsEvent());
      },
      expect: () => [isA<TicketLoading>(), isA<UserTicketsLoaded>()],
    );

    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, TicketError] when getUserTickets fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetUserTicketsUseCase.call())
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const GetUserTicketsEvent());
      },
      expect: () => [isA<TicketLoading>(), isA<TicketError>()],
    );

    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, TicketValidated] when validateTicket succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockValidateTicketUseCase.call('qr-test-123'))
            .thenAnswer((_) async => const Right(tTicket));
        bloc.add(const ValidateTicketEvent(qrData: 'qr-test-123'));
      },
      expect: () => [isA<TicketLoading>(), isA<TicketValidated>()],
    );

    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, TicketError] when validateTicket fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockValidateTicketUseCase.call('qr-test-123'))
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const ValidateTicketEvent(qrData: 'qr-test-123'));
      },
      expect: () => [isA<TicketLoading>(), isA<TicketError>()],
    );
  });
}
