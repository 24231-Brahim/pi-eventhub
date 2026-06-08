import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class GetUserFavoriteIdsUseCase {
  final EventRepository repository;
  GetUserFavoriteIdsUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call() {
    return repository.getUserFavoriteIds();
  }
}
