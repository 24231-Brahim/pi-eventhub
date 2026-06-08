import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetDashboardStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.analytics)),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }
          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminBloc>()
                        .add(const GetDashboardStatsEvent()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardStatsLoaded) {
            final s = state.stats;
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<AdminBloc>()
                  .add(const GetDashboardStatsEvent()),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SectionTitle(title: l10n.users),
                    const SizedBox(height: 8),
                    _StatCard(
                      title: l10n.users,
                      value: '${s.totalUsers}',
                      subtitle:
                          '${s.totalAdmins} admin(s), ${s.totalOrganizers} organizer(s), ${s.totalParticipants} participant(s)',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _SectionTitle(title: l10n.events),
                    const SizedBox(height: 8),
                    _StatCard(
                      title: l10n.totalEvents,
                      value: '${s.totalEvents}',
                      subtitle:
                          '${s.activeEvents} active, ${s.pendingEvents} pending, ${s.completedEvents} completed',
                      icon: Icons.event,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _SectionTitle(title: l10n.totalAmount),
                    const SizedBox(height: 8),
                    _StatCard(
                      title: l10n.totalBookings,
                      value: '${s.totalBookings}',
                      icon: Icons.book_online,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: l10n.revenue,
                      value: '${s.totalRevenue.toStringAsFixed(2)} TND',
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: l10n.tickets,
                      value: '${s.totalTickets}',
                      icon: Icons.confirmation_number,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600])),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[500])),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
