import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQRCode),
      ),
      body: BlocListener<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state is TicketValidated) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.validTicket),
                content: Text('${l10n.ticketID}: ${state.ticket.id}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          }
          if (state is TicketError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.invalidTicket),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          }
        },
        child: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              context
                  .read<TicketBloc>()
                  .add(ValidateTicketEvent(qrData: barcode!.rawValue!));
            }
          },
        ),
      ),
    );
  }
}
