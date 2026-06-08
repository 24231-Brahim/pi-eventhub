part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class DashboardStatsLoaded extends AdminState {
  final DashboardStats stats;
  const DashboardStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class AdminUsersLoaded extends AdminState {
  final List<Map<String, dynamic>> users;
  const AdminUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class AdminEventsLoaded extends AdminState {
  final List<Map<String, dynamic>> events;
  const AdminEventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class AdminBookingsLoaded extends AdminState {
  final List<Map<String, dynamic>> bookings;
  const AdminBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class AdminTicketsLoaded extends AdminState {
  final List<Map<String, dynamic>> tickets;
  const AdminTicketsLoaded({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

class AdminError extends AdminState {
  final String message;
  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}
