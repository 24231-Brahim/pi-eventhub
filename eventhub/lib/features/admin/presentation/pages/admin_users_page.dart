import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _users = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleRole(String userId, String currentRole) async {
    final newRole = switch (currentRole) {
      'admin' => 'participant',
      'organizer' => 'participant',
      _ => 'organizer',
    };
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'role': newRole}).eq('id', userId);
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final role = user['role'] as String? ?? 'participant';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (user['name'] as String? ?? '?')
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(user['name'] as String? ?? 'No name'),
                          subtitle: Text(user['email'] as String? ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RoleBadge(role: role),
                              const SizedBox(width: 8),
                              if (role != 'admin')
                                IconButton(
                                  icon: const Icon(Icons.swap_horiz),
                                  tooltip: 'Toggle role (organizer/participant)',
                                  onPressed: () =>
                                      _toggleRole(user['id'] as String, role),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      'admin' => Colors.red,
      'organizer' => Colors.green,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
