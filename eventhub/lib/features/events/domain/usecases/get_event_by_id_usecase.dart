import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/domain/repositories/event_repository.dart';

class GetEventByIdUseCase {
  final EventRepository repository;
  GetEventByIdUseCase({required this.repository});

  Future<Either<Failure, Event>> call(String id) {
    return repository.getEventById(id);
  }
}
