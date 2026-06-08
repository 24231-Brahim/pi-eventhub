import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetDashboardStatsUseCase mockGetDashboardStats;
  late MockGetAllEventsUseCase mockGetAllEvents;
  late MockGetUsersUseCase mockGetUsers;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockGetDashboardStats = MockGetDashboardStatsUseCase();
    mockGetAllEvents = MockGetAllEventsUseCase();
    mockGetUsers = MockGetUsersUseCase();
    mockAdminRepository = MockAdminRepository();
  });

  AdminBloc createBloc() => AdminBloc(
        getDashboardStatsUseCase: mockGetDashboardStats,
        getAllEventsUseCase: mockGetAllEvents,
        getUsersUseCase: mockGetUsers,
        adminRepository: mockAdminRepository,
      );

  group('AdminBloc', () {
    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, DashboardStatsLoaded] when getDashboardStats succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetDashboardStats.call())
            .thenAnswer((_) async => const Right(DashboardStats()));
        bloc.add(const GetDashboardStatsEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<DashboardStatsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminError] when getDashboardStats fails',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetDashboardStats.call())
            .thenAnswer((_) async => const Left(tFailure));
        bloc.add(const GetDashboardStatsEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<AdminError>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminUsersLoaded] when getUsers succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetUsers.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const GetAdminUsersEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<AdminUsersLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminEventsLoaded] when getAllEvents succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockGetAllEvents.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const GetAdminEventsEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<AdminEventsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminBookingsLoaded] when getAllBookings succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.getAllBookings())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const GetAdminBookingsEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<AdminBookingsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminTicketsLoaded] when getAllTickets succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.getAllTickets())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const GetAdminTicketsEvent());
      },
      expect: () => [isA<AdminLoading>(), isA<AdminTicketsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminUsersLoaded] after updateUserRole succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.updateUserRole('1', 'organizer'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetUsers.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const UpdateUserRoleEvent(userId: '1', newRole: 'organizer'));
      },
      expect: () => [isA<AdminLoading>(), isA<AdminUsersLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminEventsLoaded] after approveEvent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.approveEvent('1', approved: true, reason: null))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetAllEvents.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const ApproveEventEvent(eventId: '1'));
      },
      expect: () => [isA<AdminLoading>(), isA<AdminEventsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminEventsLoaded] after toggleEventFeatured succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.toggleEventFeatured('1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetAllEvents.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const ToggleEventFeaturedEvent(eventId: '1'));
      },
      expect: () => [isA<AdminLoading>(), isA<AdminEventsLoaded>()],
    );

    blocTest<AdminBloc, AdminState>(
      'emits [AdminLoading, AdminEventsLoaded] after deleteEvent succeeds',
      build: createBloc,
      act: (bloc) {
        when(() => mockAdminRepository.deleteEvent('1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetAllEvents.call())
            .thenAnswer((_) async => const Right([]));
        bloc.add(const DeleteAdminEventEvent(eventId: '1'));
      },
      expect: () => [isA<AdminLoading>(), isA<AdminEventsLoaded>()],
    );
  });
}
