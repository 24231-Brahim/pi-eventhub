import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AdminBloc>().add(const GetDashboardStatsEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutEvent()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.welcome}, ${user?.name ?? l10n.users}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              l10n.adminPanel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.management,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              icon: Icons.people,
              title: l10n.users,
              subtitle: l10n.manageUsers,
              color: Colors.blue,
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.event,
              title: l10n.events,
              subtitle: l10n.manageAllEvents,
              color: Colors.green,
              onTap: () => context.push('/admin/events'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.book_online,
              title: l10n.bookings,
              subtitle: l10n.viewAllBookings,
              color: Colors.orange,
              onTap: () => context.push('/admin/bookings'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.confirmation_number,
              title: l10n.tickets,
              subtitle: l10n.viewAllTickets,
              color: Colors.purple,
              onTap: () => context.push('/admin/tickets'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.analytics,
              title: l10n.analytics,
              subtitle: l10n.platformStatistics,
              color: Colors.teal,
              onTap: () => context.push('/admin/analytics'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
