import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/invitation.dart';

class QrDisplayScreen extends StatelessWidget {
  final Invitation invitation;
  const QrDisplayScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(l.myQrCode,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Event title
              Text(
                invitation.eventTitle,
                style: theme.textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: invitation.isPending
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: invitation.isPending
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  invitation.isPending ? l.pending : l.used,
                  style: TextStyle(
                      color: invitation.isPending
                          ? Colors.green.shade700
                          : Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),
              // QR Code widget
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: invitation.qrCode,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: theme.colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // QR code value
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: invitation.qrCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié !')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        invitation.qrCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                invitation.guestName,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
