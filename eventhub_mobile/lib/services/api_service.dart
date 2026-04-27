/*
 * FICHIER : api_service.dart
 * RÔLE : Gère toutes les communications HTTP avec le serveur backend
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est le "messager" de l'application.
 * Il envoie des requêtes au serveur (GET, POST, PUT, DELETE) et reçoit les réponses.
 * Il ajoute automatiquement le token JWT dans les requêtes pour prouver qu'on est connecté.
 * Il gère aussi le stockage du token dans le téléphone (SharedPreferences).
 * UTILISÉ PAR : auth_service.dart, event_service.dart, invitation_service.dart
 */

import 'dart:convert'; // Pour convertir les données en JSON
import 'package:http/http.dart' as http; // Client HTTP pour faire des requêtes
import 'package:shared_preferences/shared_preferences.dart'; // Stockage local

import 'package:flutter/foundation.dart' show kIsWeb; // Pour savoir si on est sur le web

class ApiService {
  // L'adresse du serveur backend (le même ordinateur en développement)
  // En production, on changerait cette adresse par celle du vrai serveur
  static String get baseUrl {
    // Le backend tourne sur le port 9090
    return 'http://localhost:9090/api';
  }

  // Clé pour stocker le token JWT dans le téléphone
  static const String _tokenKey = 'jwt_token';

  // ── GESTION DU TOKEN JWT ──────────────────────────────────────────────

  // Sauvegarde le token JWT dans le stockage local du téléphone
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupère le token JWT stocké dans le téléphone
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprime le token JWT (quand on se déconnecte)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── EN-TÊTES HTTP (Headers) ──────────────────────────────────────────

  // Prépare les en-têtes avec le token JWT (pour les requêtes authentifiées)
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json', // On envoie du JSON
      if (token != null) 'Authorization': 'Bearer $token', // Le token JWT
    };
  }

  // En-têtes simples (pour les requêtes publiques comme l'inscription)
  static Map<String, String> _publicHeaders() => {
        'Content-Type': 'application/json',
      };

  // ── MÉTHODES HTTP (GET, POST, PUT, DELETE) ─────────────────────────

  // Envoie une requête GET (pour récupérer des données)
  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders(); // Ajoute le token
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  // Envoie une requête POST (pour créer quelque chose)
  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool authenticated = true}) async {
    final headers =
        authenticated ? await _authHeaders() : _publicHeaders();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body), // Convertit le corps en JSON
    );
  }

  // Envoie une requête PUT (pour modifier quelque chose)
  static Future<http.Response> put(
      String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Envoie une requête DELETE (pour supprimer quelque chose)
  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }

  // ── AIDE POUR TRAITER LES RÉPONSES ─────────────────────────────────

  // Analyse la réponse du serveur et renvoie les données ou lance une erreur
  static dynamic parseResponse(http.Response response) {
    // Décode correctement les caractères spéciaux (accents, arabe, etc.)
    final body = utf8.decode(response.bodyBytes);

    // Si la réponse est réussie (code 200-299)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null; // Pas de contenu
      return jsonDecode(body); // Renvoie les données JSON décodées
    }

    // En cas d'erreur, on essaie de récupérer le message d'erreur du serveur
    String message = 'Request failed (${response.statusCode})';
    try {
      final errorBody = jsonDecode(body) as Map<String, dynamic>;
      message = errorBody['error'] as String? ??
          errorBody['message'] as String? ??
          message;
    } catch (_) {}
    throw Exception(message); // Lance une erreur avec le message
  }
}
