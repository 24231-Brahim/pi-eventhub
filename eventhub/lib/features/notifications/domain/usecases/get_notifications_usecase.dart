import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase({required this.repository});

  Future<Either<Failure, List<AppNotification>>> call() {
    return repository.getNotifications();
  }
}
