import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
import 'package:eventhub/features/events/domain/entities/event.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() =>
      _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    context.read<EventBloc>().add(GetEventsEvent(organizerId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/qr-scanner'),
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
              onRetry: () =>
                  context.read<EventBloc>().add(const GetEventsEvent()),
            );
          }
          if (state is EventsLoaded) {
            final events = state.events;
            final total = events.length;
            final active = events.where((e) => e.status == EventStatus.published).length;
            final draft = events.where((e) => e.status == EventStatus.draft).length;
            final completed = events.where((e) => e.status == EventStatus.completed).length;
            final totalBookings = events.fold<int>(
                0, (sum, e) => sum + e.currentParticipants);
            final totalRevenue = events.fold<double>(
                0, (sum, e) => sum + e.price * e.currentParticipants);
            final totalCapacity = events.fold<int>(
                0, (sum, e) => sum + e.maxParticipants);
            final participationRate = totalCapacity > 0
                ? (totalBookings / totalCapacity * 100).toStringAsFixed(1)
                : '0.0';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _DashboardCard(
                        title: l10n.totalEvents,
                        value: '$total',
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                      _DashboardCard(
                        title: l10n.active,
                        value: '$active',
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                      _DashboardCard(
                        title: l10n.bookings,
                        value: '$totalBookings',
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                      _DashboardCard(
                        title: l10n.revenue,
                        value: '${totalRevenue.toStringAsFixed(2)} TND',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.eventStatus,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatusIndicator(
                        label: l10n.draft,
                        value: draft,
                        total: total,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _StatusIndicator(
                        label: l10n.active,
                        value: active,
                        total: total,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _StatusIndicator(
                        label: l10n.completed,
                        value: completed,
                        total: total,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.participationRate,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '$participationRate%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: totalCapacity > 0
                                        ? totalBookings / totalCapacity
                                        : 0,
                                    minHeight: 12,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalBookings / $totalCapacity ${l10n.participants}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.quickActions,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionChip(
                          avatar: const Icon(Icons.add),
                          label: Text(l10n.createEvent),
                          onPressed: () =>
                              context.push('/create-event'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionChip(
                          avatar: const Icon(Icons.list),
                          label: Text(l10n.manageEvents),
                          onPressed: () =>
                              context.push('/manage-events'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionChip(
                          avatar: const Icon(Icons.qr_code_scanner),
                          label: Text(l10n.scanQR),
                          onPressed: () =>
                              context.push('/qr-scanner'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _StatusIndicator({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? value / total : 0.0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
