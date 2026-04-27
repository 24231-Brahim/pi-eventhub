/*
 * FICHIER : invitation_service.dart
 * RÔLE : Gère les appels au serveur pour tout ce qui concerne les invitations
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier envoie les requêtes au serveur pour créer
 * une invitation, récupérer mes invitations, ou vérifier un code QR.
 * Il utilise ApiService pour communiquer avec le backend.
 * UTILISÉ PAR : invitation_provider.dart (qui gère l'état des invitations)
 */

import '../models/invitation.dart'; // Le modèle de données invitation
import 'api_service.dart'; // Le service de communication HTTP

class InvitationService {
  // ── MÉTHODE : Créer une invitation (Organisateur) ───────────────
  // CE QUE ÇA FAIT : Envoie une demande au serveur pour inviter un invité
  // ROUTE : POST /invitations
  Future<Invitation> create(int eventId, String guestEmail) async {
    final response = await ApiService.post('/invitations', {
      'eventId': eventId, // L'identifiant de l'événement
      'guestEmail': guestEmail, // L'email de l'invité
    });
    // Convertit la réponse JSON en objet Invitation
    return Invitation.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  // ── MÉTHODE : Récupérer mes invitations (Invité) ────────────────
  // CE QUE ÇA FAIT : Demande au serveur la liste des invitations reçues
  // ROUTE : GET /invitations/my
  Future<List<Invitation>> getMyInvitations() async {
    final response = await ApiService.get('/invitations/my');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    // Convertit chaque élément JSON en objet Invitation
    return list
        .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  // ── MÉTHODE : Vérifier un code QR (Organisateur) ────────────────
  // CE QUE ÇA FAIT : Envoie le code QR scanné au serveur pour vérification
  // Le serveur vérifie si le code est valide et si l'invitation n'est pas déjà utilisée
  // ROUTE : POST /invitations/verify
  Future<String> verifyQrCode(String qrCode) async {
    final response = await ApiService.post('/invitations/verify', {
      'qrCode': qrCode, // Le code QR scanné
    });
    final data = ApiService.parseResponse(response) as Map<String, dynamic>;
    // Renvoie le message de confirmation du serveur
    return data['message'] as String? ?? 'Verified';
  }
}
