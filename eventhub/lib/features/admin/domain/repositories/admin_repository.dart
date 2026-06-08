import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';

abstract class AdminRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers();
  Future<Either<Failure, void>> updateUserRole(String userId, String newRole);
  Future<Either<Failure, void>> toggleUserActive(String userId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllEvents();
  Future<Either<Failure, void>> approveEvent(String eventId, {bool approved = true, String? reason});
  Future<Either<Failure, void>> toggleEventFeatured(String eventId);
  Future<Either<Failure, void>> deleteEvent(String eventId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllBookings();
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllTickets();
}
