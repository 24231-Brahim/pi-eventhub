/*
 * FICHIER : auth_provider.dart
 * RÔLE : Gère l'état de connexion (connecté ou déconnecté) et les informations utilisateur
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est comme un "tableau de bord" de l'utilisateur.
 * Il sait si on est connecté, quel est notre nom, notre email, notre rôle (organisateur ou invité).
 * Quand on se connecte ou s'inscrit, il met à jour ces informations et prévient toute l'application.
 * UTILISÉ PAR : Toutes les pages qui ont besoin de savoir qui est connecté
 */

import 'package:flutter/material.dart'; // Pour ChangeNotifier
import '../models/user.dart'; // Le modèle de données utilisateur
import '../services/api_service.dart'; // Pour supprimer le token
import '../services/auth_service.dart'; // Pour appeler le serveur

class AuthProvider extends ChangeNotifier {
  // Le service qui gère les appels au serveur pour l'authentification
  final AuthService _authService = AuthService();

  // Les données de l'utilisateur connecté (null si déconnecté)
  AuthResponse? _auth;
  // Indique si une opération est en cours (connexion/inscription)
  bool _loading = false;
  // Message d'erreur éventuel
  String? _error;

  // ── GETTERS (POUR LIRE LES INFORMATIONS) ─────────────────────────

  // Renvoie les données complètes de l'utilisateur connecté
  AuthResponse? get auth => _auth;

  // Indique si une opération est en cours (pour afficher un chargement)
  bool get loading => _loading;

  // Renvoie le message d'erreur (null si pas d'erreur)
  String? get error => _error;

  // Indique si l'utilisateur est connecté (auth n'est pas null)
  bool get isLoggedIn => _auth != null;

  // Indique si l'utilisateur a le rôle ORGANIZER (organisateur)
  bool get isOrganizer => _auth?.role == 'ORGANIZER';

  // Renvoie le nom de l'utilisateur connecté (chaîne vide si déconnecté)
  String get userName => _auth?.name ?? '';

  // Renvoie l'email de l'utilisateur connecté (chaîne vide si déconnecté)
  String get userEmail => _auth?.email ?? '';

  // ── MÉTHODES (POUR MODIFIER L'ÉTAT) ─────────────────────────────

  // MÉTHODE : Connecter un utilisateur
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Appelle le serveur pour vérifier l'email et le mot de passe
  // 3. Si succès : sauvegarde les données, vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur
  // 5. Désactive le mode "chargement"
  // 6. Prévient toute l'application que quelque chose a changé
  Future<bool> login(String email, String password) async {
    _setLoading(true); // Affiche le chargement
    try {
      _auth = await _authService.login(email, password);
      _error = null; // Pas d'erreur
      notifyListeners(); // Prévient l'application (ex: pour afficher la page d'accueil)
      return true; // Succès
    } catch (e) {
      // En cas d'erreur, on récupère le message (sans le mot "Exception: ")
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners(); // Prévient l'application (pour afficher l'erreur)
      return false; // Échec
    } finally {
      _setLoading(false); // Cache le chargement
    }
  }

  // MÉTHODE : Inscire un nouvel utilisateur
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Appelle le serveur pour créer le compte
  // 3. Si succès : sauvegarde les données, vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur
  // 5. Désactive le mode "chargement"
  Future<bool> register(
      String name, String email, String password, String role) async {
    _setLoading(true);
    try {
      _auth = await _authService.register(name, email, password, role);
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

  // MÉTHODE : Déconnecter l'utilisateur
  // CE QUE ÇA FAIT : Supprime le token et remet tout à zéro
  Future<void> logout() async {
    await _authService.logout(); // Supprime le token du téléphone
    _auth = null; // Plus d'utilisateur connecté
    _error = null; // Plus d'erreur
    notifyListeners(); // Prévient l'application (pour afficher la page de connexion)
  }

  // MÉTHODE : Effacer le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // MÉTHODE PRIVÉE : Modifier l'état de chargement et prévenir l'application
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
