import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class UpdateUserRoleUseCase {
  final AdminRepository repository;
  UpdateUserRoleUseCase({required this.repository});

  Future<Either<Failure, void>> call(String userId, String newRole) {
    return repository.updateUserRole(userId, newRole);
  }
}
