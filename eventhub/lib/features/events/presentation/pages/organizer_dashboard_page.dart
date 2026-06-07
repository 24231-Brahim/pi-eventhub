import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/events/presentation/bloc/event_bloc.dart';
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
    context.read<EventBloc>().add(const GetEventsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pushNamed(context, '/qr-scanner'),
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
            final active =
                events.where((e) => e.status.name == 'published').length;
            final totalBookings = events.fold<int>(
                0, (sum, e) => sum + e.currentParticipants);
            final totalRevenue = events.fold<double>(
                0, (sum, e) => sum + e.price * e.currentParticipants);

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
                        title: 'Total Events',
                        value: '$total',
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                      _DashboardCard(
                        title: 'Active',
                        value: '$active',
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                      _DashboardCard(
                        title: 'Bookings',
                        value: '$totalBookings',
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                      _DashboardCard(
                        title: 'Revenue',
                        value: '${totalRevenue.toStringAsFixed(2)} TND',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
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
                          label: const Text('Create Event'),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/create-event'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionChip(
                          avatar: const Icon(Icons.list),
                          label: const Text('Manage Events'),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/manage-events'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionChip(
                          avatar: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR'),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/qr-scanner'),
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
