import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('tickets')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _tickets = List<Map<String, dynamic>>.from(data);
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
      appBar: AppBar(title: const Text('Manage Tickets')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: _tickets.isEmpty
                      ? const Center(child: Text('No tickets'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = _tickets[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    ticket['event_title'] as String? ?? 'Event'),
                                subtitle: Text(
                                  'Status: ${ticket['status'] as String? ?? ''}',
                                ),
                                trailing: Text(
                                  ticket['qr_code'] as String? ?? '',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
