import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetAdminUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageUsersTitle)),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(const GetAdminUsersEvent()),
            );
          }
          if (state is AdminUsersLoaded) {
            final users = state.users;
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AdminBloc>().add(const GetAdminUsersEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final role = user['role'] as String? ?? 'participant';
                  final isActive = user['is_active'] as bool? ?? true;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (user['name'] as String? ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(user['name'] as String? ?? l10n.noName),
                      subtitle: Text(
                        '${user['email'] as String? ?? ''}${!isActive ? ' (${l10n.disabled})' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoleBadge(role: role),
                          const SizedBox(width: 8),
                          if (role != 'admin')
                            IconButton(
                              icon: const Icon(Icons.swap_horiz),
                              tooltip:
                                  'Toggle role (organizer/participant)',
                              onPressed: () {
                                final newRole =
                                    role == 'organizer' ? 'participant' : 'organizer';
                                context.read<AdminBloc>().add(
                                      UpdateUserRoleEvent(
                                        userId: user['id'] as String,
                                        newRole: newRole,
                                      ),
                                    );
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                            tooltip: isActive
                                ? 'Deactivate user'
                                : 'Activate user',
                            onPressed: () {
                              context.read<AdminBloc>().add(
                                    ToggleUserActiveEvent(
                                        userId: user['id'] as String),
                                  );
                            },
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
