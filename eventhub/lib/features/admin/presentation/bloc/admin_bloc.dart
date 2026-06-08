import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';
import 'package:eventhub/features/admin/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_all_events_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetAllEventsUseCase getAllEventsUseCase;
  final GetUsersUseCase getUsersUseCase;
  final AdminRepository adminRepository;

  AdminBloc({
    required this.getDashboardStatsUseCase,
    required this.getAllEventsUseCase,
    required this.getUsersUseCase,
    required this.adminRepository,
  }) : super(const AdminInitial()) {
    on<GetDashboardStatsEvent>(_onGetDashboardStats);
    on<GetAdminUsersEvent>(_onGetUsers);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<ToggleUserActiveEvent>(_onToggleUserActive);
    on<GetAdminEventsEvent>(_onGetAllEvents);
    on<ApproveEventEvent>(_onApproveEvent);
    on<ToggleEventFeaturedEvent>(_onToggleEventFeatured);
    on<DeleteAdminEventEvent>(_onDeleteEvent);
    on<GetAdminBookingsEvent>(_onGetAllBookings);
    on<GetAdminTicketsEvent>(_onGetAllTickets);
  }

  Future<void> _onGetDashboardStats(
      GetDashboardStatsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getDashboardStatsUseCase.call();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (stats) => emit(DashboardStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onGetUsers(
      GetAdminUsersEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getUsersUseCase.call();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (users) => emit(AdminUsersLoaded(users: users)),
    );
  }

  Future<void> _onUpdateUserRole(
      UpdateUserRoleEvent event, Emitter<AdminState> emit) async {
    final result =
        await adminRepository.updateUserRole(event.userId, event.newRole);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminUsersEvent()),
    );
  }

  Future<void> _onToggleUserActive(
      ToggleUserActiveEvent event, Emitter<AdminState> emit) async {
    final result = await adminRepository.toggleUserActive(event.userId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminUsersEvent()),
    );
  }

  Future<void> _onGetAllEvents(
      GetAdminEventsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAllEventsUseCase.call();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (events) => emit(AdminEventsLoaded(events: events)),
    );
  }

  Future<void> _onApproveEvent(
      ApproveEventEvent event, Emitter<AdminState> emit) async {
    final result = await adminRepository.approveEvent(
      event.eventId,
      approved: event.approved,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminEventsEvent()),
    );
  }

  Future<void> _onToggleEventFeatured(
      ToggleEventFeaturedEvent event, Emitter<AdminState> emit) async {
    final result =
        await adminRepository.toggleEventFeatured(event.eventId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminEventsEvent()),
    );
  }

  Future<void> _onDeleteEvent(
      DeleteAdminEventEvent event, Emitter<AdminState> emit) async {
    final result = await adminRepository.deleteEvent(event.eventId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminEventsEvent()),
    );
  }

  Future<void> _onGetAllBookings(
      GetAdminBookingsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.getAllBookings();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (bookings) => emit(AdminBookingsLoaded(bookings: bookings)),
    );
  }

  Future<void> _onGetAllTickets(
      GetAdminTicketsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.getAllTickets();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (tickets) => emit(AdminTicketsLoaded(tickets: tickets)),
    );
  }
}
