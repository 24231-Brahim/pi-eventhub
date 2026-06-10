import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';
import 'package:eventhub/shared/widgets/error_widget.dart';
import 'package:eventhub/shared/widgets/empty_widget.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(const GetUserTicketsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myTickets),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/qr-scanner'),
          ),
        ],
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const LoadingWidget();
          }
          if (state is TicketError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<TicketBloc>().add(const GetUserTicketsEvent()),
            );
          }
          if (state is UserTicketsLoaded) {
            if (state.tickets.isEmpty) {
              return EmptyWidget(message: l10n.noTickets);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tickets.length,
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.confirmation_number, size: 40),
                    title: Text(ticket.eventTitle ?? l10n.eventTicket),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ticket.eventDate != null)
                          Text(ticket.eventDate!),
                        Text('${l10n.status}: ${ticket.status.name}'),
                      ],
                    ),
                    trailing: const Icon(Icons.qr_code),
                    onTap: () => context.push(
                      '/qr-code',
                      extra: ticket,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
