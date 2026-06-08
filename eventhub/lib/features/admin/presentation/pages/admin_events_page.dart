import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetAdminEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageEvents)),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(const GetAdminEventsEvent()),
            );
          }
          if (state is AdminEventsLoaded) {
            final events = state.events;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AdminBloc>().add(const GetAdminEventsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final status = event['status'] as String? ?? 'draft';
                  final isFeatured =
                      (event['is_featured'] as bool?) ?? false;
                  final isApproved = status == 'published';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event['title'] as String? ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              _StatusBadge(status: status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event['date'] as String? ?? ''} | ${event['city'] as String? ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isApproved && status != 'rejected')
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  tooltip: 'Approve',
                                  onPressed: () {
                                    context.read<AdminBloc>().add(
                                          ApproveEventEvent(
                                            eventId: event['id'] as String,
                                          ),
                                        );
                                  },
                                ),
                              if (isApproved)
                                IconButton(
                                  icon: Icon(Icons.star,
                                      color: isFeatured
                                          ? Colors.amber
                                          : Colors.grey),
                                  tooltip: isFeatured
                                      ? 'Remove featured'
                                      : 'Mark as featured',
                                  onPressed: () {
                                    context.read<AdminBloc>().add(
                                          ToggleEventFeaturedEvent(
                                            eventId: event['id'] as String,
                                          ),
                                        );
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                tooltip: 'Delete event',
                                onPressed: () =>
                                    _confirmDelete(event['id'] as String),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _confirmDelete(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEvent),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context
          .read<AdminBloc>()
          .add(DeleteAdminEventEvent(eventId: id));
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'published' => Colors.green,
      'draft' => Colors.orange,
      'rejected' => Colors.red,
      'cancelled' => Colors.grey,
      _ => Colors.blue,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
