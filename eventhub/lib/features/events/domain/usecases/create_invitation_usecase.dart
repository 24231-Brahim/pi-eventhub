import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class CreateInvitationUseCase {
  final EventRepository repository;
  CreateInvitationUseCase({required this.repository});

  Future<Either<Failure, EventInvitation>> call(
      String eventId, String email, String name) {
    return repository.createInvitation(eventId, email, name);
  }
}
