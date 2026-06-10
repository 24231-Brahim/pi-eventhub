import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/entities/event_invitation.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getEvents({
    int page = 0,
    int size = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
    String? organizerId,
  });
  Future<Either<Failure, Event>> getEventById(String id);
  Future<Either<Failure, Event>> createEvent(Event event);
  Future<Either<Failure, Event>> updateEvent(Event event);
  Future<Either<Failure, void>> deleteEvent(String id);
  Future<Either<Failure, bool>> toggleFavorite(String eventId);
  Future<Either<Failure, List<String>>> getUserFavoriteIds();

  Future<Either<Failure, List<EventInvitation>>> getInvitations(String eventId);
  Future<Either<Failure, EventInvitation>> createInvitation(
      String eventId, String email, String name);
  Future<Either<Failure, void>> deleteInvitation(String id);
  Future<Either<Failure, void>> createInvitationsBulk(
      String eventId, List<Map<String, String>> invitations);
}
