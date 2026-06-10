import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:eventhub/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  }) : super(const NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
  }

  Future<void> _onGetNotifications(
      GetNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    final result = await getNotificationsUseCase.call();
    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) =>
          emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    final result = await markNotificationAsReadUseCase.call(event.id);
    result.fold(
      (failure) => null,
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updated = currentState.notifications.map((n) {
            if (n.id == event.id) {
              return AppNotification(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          emit(NotificationsLoaded(notifications: updated));
        }
      },
    );
  }
}
