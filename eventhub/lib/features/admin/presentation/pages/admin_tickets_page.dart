import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhub/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetAdminTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageTickets)),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingWidget();
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AdminBloc>().add(const GetAdminTicketsEvent()),
            );
          }
          if (state is AdminTicketsLoaded) {
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return Center(child: Text(l10n.noTickets));
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AdminBloc>().add(const GetAdminTicketsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  final status = ticket['status'] as String? ?? '';
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: status == 'active'
                            ? Colors.green.withAlpha(30)
                            : Colors.grey.withAlpha(30),
                        child: Icon(
                          status == 'active'
                              ? Icons.confirmation_number
                              : Icons.confirmation_number_outlined,
                          color: status == 'active'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      title: Text(
                          ticket['event_title'] as String? ?? l10n.eventTicket),
                      subtitle: Text('${l10n.status}: $status'),
                      trailing: Text(
                        ticket['qr_code'] as String? ?? '',
                        style: const TextStyle(fontSize: 10),
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
