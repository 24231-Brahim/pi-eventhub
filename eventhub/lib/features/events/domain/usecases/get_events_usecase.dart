import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class GetEventsUseCase {
  final EventRepository repository;
  GetEventsUseCase({required this.repository});

  Future<Either<Failure, List<Event>>> call({
    int page = 0,
    int size = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? date,
    String? organizerId,
  }) {
    return repository.getEvents(
      page: page,
      size: size,
      category: category,
      city: city,
      minPrice: minPrice,
      maxPrice: maxPrice,
      date: date,
      organizerId: organizerId,
    );
  }
}
