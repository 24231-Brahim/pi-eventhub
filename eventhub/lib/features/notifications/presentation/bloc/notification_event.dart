part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NotificationEvent {
  const GetNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String id;
  const MarkNotificationAsReadEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
