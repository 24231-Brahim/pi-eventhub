import 'package:dartz/dartz.dart';
import 'package:eventhub/core/errors/failures.dart';
import 'package:eventhub/features/notifications/data/datasources/notification_supabase_datasource.dart';
import 'package:eventhub/features/notifications/data/models/notification_model.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/features/notifications/domain/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationSupabaseDataSource dataSource;
  final SupabaseClient supabase;

  NotificationRepositoryImpl({
    required this.dataSource,
    required this.supabase,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? '';
      final data = await dataSource.getNotifications(userId);
      final notifications =
          data.map((e) => NotificationModel.fromJson(e)).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await dataSource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
