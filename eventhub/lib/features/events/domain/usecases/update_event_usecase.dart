import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;
  UpdateEventUseCase({required this.repository});

  Future<Either<Failure, Event>> call(Event event) {
    return repository.updateEvent(event);
  }
}
