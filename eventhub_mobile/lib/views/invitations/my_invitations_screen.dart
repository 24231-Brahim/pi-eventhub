/*
 * FICHIER : my_invitations_screen.dart
 * RÔLE : Affiche la liste des invitations reçues par l'invité (GUEST)
 * DESCRIPTION (POUR DÉBUTANTS) : Cet écran est réservé aux utilisateurs avec le rôle GUEST.
 * Il affiche toutes les invitations qu'ils ont reçues pour différents événements.
 * Chaque invitation affiche le titre de l'événement, son statut (EN ATTENTE ou UTILISÉ)
 * et un extrait du code QR. En cliquant sur une invitation, on voit le code QR complet.
 * UTILISÉ PAR : EventsListScreen (via l'icône "Mes invitations")
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/invitation.dart';
import '../../providers/invitation_provider.dart';
import 'qr_display_screen.dart';

// Widget principal de la liste des invitations
class MyInvitationsScreen extends StatefulWidget {
  const MyInvitationsScreen({super.key});

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    // Quand l'écran s'affiche, on charge les invitations depuis le serveur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationProvider>().loadMyInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // Traductions
    final inv = context.watch<InvitationProvider>(); // État des invitations

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Fond gris clair
      appBar: AppBar(
        title: Text(l.myInvitations, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: inv.loading
          ? const Center(child: CircularProgressIndicator()) // Chargement en cours
          : inv.error != null
              ? Center( // Erreur de chargement
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(inv.error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<InvitationProvider>().loadMyInvitations(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ))
              : inv.invitations.isEmpty
                  ? Center( // Aucune invitation
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(l.noInvitations, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator( // Liste des invitations avec pull-to-refresh
                      onRefresh: () => context.read<InvitationProvider>().loadMyInvitations(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: inv.invitations.length,
                        itemBuilder: (_, i) => _InvitationCard(invitation: inv.invitations[i]),
                      ),
                    ),
    );
  }
}

// Widget pour afficher une carte d'invitation
class _InvitationCard extends StatelessWidget {
  final Invitation invitation;
  const _InvitationCard({required this.invitation});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Vérifie si l'invitation est encore en attente (pas encore utilisée)
    final isPending = invitation.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Cliquer sur la carte → affiche le code QR complet
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QrDisplayScreen(invitation: invitation)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bloc icône QR code (couleur change selon le statut)
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPending
                        ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.qr_code, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de l'événement
                    Text(invitation.eventTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    // Badge de statut (EN ATTENTE ou UTILISÉ)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPending ? Colors.green.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPending ? Colors.green.shade300 : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            isPending ? l.pending : l.used,
                            style: TextStyle(
                                color: isPending ? Colors.green.shade700 : Colors.grey,
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Extrait du code QR (8 premiers caractères)
                    Text(
                      invitation.qrCode.substring(0, 8) + '...',
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              // Icône indiquant qu'on peut voir le QR code
              Icon(Icons.qr_code_2, color: theme.colorScheme.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
