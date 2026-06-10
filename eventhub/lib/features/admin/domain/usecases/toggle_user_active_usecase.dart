import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class ToggleUserActiveUseCase {
  final AdminRepository repository;
  ToggleUserActiveUseCase({required this.repository});

  Future<Either<Failure, void>> call(String userId) {
    return repository.toggleUserActive(userId);
  }
}
