import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class ImportInvitationsUseCase {
  final EventRepository repository;
  ImportInvitationsUseCase({required this.repository});

  Future<Either<Failure, void>> call(
      String eventId, List<Map<String, String>> invitations) {
    return repository.createInvitationsBulk(eventId, invitations);
  }
}
