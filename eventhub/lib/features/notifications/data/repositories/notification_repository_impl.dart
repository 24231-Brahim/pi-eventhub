import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/core/network/network_info.dart';
import 'package:eventhub/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:eventhub/features/notifications/data/models/notification_model.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final data = await remoteDataSource.getNotifications();
      final notifications =
          data.map((e) => NotificationModel.fromJson(e)).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
