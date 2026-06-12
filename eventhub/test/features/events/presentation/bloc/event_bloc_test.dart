import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetEventsUseCase mockGetEventsUseCase;
  late MockGetEventByIdUseCase mockGetEventByIdUseCase;
  late MockCreateEventUseCase mockCreateEventUseCase;
  late MockUpdateEventUseCase mockUpdateEventUseCase;
  late MockDeleteEventUseCase mockDeleteEventUseCase;
  late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;
  late MockGetUserFavoriteIdsUseCase mockGetUserFavoriteIdsUseCase;
  late MockGetInvitationsUseCase mockGetInvitationsUseCase;
  late MockCreateInvitationUseCase mockCreateInvitationUseCase;
  late MockDeleteInvitationUseCase mockDeleteInvitationUseCase;

  setUp(() {
    mockGetEventsUseCase = MockGetEventsUseCase();
    mockGetEventByIdUseCase = MockGetEventByIdUseCase();
    mockCreateEventUseCase = MockCreateEventUseCase();
    mockUpdateEventUseCase = MockUpdateEventUseCase();
    mockDeleteEventUseCase = MockDeleteEventUseCase();
    mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
    mockGetUserFavoriteIdsUseCase = MockGetUserFavoriteIdsUseCase();
    mockGetInvitationsUseCase = MockGetInvitationsUseCase();
    mockCreateInvitationUseCase = MockCreateInvitationUseCase();
    mockDeleteInvitationUseCase = MockDeleteInvitationUseCase();
  });

  EventBloc createBloc() => EventBloc(
        getEventsUseCase: mockGetEventsUseCase,
        getEventByIdUseCase: mockGetEventByIdUseCase,
        createEventUseCase: mockCreateEventUseCase,
        updateEventUseCase: mockUpdateEventUseCase,
        deleteEventUseCase: mockDeleteEventUseCase,
        toggleFavoriteUseCase: mockToggleFavoriteUseCase,
        getUserFavoriteIdsUseCase: mockGetUserFavoriteIdsUseCase,
        getInvitationsUseCase: mockGetInvitationsUseCase,
        createInvitationUseCase: mockCreateInvitationUseCase,
        deleteInvitationUseCase: mockDeleteInvitationUseCase,
      );

  group('EventBloc', () {
    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventsLoaded] when getEvents succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetEventsUseCase.call(
              page: any(named: 'page'),
              size: any(named: 'size'),
            )).thenAnswer((_) async => Right([tEvent]));
        bloc.add(const GetEventsEvent());
      },
      expect: () => [isA<EventLoading>(), isA<EventsLoaded>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventError] when getEvents fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetEventsUseCase.call(
              page: any(named: 'page'),
              size: any(named: 'size'),
            )).thenAnswer((_) async => const Left(tFailure));
        bloc.add(const GetEventsEvent());
      },
      expect: () => [isA<EventLoading>(), isA<EventError>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventDetailLoaded] when getEventById succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetEventByIdUseCase.call('1'))
            .thenAnswer((_) async => Right(tEvent));
        bloc.add(const GetEventByIdEvent(id: '1'));
      },
      expect: () => [isA<EventLoading>(), isA<EventDetailLoaded>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventCreated] when createEvent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockCreateEventUseCase.call(tEvent))
            .thenAnswer((_) async => Right(tEvent));
        bloc.add(CreateEventEvent(event: tEvent));
      },
      expect: () => [isA<EventLoading>(), isA<EventCreated>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventDeleted] when deleteEvent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockDeleteEventUseCase.call('1'))
            .thenAnswer((_) async => const Right(null));
        bloc.add(const DeleteEventEvent(id: '1'));
      },
      expect: () => [isA<EventLoading>(), isA<EventDeleted>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [EventLoading, EventUpdated] when updateEvent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockUpdateEventUseCase.call(tEvent))
            .thenAnswer((_) async => Right(tEvent));
        bloc.add(UpdateEventEvent(event: tEvent));
      },
      expect: () => [isA<EventLoading>(), isA<EventUpdated>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [FavoriteToggled] when toggleFavorite succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockToggleFavoriteUseCase.call('1'))
            .thenAnswer((_) async => const Right(true));
        bloc.add(const ToggleFavoriteEvent(eventId: '1'));
      },
      expect: () => [isA<FavoriteToggled>()],
    );

    blocTest<EventBloc, EventState>(
      'emits [FavoriteIdsLoadedState] when getUserFavoriteIds succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetUserFavoriteIdsUseCase.call())
            .thenAnswer((_) async => const Right(['1', '2']));
        bloc.add(const GetUserFavoriteIdsEvent());
      },
      expect: () => [isA<FavoriteIdsLoadedState>()],
    );

    blocTest<EventBloc, EventState>(
      'emits EventsLoaded with hasReachedMax=true when fewer results than page size',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetEventsUseCase.call(
              page: any(named: 'page'),
              size: any(named: 'size'),
            )).thenAnswer((_) async => Right([tEvent]));
        bloc.add(const GetEventsEvent(size: 20));
      },
      expect: () => [isA<EventLoading>(), isA<EventsLoaded>()],
      verify: (bloc) {
        final state = bloc.state as EventsLoaded;
        expect(state.hasReachedMax, isTrue);
      },
    );

    blocTest<EventBloc, EventState>(
      'emits EventsLoaded with hasReachedMax=false when results equal page size',
      build: createBloc,
      act: (bloc) {
        final events = List.generate(20, (i) => tEvent);
        when(() => mockGetEventsUseCase.call(
              page: any(named: 'page'),
              size: any(named: 'size'),
            )).thenAnswer((_) async => Right(events));
        bloc.add(const GetEventsEvent(size: 20));
      },
      expect: () => [isA<EventLoading>(), isA<EventsLoaded>()],
      verify: (bloc) {
        final state = bloc.state as EventsLoaded;
        expect(state.hasReachedMax, isFalse);
      },
    );
  });
}
