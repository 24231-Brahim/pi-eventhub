import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingWidget();
          }
          if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<NotificationBloc>().add(const GetNotificationsEvent()),
            );
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return EmptyWidget(message: l10n.noNotifications);
            }
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return ListTile(
                  leading: Icon(
                    notif.isRead
                        ? Icons.notifications_none
                        : Icons.notifications,
                    color: notif.isRead ? Colors.grey : null,
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight:
                          notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notif.body),
                  trailing: notif.isRead ? null : _UnreadDot(),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
