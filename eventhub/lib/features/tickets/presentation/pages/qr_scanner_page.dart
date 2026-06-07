import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: BlocListener<TicketBloc, TicketState>(
        listener: (context, state) {
          if (state is TicketValidated) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('✅ Valid Ticket'),
                content: Text('Ticket ID: ${state.ticket.id}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (state is TicketError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('❌ Invalid Ticket'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
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
