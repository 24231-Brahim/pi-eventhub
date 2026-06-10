import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';
import 'package:eventhub/features/admin/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_all_events_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/update_user_role_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/toggle_user_active_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/approve_event_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/toggle_event_featured_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/delete_admin_event_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_admin_bookings_usecase.dart';
import 'package:eventhub/features/admin/domain/usecases/get_admin_tickets_usecase.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetAllEventsUseCase getAllEventsUseCase;
  final GetUsersUseCase getUsersUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final ToggleUserActiveUseCase toggleUserActiveUseCase;
  final ApproveEventUseCase approveEventUseCase;
  final ToggleEventFeaturedUseCase toggleEventFeaturedUseCase;
  final DeleteAdminEventUseCase deleteAdminEventUseCase;
  final GetAdminBookingsUseCase getAdminBookingsUseCase;
  final GetAdminTicketsUseCase getAdminTicketsUseCase;

  AdminBloc({
    required this.getDashboardStatsUseCase,
    required this.getAllEventsUseCase,
    required this.getUsersUseCase,
    required this.updateUserRoleUseCase,
    required this.toggleUserActiveUseCase,
    required this.approveEventUseCase,
    required this.toggleEventFeaturedUseCase,
    required this.deleteAdminEventUseCase,
    required this.getAdminBookingsUseCase,
    required this.getAdminTicketsUseCase,
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
        await updateUserRoleUseCase.call(event.userId, event.newRole);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminUsersEvent()),
    );
  }

  Future<void> _onToggleUserActive(
      ToggleUserActiveEvent event, Emitter<AdminState> emit) async {
    final result = await toggleUserActiveUseCase.call(event.userId);
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
    final result = await approveEventUseCase.call(
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
        await toggleEventFeaturedUseCase.call(event.eventId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminEventsEvent()),
    );
  }

  Future<void> _onDeleteEvent(
      DeleteAdminEventEvent event, Emitter<AdminState> emit) async {
    final result = await deleteAdminEventUseCase.call(event.eventId);
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => add(const GetAdminEventsEvent()),
    );
  }

  Future<void> _onGetAllBookings(
      GetAdminBookingsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAdminBookingsUseCase.call();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (bookings) => emit(AdminBookingsLoaded(bookings: bookings)),
    );
  }

  Future<void> _onGetAllTickets(
      GetAdminTicketsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await getAdminTicketsUseCase.call();
    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (tickets) => emit(AdminTicketsLoaded(tickets: tickets)),
    );
  }
}
