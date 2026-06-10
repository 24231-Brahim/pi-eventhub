import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanQRCode)),
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
