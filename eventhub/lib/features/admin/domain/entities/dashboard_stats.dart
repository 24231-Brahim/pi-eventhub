import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalUsers;
  final int totalAdmins;
  final int totalOrganizers;
  final int totalParticipants;
  final int totalEvents;
  final int activeEvents;
  final int pendingEvents;
  final int completedEvents;
  final int totalBookings;
  final int totalTickets;
  final double totalRevenue;

  const DashboardStats({
    this.totalUsers = 0,
    this.totalAdmins = 0,
    this.totalOrganizers = 0,
    this.totalParticipants = 0,
    this.totalEvents = 0,
    this.activeEvents = 0,
    this.pendingEvents = 0,
    this.completedEvents = 0,
    this.totalBookings = 0,
    this.totalTickets = 0,
    this.totalRevenue = 0,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalAdmins,
        totalOrganizers,
        totalParticipants,
        totalEvents,
        activeEvents,
        pendingEvents,
        completedEvents,
        totalBookings,
        totalTickets,
        totalRevenue,
      ];
}
