import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/presentation/widgets/event_card.dart'
    show categoryIcon;
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    context.read<EventBloc>().add(GetEventsEvent(organizerId: userId));
  }

  void _togglePublish(Event event) {
    final newStatus = event.status == EventStatus.published
        ? EventStatus.draft
        : EventStatus.published;
    final updated = Event(
      id: event.id,
      title: event.title,
      description: event.description,
      imageUrl: event.imageUrl,
      date: event.date,
      endDate: event.endDate,
      location: event.location,
      city: event.city,
      latitude: event.latitude,
      longitude: event.longitude,
      price: event.price,
      maxParticipants: event.maxParticipants,
      currentParticipants: event.currentParticipants,
      category: event.category,
      status: newStatus,
      organizerId: event.organizerId,
      organizerName: event.organizerName,
      isFeatured: event.isFeatured,
      isPrivate: event.isPrivate,
      rejectionReason: event.rejectionReason,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
    context.read<EventBloc>().add(UpdateEventEvent(event: updated));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        title: Text(l10n.myEvents),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-event'),
          ),
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listenWhen: (_, state) => state is EventUpdated || state is EventError,
        listener: (context, state) {
          if (state is EventUpdated) {
            _loadEvents();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.event.status == EventStatus.published
                      ? l10n.eventPublished
                      : l10n.eventUnpublished,
                ),
              ),
            );
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<EventBloc, EventState>(
          buildWhen: (previous, current) =>
              current is EventLoading ||
              current is EventError ||
              current is EventsLoaded,
          builder: (context, state) {
            if (state is EventLoading) {
              return const LoadingWidget();
            }
            if (state is EventError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: _loadEvents,
              );
            }
            if (state is EventsLoaded) {
              if (state.events.isEmpty) {
                return EmptyWidget(
                  message: l10n.noEvents,
                  icon: Icons.add_circle_outline,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return _ManageEventCard(
                    event: event,
                    onTogglePublish: () => _togglePublish(event),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.vibrantGreen,
        foregroundColor: AppColors.obsidian,
        onPressed: () => context.push('/create-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ManageEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTogglePublish;

  const _ManageEventCard({
    required this.event,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canTogglePublish = event.status == EventStatus.published ||
        event.status == EventStatus.draft;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.level1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/edit-event', extra: event),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: event.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: event.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    _ThumbnailPlaceholder(event: event),
                                errorWidget: (_, _, _) =>
                                    _ThumbnailPlaceholder(event: event),
                              )
                            : _ThumbnailPlaceholder(event: event),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.stackMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: AppTypography.headlineSm
                                      .copyWith(color: AppColors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.stackSm),
                              _EventStatusBadge(status: event.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.stackSm),
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  size: 14,
                                  color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${event.currentParticipants}/${event.maxParticipants}',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 0,
                                ),
                              ),
                              if (event.isPrivate) ...[
                                const SizedBox(width: AppSpacing.stackMd),
                                const Icon(Icons.lock_outline,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.privateEvent,
                                  style: AppTypography.labelMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Divider(
                  height: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSpacing.stackSm),
                Row(
                  children: [
                    Expanded(
                      child: _CardActionButton(
                        icon: Icons.edit_outlined,
                        label: l10n.editEvent,
                        onTap: () =>
                            context.push('/edit-event', extra: event),
                      ),
                    ),
                    Expanded(
                      child: _CardActionButton(
                        icon: Icons.people_outline,
                        label: l10n.attendees,
                        onTap: () =>
                            context.push('/event-attendees', extra: event),
                      ),
                    ),
                    if (event.isPrivate)
                      Expanded(
                        child: _CardActionButton(
                          icon: Icons.mail_outline,
                          label: l10n.inviteGuests,
                          onTap: () => context
                              .push('/event-invitations', extra: event),
                        ),
                      ),
                    if (canTogglePublish)
                      Expanded(
                        child: _CardActionButton(
                          icon: event.status == EventStatus.published
                              ? Icons.unpublished_outlined
                              : Icons.publish_outlined,
                          label: event.status == EventStatus.published
                              ? l10n.unpublish
                              : l10n.publish,
                          onTap: onTogglePublish,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final Event event;
  const _ThumbnailPlaceholder({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.vibrantGreen.withValues(alpha: 0.18),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        categoryIcon(event.category),
        size: 24,
        color: AppColors.vibrantGreen.withValues(alpha: 0.8),
      ),
    );
  }
}

class _EventStatusBadge extends StatelessWidget {
  final EventStatus status;
  const _EventStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    switch (status) {
      case EventStatus.published:
        color = AppColors.vibrantGreen;
        label = l10n.published;
      case EventStatus.draft:
        color = AppColors.warning;
        label = l10n.draft;
      case EventStatus.cancelled:
        color = AppColors.error;
        label = l10n.cancelledStatus;
      case EventStatus.completed:
        color = AppColors.onSurfaceVariant;
        label = l10n.completed;
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

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackSm),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.vibrantGreen),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
