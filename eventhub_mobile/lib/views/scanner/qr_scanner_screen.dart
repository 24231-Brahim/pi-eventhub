import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../providers/invitation_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _scanned = true);
    await _ctrl.stop();

    final qrCode = barcode.rawValue!;
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final inv = context.read<InvitationProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await inv.verifyQrCode(qrCode);

    if (!mounted) return;
    Navigator.pop(context); // close loading dialog

    final isSuccess = result.contains('success') ||
        result.contains('USED') ||
        result.contains('✅') ||
        result.contains('successfully');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 48,
                color:
                    isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? l.qrVerified : l.qrInvalid,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSuccess ? Colors.green : Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // close result dialog
                Navigator.pop(context); // close scanner
              },
              child: Text(isSuccess ? '✅ OK' : '❌ OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l.scanQr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _ctrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),
          // Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(
                color: theme.colorScheme.primary),
            child: const SizedBox.expand(),
          ),
          // Instructions
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.verifyQr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color color;
  const _ScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: size.width * 0.72,
      height: size.width * 0.72,
    );

    // Dark overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
          scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
        path, Paint()..color = Colors.black.withOpacity(0.6));

    // Corner brackets
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;
    final r = scanRect;

    // Top-left
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);
    // Top-right
    canvas.drawLine(r.topRight, r.topRight - const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);
    // Bottom-left
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft - const Offset(0, cornerLen), paint);
    // Bottom-right
    canvas.drawLine(r.bottomRight, r.bottomRight - const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight - const Offset(0, cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
