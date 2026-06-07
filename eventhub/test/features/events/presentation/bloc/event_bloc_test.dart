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

  setUp(() {
    mockGetEventsUseCase = MockGetEventsUseCase();
    mockGetEventByIdUseCase = MockGetEventByIdUseCase();
    mockCreateEventUseCase = MockCreateEventUseCase();
    mockUpdateEventUseCase = MockUpdateEventUseCase();
    mockDeleteEventUseCase = MockDeleteEventUseCase();
  });

  EventBloc createBloc() => EventBloc(
        getEventsUseCase: mockGetEventsUseCase,
        getEventByIdUseCase: mockGetEventByIdUseCase,
        createEventUseCase: mockCreateEventUseCase,
        updateEventUseCase: mockUpdateEventUseCase,
        deleteEventUseCase: mockDeleteEventUseCase,
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
  });
}
