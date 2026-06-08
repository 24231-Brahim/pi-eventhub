import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/admin/domain/repositories/admin_repository.dart';

class GetAllEventsUseCase {
  final AdminRepository repository;
  GetAllEventsUseCase({required this.repository});

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return repository.getAllEvents();
  }
}
