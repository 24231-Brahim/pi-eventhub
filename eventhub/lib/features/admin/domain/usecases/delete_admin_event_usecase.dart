import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class DeleteAdminEventUseCase {
  final AdminRepository repository;
  DeleteAdminEventUseCase({required this.repository});

  Future<Either<Failure, void>> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}
