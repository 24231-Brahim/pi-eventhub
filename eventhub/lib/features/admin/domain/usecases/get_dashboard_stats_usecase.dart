import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/entities/dashboard_stats.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class GetDashboardStatsUseCase {
  final AdminRepository repository;
  GetDashboardStatsUseCase({required this.repository});

  Future<Either<Failure, DashboardStats>> call() {
    return repository.getDashboardStats();
  }
}
