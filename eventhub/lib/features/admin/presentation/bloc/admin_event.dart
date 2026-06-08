part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class GetDashboardStatsEvent extends AdminEvent {
  const GetDashboardStatsEvent();
}

class GetAdminUsersEvent extends AdminEvent {
  const GetAdminUsersEvent();
}

class UpdateUserRoleEvent extends AdminEvent {
  final String userId;
  final String newRole;
  const UpdateUserRoleEvent({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}

class ToggleUserActiveEvent extends AdminEvent {
  final String userId;
  const ToggleUserActiveEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetAdminEventsEvent extends AdminEvent {
  const GetAdminEventsEvent();
}

class ApproveEventEvent extends AdminEvent {
  final String eventId;
  final bool approved;
  final String? reason;
  const ApproveEventEvent({
    required this.eventId,
    this.approved = true,
    this.reason,
  });

  @override
  List<Object?> get props => [eventId, approved, reason];
}

class ToggleEventFeaturedEvent extends AdminEvent {
  final String eventId;
  const ToggleEventFeaturedEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class DeleteAdminEventEvent extends AdminEvent {
  final String eventId;
  const DeleteAdminEventEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class GetAdminBookingsEvent extends AdminEvent {
  const GetAdminBookingsEvent();
}

class GetAdminTicketsEvent extends AdminEvent {
  const GetAdminTicketsEvent();
}
