import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  int _users = 0;
  int _events = 0;
  int _bookings = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        Supabase.instance.client.from('profiles').select('id'),
        Supabase.instance.client.from('events').select('id'),
        Supabase.instance.client.from('bookings').select('id'),
      ]);
      setState(() {
        _users = (results[0] as List).length;
        _events = (results[1] as List).length;
        _bookings = (results[2] as List).length;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: '$_users',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Total Events',
                    value: '$_events',
                    icon: Icons.event,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Total Bookings',
                    value: '$_bookings',
                    icon: Icons.book_online,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        )),
                Text(value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
