import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('bookings')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _bookings = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: _bookings.isEmpty
                      ? const Center(child: Text('No bookings'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final booking = _bookings[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    booking['event_title'] as String? ?? 'Event'),
                                subtitle: Text(
                                  'User: ${booking['user_id'] as String? ?? ''} | ${booking['status'] as String? ?? ''}',
                                ),
                                trailing: Text(
                                  '${booking['total_amount'] ?? 0} TND',
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
