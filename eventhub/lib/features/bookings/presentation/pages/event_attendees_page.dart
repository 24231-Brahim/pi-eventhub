import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eventhub/features/bookings/domain/entities/booking.dart';
import 'package:eventhub/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class EventAttendeesPage extends StatefulWidget {
  final Event event;
  const EventAttendeesPage({super.key, required this.event});

  @override
  State<EventAttendeesPage> createState() => _EventAttendeesPageState();
}

class _EventAttendeesPageState extends State<EventAttendeesPage> {
  @override
  void initState() {
    super.initState();
    _loadAttendees();
  }

  void _loadAttendees() {
    context
        .read<BookingBloc>()
        .add(GetEventBookingsEvent(eventId: widget.event.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(l10n.attendees),
        backgroundColor: AppColors.obsidian,
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const LoadingWidget();
          }
          if (state is BookingError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _loadAttendees,
            );
          }
          if (state is EventBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return EmptyWidget(
                message: l10n.noAttendeesYet,
                icon: Icons.people_outline,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) =>
                  _AttendeeCard(booking: state.bookings[index]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _AttendeeCard extends StatelessWidget {
  final Booking booking;
  const _AttendeeCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = (booking.attendeeName?.isNotEmpty ?? false)
        ? booking.attendeeName!
        : l10n.noName;
    final email = booking.attendeeEmail ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.gutter),
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTypography.labelLg
                  .copyWith(color: AppColors.vibrantGreen),
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.labelLg
                      .copyWith(color: AppColors.onSurface),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: AppSpacing.stackSm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      booking.createdAt != null
                          ? DateFormat('MMM d, yyyy')
                              .format(booking.createdAt!)
                          : '-',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.stackMd),
                    const Icon(Icons.confirmation_number_outlined,
                        size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'x${booking.quantity}',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          _StatusBadge(status: booking.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    switch (status) {
      case BookingStatus.confirmed:
        color = AppColors.vibrantGreen;
        label = l10n.confirmed;
      case BookingStatus.pending:
        color = AppColors.warning;
        label = l10n.pendingStatus;
      case BookingStatus.cancelled:
        color = AppColors.error;
        label = l10n.cancelledStatus;
      case BookingStatus.refunded:
        color = AppColors.onSurfaceVariant;
        label = l10n.refunded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.base / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
