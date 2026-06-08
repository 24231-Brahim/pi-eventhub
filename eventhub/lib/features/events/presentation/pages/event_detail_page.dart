import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isFavorite = false;
  bool _favoritesLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(GetEventByIdEvent(id: widget.eventId));
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final data = await Supabase.instance.client
          .from('favorites')
          .select('event_id')
          .eq('user_id', userId);
      final ids = data.map((e) => e['event_id'] as String).toList();
      if (mounted) {
        setState(() {
          _isFavorite = ids.contains(widget.eventId);
          _favoritesLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _favoritesLoaded = true);
    }
  }

  void _toggleFavorite() {
    context.read<EventBloc>().add(ToggleFavoriteEvent(eventId: widget.eventId));
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventDetails),
        actions: [
          if (_favoritesLoaded)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final state = context.watch<EventBloc>().state;
              if (state is EventDetailLoaded) {
                final event = state.event;
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    final text = [
                      event.title,
                      '',
                      event.description,
                      '',
                      DateFormat('EEEE, MMM d, yyyy HH:mm').format(event.date),
                      '${event.location}${event.city != null ? ', ${event.city}' : ''}',
                      event.isFree ? l10n.free : '${event.price.toStringAsFixed(2)} TND',
                      '',
                      l10n.discoverAndBook,
                    ].join('\n');
                    SharePlus.instance.share(ShareParams(text: text));
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listenWhen: (_, state) => state is FavoriteToggled,
        listener: (context, state) {
          if (state is FavoriteToggled) {
            setState(() => _isFavorite = state.isFavorite);
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
              onRetry: () => context
                  .read<EventBloc>()
                  .add(GetEventByIdEvent(id: widget.eventId)),
            );
          }
          if (state is EventDetailLoaded) {
            return _EventDetailContent(event: state.event);
          }
          return const LoadingWidget();
        },
      ),
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  final Event event;
  const _EventDetailContent({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      event.isFree ? l10n.free : '${event.price.toStringAsFixed(2)} TND',
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
                    text: '${l10n.completed}: ${DateFormat('MMM d, yyyy HH:mm').format(event.endDate!)}',
                  ),
                _InfoRow(icon: Icons.location_on, text: event.location),
                if (event.city != null)
                  _InfoRow(icon: Icons.map, text: event.city!),
                _InfoRow(
                  icon: Icons.people,
                  text:
                      '${event.currentParticipants}/${event.maxParticipants} ${l10n.participants}',
                ),
                if (event.organizerName != null)
                  _InfoRow(
                    icon: Icons.person,
                    text: '${l10n.organizeEvents} ${event.organizerName}',
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.description,
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
