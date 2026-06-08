import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class ToggleFavoriteUseCase {
  final EventRepository repository;
  ToggleFavoriteUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String eventId) {
    return repository.toggleFavorite(eventId);
  }
}
