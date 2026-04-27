/*
 * FICHIER : auth_service.dart
 * RÔLE : Gère les appels au serveur pour l'inscription et la connexion
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier fait le lien entre l'application mobile et le serveur.
 * Il envoie les identifiants au serveur, reçoit le token JWT (la "clé d'accès"),
 * et le sauvegarde dans le téléphone pour les prochaines requêtes.
 * UTILISÉ PAR : auth_provider.dart (qui gère l'état de connexion)
 */

import '../models/user.dart'; // Le modèle de données utilisateur
import 'api_service.dart'; // Le service de communication HTTP

class AuthService {
  // ── MÉTHODE : Connexion d'un utilisateur ──────────────────────────
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Envoie l'email et le mot de passe au serveur (POST /auth/login)
  // 2. Le serveur vérifie et renvoie un token JWT + infos utilisateur
  // 3. On sauvegarde le token dans le téléphone (pour rester connecté)
  // 4. On renvoie les informations de l'utilisateur connecté
  Future<AuthResponse> login(String email, String password) async {
    // Envoie la requête au serveur (sans token car on n'est pas encore connecté)
    final response = await ApiService.post(
      '/auth/login',
      {'email': email, 'password': password},
      authenticated: false, // Pas besoin de token pour se connecter
    );

    // Analyse la réponse du serveur
    final responseData = ApiService.parseResponse(response) as Map<String, dynamic>;
    // Récupère les données dans le champ "data" de la réponse
    final data = responseData['data'] as Map<String, dynamic>;
    // Convertit les données JSON en objet AuthResponse
    final auth = AuthResponse.fromJson(data);

    // Sauvegarde le token JWT dans le téléphone (SharedPreferences)
    await ApiService.saveToken(auth.token);

    // Renvoie les informations de l'utilisateur connecté
    return auth;
  }

  // ── MÉTHODE : Inscription d'un nouvel utilisateur ───────────────────
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Envoie les infos d'inscription au serveur (POST /auth/register)
  // 2. Le serveur crée le compte et renvoie un token JWT + infos
  // 3. On sauvegarde le token dans le téléphone
  // 4. On renvoie les informations du nouvel utilisateur
  Future<AuthResponse> register(
      String name, String email, String password, String role) async {
    // Envoie la requête au serveur
    final response = await ApiService.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'role': role, // ORGANIZER ou GUEST
      },
      authenticated: false, // Pas besoin de token pour s'inscrire
    );

    // Analyse la réponse du serveur
    final responseData = ApiService.parseResponse(response) as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(data);

    // Sauvegarde le token JWT
    await ApiService.saveToken(auth.token);

    return auth;
  }

  // ── MÉTHODE : Déconnexion ─────────────────────────────────────────
  // CE QUE ÇA FAIT : Supprime le token JWT du téléphone
  // L'utilisateur ne sera plus connecté
  Future<void> logout() async {
    await ApiService.clearToken();
  }
}
