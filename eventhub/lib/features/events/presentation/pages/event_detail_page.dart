import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const LoadingWidget();
          }
          if (state is EventError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<EventBloc>()
                  .add(GetEventByIdEvent(id: eventId)),
            );
          }
          if (state is EventDetailLoaded) {
            return _EventDetailContent(event: state.event);
          }
          context.read<EventBloc>().add(GetEventByIdEvent(id: eventId));
          return const LoadingWidget();
        },
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  final Event event;
  const _EventDetailContent({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event.imageUrl != null)
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(event.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 250,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.event, size: 80),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(event.category.name.toUpperCase()),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.isFree ? 'FREE' : '${event.price.toStringAsFixed(2)} TND',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: event.isFree
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today,
                  text:
                      '${DateFormat('EEEE, MMM d, yyyy').format(event.date)} at ${DateFormat('HH:mm').format(event.date)}',
                ),
                if (event.endDate != null)
                  _InfoRow(
                    icon: Icons.event,
                    text: 'Ends: ${DateFormat('MMM d, yyyy HH:mm').format(event.endDate!)}',
                  ),
                _InfoRow(icon: Icons.location_on, text: event.location),
                if (event.city != null)
                  _InfoRow(icon: Icons.map, text: event.city!),
                _InfoRow(
                  icon: Icons.people,
                  text:
                      '${event.currentParticipants}/${event.maxParticipants} participants',
                ),
                if (event.organizerName != null)
                  _InfoRow(
                    icon: Icons.person,
                    text: 'Organized by ${event.organizerName}',
                  ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
