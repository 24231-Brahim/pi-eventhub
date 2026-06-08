import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetAdminBookingsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageBookings)),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(const GetAdminBookingsEvent()),
            );
          }
          if (state is AdminBookingsLoaded) {
            final bookings = state.bookings;
            if (bookings.isEmpty) {
              return Center(child: Text(l10n.noTickets));
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AdminBloc>().add(const GetAdminBookingsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    child: ListTile(
                      leading: _statusIcon(
                          booking['status'] as String? ?? ''),
                      title: Text(
                          booking['event_title'] as String? ?? l10n.eventTicket),
                      subtitle: Text(
                        'User: ${booking['user_id'] as String? ?? ''} | ${booking['status'] as String? ?? ''}',
                      ),
                      trailing: Text(
                        '${booking['total_amount'] ?? 0} TND',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
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

  Widget _statusIcon(String status) {
    final icon = switch (status) {
      'confirmed' => Icons.check_circle,
      'pending' => Icons.hourglass_empty,
      'cancelled' => Icons.cancel,
      'refunded' => Icons.undo,
      _ => Icons.help,
    };
    final color = switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      'refunded' => Colors.blue,
      _ => Colors.grey,
    };
    return CircleAvatar(
      backgroundColor: color.withAlpha(30),
      child: Icon(icon, color: color),
    );
  }
}
