import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/features/tickets/presentation/bloc/ticket_bloc.dart';
import 'package:eventhub/l10n/app_localizations.dart';
import 'package:eventhub/shared/widgets/loading_widget.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  DateTime _lastScan = DateTime.now();
  static const Duration _debounceDuration = Duration(seconds: 2);

  void _onDetect(BarcodeCapture capture, TicketBloc bloc) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    final now = DateTime.now();
    if (now.difference(_lastScan) < _debounceDuration) return;
    _lastScan = now;
    bloc.add(ValidateTicketEvent(qrData: barcode!.rawValue!));
  }

  void _showValidationResult(BuildContext context, TicketState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is TicketValidated) {
      final ticket = state.ticket;
      switch (ticket.status) {
        case TicketStatus.used:
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 28),
                  SizedBox(width: 8),
                  Text('Already Used'),
                ],
              ),
              content: const Text('This ticket was already checked in.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        case TicketStatus.cancelled:
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(l10n.invalidTicket),
                ],
              ),
              content: const Text('This ticket has been cancelled.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        case TicketStatus.active:
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text(l10n.validTicket),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.ticketID}: ${ticket.id}'),
                  if (ticket.eventTitle != null)
                    Text('Event: ${ticket.eventTitle}'),
                  const Text('Check-in successful!'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
      }
    }
    if (state is TicketError) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Invalid Ticket'),
            ],
          ),
          content: Text(state.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanQRCode)),
      body: BlocListener<TicketBloc, TicketState>(
        listener: (context, state) => _showValidationResult(context, state),
        child: BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            return Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) =>
                      _onDetect(capture, context.read<TicketBloc>()),
                ),
                if (state is TicketLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black54,
                      child: Center(child: LoadingWidget()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
