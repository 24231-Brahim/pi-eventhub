import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class DeleteInvitationUseCase {
  final EventRepository repository;
  DeleteInvitationUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteInvitation(id);
  }
}
