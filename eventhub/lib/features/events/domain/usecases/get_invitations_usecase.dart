import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class GetInvitationsUseCase {
  final EventRepository repository;
  GetInvitationsUseCase({required this.repository});

  Future<Either<Failure, List<EventInvitation>>> call(String eventId) {
    return repository.getInvitations(eventId);
  }
}
