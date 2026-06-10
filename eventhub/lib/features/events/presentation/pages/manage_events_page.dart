import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/presentation/widgets/event_card.dart';
import 'package:eventhub/l10n/app_localizations.dart';
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
      appBar: AppBar(
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
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoading) {
              return const LoadingWidget();
            }
            if (state is EventError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<EventBloc>().add(const GetEventsEvent()),
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
                padding: const EdgeInsets.all(16),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return Column(
                    children: [
                      if (event.status != EventStatus.published)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(25),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_off,
                                  size: 14, color: Colors.orange[700]),
                              const SizedBox(width: 4),
                              Text(
                                l10n.draft,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Stack(
                        children: [
                          EventCard(
                            event: event,
                            onTap: () => context.push(
                              '/event-details',
                              extra: event,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: Colors.blue,
                                  tooltip: l10n.editEvent,
                                  onPressed: () => context.push(
                                    '/edit-event',
                                    extra: event,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    event.status == EventStatus.published
                                        ? Icons.published_with_changes
                                        : Icons.publish,
                                    color: event.status == EventStatus.published
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  tooltip: event.status == EventStatus.published
                                      ? l10n.unpublish
                                      : l10n.publish,
                                  onPressed: () => _togglePublish(event),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
