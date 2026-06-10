import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;
  MarkNotificationAsReadUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.markAsRead(id);
  }
}
