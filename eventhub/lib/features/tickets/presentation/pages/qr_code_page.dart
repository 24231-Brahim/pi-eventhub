import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventhub/core/utils/date_utils.dart' as app_date_utils;
import 'package:eventhub/features/tickets/domain/entities/ticket.dart';
import 'package:eventhub/l10n/app_localizations.dart';

class QrCodePage extends StatefulWidget {
  final Ticket ticket;
  const QrCodePage({super.key, required this.ticket});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final _repaintKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _downloadQr() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/qr_${widget.ticket.eventId}_${widget.ticket.id}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'My ticket for ${widget.ticket.eventTitle ?? l10n.eventTicket}',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSaveQRCode)),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _shareQr() {
    final l10n = AppLocalizations.of(context)!;
    final text = [
      l10n.myQRCode,
      'Event: ${widget.ticket.eventTitle ?? l10n.eventTicket}',
      if (widget.ticket.eventDate != null)
        '📅 ${app_date_utils.DateUtils.formatFriendlyFromIso(widget.ticket.eventDate!)}',
      if (widget.ticket.eventLocation != null)
        '📍 ${widget.ticket.eventLocation}',
      '${l10n.status}: ${widget.ticket.status.name.toUpperCase()}',
      '',
      '${l10n.ticketID}: ${widget.ticket.id}',
    ].join('\n');

    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myQRCode),
        actions: [
          IconButton(
            icon: _isCapturing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isCapturing ? null : _downloadQr,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQr,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.ticket.eventTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.ticket.eventTitle!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.ticket.eventDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  app_date_utils.DateUtils.formatFriendlyFromIso(
                      widget.ticket.eventDate!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            RepaintBoundary(
              key: _repaintKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: widget.ticket.qrCode,
                  version: QrVersions.auto,
                  size: 250,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${l10n.status}: ${widget.ticket.status.name.toUpperCase()}',
              style: TextStyle(
                fontSize: 16,
                color: widget.ticket.status.name == 'active'
                    ? Colors.green
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.showQRAtEntrance,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
