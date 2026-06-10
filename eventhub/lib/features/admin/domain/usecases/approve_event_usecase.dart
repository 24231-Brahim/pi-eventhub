import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class ApproveEventUseCase {
  final AdminRepository repository;
  ApproveEventUseCase({required this.repository});

  Future<Either<Failure, void>> call(String eventId, {bool approved = true, String? reason}) {
    return repository.approveEvent(eventId, approved: approved, reason: reason);
  }
}
