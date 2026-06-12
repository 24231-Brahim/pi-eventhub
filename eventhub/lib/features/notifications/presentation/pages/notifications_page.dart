import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eventhub/features/notifications/domain/entities/notification.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/core/utils/date_utils.dart' as app_date_utils;

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

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmation:
        return Icons.confirmation_number;
      case NotificationType.paymentConfirmed:
        return Icons.payments;
      case NotificationType.eventCancelled:
        return Icons.event_busy;
      case NotificationType.eventReminder:
        return Icons.celebration;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerHigh,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.stackMd),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerPadding,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.notifications,
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const LoadingWidget();
                  }
                  if (state is NotificationError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context
                          .read<NotificationBloc>()
                          .add(const GetNotificationsEvent()),
                    );
                  }
                  if (state is NotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return EmptyWidget(message: l10n.noNotifications);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.containerPadding,
                      ).copyWith(bottom: AppSpacing.stackLg),
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.stackMd),
                      itemBuilder: (context, index) {
                        final notif = state.notifications[index];
                        return Dismissible(
                          key: Key(notif.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            context.read<NotificationBloc>().add(
                                  MarkNotificationAsReadEvent(id: notif.id),
                                );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSpacing.containerPadding,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.vibrantGreen,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.obsidian,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (!notif.isRead) {
                                context.read<NotificationBloc>().add(
                                      MarkNotificationAsReadEvent(id: notif.id),
                                    );
                              }
                            },
                            child: _NotificationTile(
                              notification: notif,
                              icon: _iconForType(notif.type),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;

  const _NotificationTile({required this.notification, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timestamp = notification.createdAt != null
        ? app_date_utils.DateUtils.timeAgo(notification.createdAt!)
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.vibrantGreen.withValues(alpha: 0.05)
            : AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isUnread
            ? const Border(
                left: BorderSide(color: AppColors.vibrantGreen, width: 4),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppColors.vibrantGreen.withValues(alpha: 0.2)
                      : AppColors.surfaceVariant.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isUnread
                      ? AppColors.vibrantGreen
                      : AppColors.onSurfaceVariant,
                ),
              ),
              if (isUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.vibrantGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceContainerHigh,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.gutter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.stackSm / 2),
                Text(
                  notification.body,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0,
                  ),
                ),
                if (timestamp.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.stackSm),
                  Text(
                    timestamp,
                    style: AppTypography.labelMd.copyWith(
                      color: isUnread
                          ? AppColors.vibrantGreen
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
