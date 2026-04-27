/*
 * FICHIER : invitation_provider.dart
 * RÔLE : Gère l'état des invitations (liste, chargement, erreurs, vérification QR)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est le "centre de données" pour les invitations.
 * Il garde en mémoire la liste des invitations reçues, et gère la création d'invitations
 * et la vérification des codes QR. Quand quelque chose change, il prévient l'interface.
 * UTILISÉ PAR : Les pages qui affichent les invitations ou scannent des QR codes
 */

import 'package:flutter/material.dart';
import '../models/invitation.dart'; // Le modèle de données invitation
import '../services/invitation_service.dart'; // Le service de communication

class InvitationProvider extends ChangeNotifier {
  // Le service qui communique avec le serveur
  final InvitationService _service = InvitationService();

  // La liste des invitations (stockée en mémoire)
  List<Invitation> _invitations = [];
  // Indique si une opération est en cours (chargement)
  bool _loading = false;
  // Message d'erreur éventuel
  String? _error;
  // Résultat de la vérification d'un code QR
  String? _verifyResult;

  // ── GETTERS (POUR LIRE LES DONNÉES) ─────────────────────────

  // Renvoie la liste des invitations
  List<Invitation> get invitations => _invitations;

  // Indique si une opération est en cours
  bool get loading => _loading;

  // Renvoie le message d'erreur (null si pas d'erreur)
  String? get error => _error;

  // Renvoie le résultat de la vérification QR
  String? get verifyResult => _verifyResult;

  // ── MÉTHODES (POUR MODIFIER L'ÉTAT) ─────────────────────

  // MÉTHODE : Charger mes invitations depuis le serveur
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Demande au serveur la liste des invitations reçues
  // 3. Si succès : sauvegarde la liste, vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur
  // 5. Désactive le mode "chargement"
  Future<void> loadMyInvitations() async {
    _setLoading(true);
    try {
      _invitations = await _service.getMyInvitations();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // MÉTHODE : Créer une invitation (Organisateur)
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Envoie la demande au serveur (eventId + email de l'invité)
  // 3. Si succès : vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur
  // 5. Désactive le mode "chargement"
  // 6. Retourne true si succès, false si échec
  Future<bool> inviteGuest(int eventId, String guestEmail) async {
    _setLoading(true);
    try {
      await _service.create(eventId, guestEmail);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // MÉTHODE : Vérifier un code QR (Organisateur)
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Envoie le code QR scanné au serveur pour vérification
  // 3. Si succès : sauvegarde le résultat, vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur et le met aussi dans verifyResult
  // 5. Désactive le mode "chargement"
  // 6. Retourne le message de résultat
  Future<String> verifyQrCode(String qrCode) async {
    _setLoading(true);
    try {
      _verifyResult = await _service.verifyQrCode(qrCode);
      _error = null;
      notifyListeners();
      return _verifyResult!;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg;
      _verifyResult = msg;
      notifyListeners();
      return msg;
    } finally {
      _setLoading(false);
    }
  }

  // MÉTHODE : Effacer le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // MÉTHODE PRIVÉE : Modifier l'état de chargement et prévenir l'interface
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
