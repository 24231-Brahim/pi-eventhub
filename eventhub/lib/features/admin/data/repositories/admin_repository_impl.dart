import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/data/datasources/admin_supabase_datasource.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminSupabaseDataSource dataSource;

  AdminRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final data = await dataSource.getDashboardStats();
      return Right(DashboardStats(
        totalUsers: data['totalUsers'] as int,
        totalAdmins: data['totalAdmins'] as int,
        totalOrganizers: data['totalOrganizers'] as int,
        totalParticipants: data['totalParticipants'] as int,
        totalEvents: data['totalEvents'] as int,
        activeEvents: data['activeEvents'] as int,
        pendingEvents: data['pendingEvents'] as int,
        completedEvents: data['completedEvents'] as int,
        totalBookings: data['totalBookings'] as int,
        totalTickets: data['totalTickets'] as int,
        totalRevenue: (data['totalRevenue'] as num).toDouble(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers() async {
    try {
      final data = await dataSource.getUsers();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(
      String userId, String newRole) async {
    try {
      await dataSource.updateUserRole(userId, newRole);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserActive(String userId) async {
    try {
      await dataSource.toggleUserActive(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllEvents() async {
    try {
      final data = await dataSource.getAllEvents();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveEvent(String eventId,
      {bool approved = true, String? reason}) async {
    try {
      await dataSource.approveEvent(eventId, approved: approved, reason: reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleEventFeatured(String eventId) async {
    try {
      await dataSource.toggleEventFeatured(eventId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      await dataSource.deleteEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllBookings() async {
    try {
      final data = await dataSource.getAllBookings();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllTickets() async {
    try {
      final data = await dataSource.getAllTickets();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
