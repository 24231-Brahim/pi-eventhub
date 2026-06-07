import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/auth/presentation/bloc/auth_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
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
              'Welcome, ${user?.name ?? 'Admin'}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Admin Panel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'Manage all users',
              color: Colors.blue,
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.event,
              title: 'Events',
              subtitle: 'Manage all events',
              color: Colors.green,
              onTap: () => context.push('/admin/events'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.book_online,
              title: 'Bookings',
              subtitle: 'View all bookings',
              color: Colors.orange,
              onTap: () => context.push('/admin/bookings'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.confirmation_number,
              title: 'Tickets',
              subtitle: 'View all tickets',
              color: Colors.purple,
              onTap: () => context.push('/admin/tickets'),
            ),
            const SizedBox(height: 8),
            _AdminCard(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Platform statistics',
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
