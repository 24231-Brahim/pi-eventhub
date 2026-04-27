/*
 * FICHIER : qr_display_screen.dart
 * RÔLE : Affiche le code QR complet d'une invitation
 * DESCRIPTION (POUR DÉBUTANTS) : Cet écran permet à l'invité de voir son code QR
 * de manière bien visible. Ce code QR sera scanné par l'organisateur à l'événement
 * pour vérifier la présence. On peut aussi copier le code dans le presse-papiers.
 * UTILISÉ PAR : my_invitations_screen.dart (quand on clique sur une invitation)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour copier dans le presse-papiers
import 'package:qr_flutter/qr_flutter.dart'; // Pour générer le code QR visuel
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/invitation.dart';

class QrDisplayScreen extends StatelessWidget {
  final Invitation invitation; // L'invitation dont on affiche le QR
  const QrDisplayScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // Traductions
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(l.myQrCode, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // Titre de l'événement
              Text(
                invitation.eventTitle,
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Badge de statut (EN ATTENTE ou UTILISÉ)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: invitation.isPending ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: invitation.isPending ? Colors.green.shade300 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  invitation.isPending ? l.pending : l.used,
                  style: TextStyle(
                      color: invitation.isPending ? Colors.green.shade700 : Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),

              // Code QR visuel (généré automatiquement avec la bibliothèque qr_flutter)
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
                  data: invitation.qrCode, // Le code QR en texte (UUID)
                  version: QrVersions.auto, // Taille automatique
                  size: 240, // Taille du carré QR
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square, // Forme des coins du QR
                    color: theme.colorScheme.primary, // Couleur des coins
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square, // Carrés du QR
                    color: Colors.black87, // Couleur des carrés
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Code QR en texte (cliquable pour copier)
              GestureDetector(
                onTap: () {
                  // Copie le code QR dans le presse-papiers du téléphone
                  Clipboard.setData(ClipboardData(text: invitation.qrCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié !')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        invitation.qrCode,
                        style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11, color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nom de l'invité
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
