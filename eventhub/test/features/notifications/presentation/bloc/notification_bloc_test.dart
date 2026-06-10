import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkNotificationAsReadUseCase mockMarkNotificationAsReadUseCase;

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkNotificationAsReadUseCase = MockMarkNotificationAsReadUseCase();
  });

  NotificationBloc createBloc() => NotificationBloc(
        getNotificationsUseCase: mockGetNotificationsUseCase,
        markNotificationAsReadUseCase: mockMarkNotificationAsReadUseCase,
      );

  group('NotificationBloc', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationsLoaded] when getNotifications succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => const Right([tNotification]));
        bloc.add(const GetNotificationsEvent());
      },
      expect: () =>
          [isA<NotificationLoading>(), isA<NotificationsLoaded>()],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when getNotifications fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const GetNotificationsEvent());
      },
      expect: () =>
          [isA<NotificationLoading>(), isA<NotificationError>()],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits empty list when no notifications exist',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const GetNotificationsEvent());
      },
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationsLoaded>(),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'marks notification as read and updates state',
      build: createBloc,
      seed: () => NotificationsLoaded(notifications: const [tNotification]),
      act: (bloc) {
        when(() => mockMarkNotificationAsReadUseCase.call('1'))
            .thenAnswer((_) async => const Right(null));
        bloc.add(const MarkNotificationAsReadEvent(id: '1'));
      },
      expect: () => [
        isA<NotificationsLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as NotificationsLoaded;
        expect(state.notifications.first.isRead, isTrue);
      },
    );
  });
}
