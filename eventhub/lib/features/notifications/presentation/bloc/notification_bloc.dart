import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/features/notifications/domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationBloc({required this.getNotificationsUseCase})
      : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
  }

  Future<void> _onGetNotifications(
      GetNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    final result = await getNotificationsUseCase.call();
    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (notifications) =>
          emit(NotificationsLoaded(notifications: notifications)),
    );
  }
}
