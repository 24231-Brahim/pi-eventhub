import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;
  DeleteEventUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteEvent(id);
  }
}
