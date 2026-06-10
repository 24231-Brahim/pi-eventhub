import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/presentation/widgets/event_card.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(const GetEventsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!),
              onDeleted: () => setState(() {
                _selectedCategory = null;
                context.read<EventBloc>().add(const GetEventsEvent());
              }),
            ),
          Expanded(
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
                    return EmptyWidget(message: l10n.noEvents);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) => EventCard(
                      event: state.events[index],
                      onTap: () => context.push(
                        '/event-details',
                        extra: state.events[index],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _EventSearchDelegate(),
    );
  }

  void _showFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.filterByCategory,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventCategory.values
                  .map((cat) => cat.name)
                  .map((name) => name[0].toUpperCase() + name.substring(1))
                  .map((cat) => FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setState(
                              () => _selectedCategory = selected ? cat : null);
                          Navigator.pop(context);
                          context.read<EventBloc>().add(GetEventsEvent(
                                category: _selectedCategory?.toLowerCase(),
                              ));
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) =>
      buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      return EmptyWidget(message: l10n.search);
    }
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is! EventsLoaded) {
          return const LoadingWidget();
        }
        final filtered = state.events.where((e) =>
            e.title.toLowerCase().contains(query.toLowerCase()) ||
            e.description.toLowerCase().contains(query.toLowerCase()) ||
            (e.city?.toLowerCase().contains(query.toLowerCase()) ?? false));
        if (filtered.isEmpty) {
          return EmptyWidget(message: l10n.noEvents);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => EventCard(
            event: filtered.elementAt(index),
            onTap: () {
              close(context, null);
              context.push(
                '/event-details',
                extra: filtered.elementAt(index),
              );
            },
          ),
        );
      },
    );
  }
}
