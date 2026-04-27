/*
 * FICHIER : qr_scanner_screen.dart
 * RÔLE : Permet à l'organisateur de scanner le code QR d'un invité
 * DESCRIPTION (POUR DÉBUTANTS) : Cet écran utilise la caméra du téléphone
 * pour scanner le code QR affiché par l'invité. Une fois scanné, il envoie le code
 * au serveur pour vérification. Si valide, le statut passe à UTILISÉ.
 * UTILISÉ PAR : EventDetailScreen (bouton "Scanner QR")
 */

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Pour scanner les QR codes
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../providers/invitation_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Contrôleur de la caméra pour le scanner
  final MobileScannerController _ctrl = MobileScannerController();
  // Indique si un QR a déjà été scanné (pour éviter les doublons)
  bool _scanned = false;

  @override
  void dispose() {
    // Nettoie le contrôleur de la caméra
    _ctrl.dispose();
    super.dispose();
  }

  // MÉTHODE : Quand un QR code est détecté
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Vérifie qu'on n'a pas déjà scanné (évite double traitement)
  // 2. Récupère la valeur du QR code
  // 3. Arrête la caméra
  // 4. Affiche un écran de chargement
  // 5. Envoie le code au serveur pour vérification
  // 6. Affiche le résultat (succès ou échec)
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return; // Déjà scanné, on ignore
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _scanned = true); // Marque comme scanné
    await _ctrl.stop(); // Arrête la caméra

    final qrCode = barcode.rawValue!;
    if (!mounted) return;

    final l = AppLocalizations.of(context)!;
    final inv = context.read<InvitationProvider>();

    // Affiche un dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false, // Ne peut pas fermer sans validation
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Envoie le QR code au serveur pour vérification
    final result = await inv.verifyQrCode(qrCode);

    if (!mounted) return;
    Navigator.pop(context); // Ferme le dialogue de chargement

    // Vérifie si c'est un succès (plusieurs mots-clés possibles)
    final isSuccess = result.contains('success') ||
        result.contains('USED') ||
        result.contains('✅') ||
        result.contains('successfully');

    // Affiche le résultat de la vérification
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Icône de résultat (succès ou échec)
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 48,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            // Texte de résultat
            Text(
              isSuccess ? l.qrVerified : l.qrInvalid,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18,
                  color: isSuccess ? Colors.green : Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message détaillé du serveur
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // Ferme le dialogue
                Navigator.pop(context); // Retourne à l'écran précédent
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
      backgroundColor: Colors.black, // Fond noir pour le scanner
      appBar: AppBar(
        title: Text(l.scanQr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour activer/désactiver le flash
          IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _ctrl.toggleTorch(),
          ),
          // Bouton pour changer de caméra (avant/arrière)
          IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Le scanner de codes QR (caméra)
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect, // Appelé quand un QR est détecté
          ),
          // Overlay avec un trou transparent pour viser le QR
          CustomPaint(
            painter: _ScannerOverlayPainter(color: theme.colorScheme.primary),
            child: const SizedBox.expand(),
          ),
          // Instructions en bas de l'écran
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l.verifyQr,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

// ── WIDGET POUR L'OVERLAY DU SCANNER ─────────────────────────

// Dessine un overlay sombre avec un trou rectangulaire au centre
class _ScannerOverlayPainter extends CustomPainter {
  final Color color;
  const _ScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Le rectangle de scan (zone cible)
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: size.width * 0.72,
      height: size.width * 0.72,
    );

    // Chemin pour l'overlay sombre (tout l'écran sauf le rectangle)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd; // Remplit l'extérieur seulement

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));

    // Dessine les coins du rectangle (cibles visuelles)
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 28.0;
    final r = scanRect;

    // Coin haut-gauche
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);
    // Coin haut-droit
    canvas.drawLine(r.topRight, r.topRight - const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);
    // Coin bas-gauche
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft - const Offset(0, cornerLen), paint);
    // Coin bas-droit
    canvas.drawLine(r.bottomRight, r.bottomRight - const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight - const Offset(0, cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
