/*
 * FICHIER : event_service.dart
 * RÔLE : Gère les appels au serveur pour tout ce qui concerne les événements
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier envoie les requêtes au serveur pour récupérer,
 * créer, modifier ou supprimer des événements. Il utilise ApiService pour communiquer.
 * Chaque méthode correspond à une action précise (voir, ajouter, modifier, supprimer).
 * UTILISÉ PAR : event_provider.dart (qui gère l'état des événements)
 */

import '../models/category.dart'; // Le modèle catégorie
import '../models/event.dart'; // Le modèle événement
import 'api_service.dart'; // Le service de communication HTTP

class EventService {
  // ── MÉTHODE : Récupérer tous les événements ─────────────────────────
  // CE QUE ÇA FAIT : Demande au serveur la liste de tous les événements
  // ROUTE : GET /events
  Future<List<Event>> getAll() async {
    final response = await ApiService.get('/events');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    // Convertit chaque élément JSON en objet Event
    return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── MÉTHODE : Récupérer un événement par son ID ────────────────────
  // CE QUE ÇA FAIT : Demande au serveur les détails d'un événement précis
  // ROUTE : GET /events/{id}
  Future<Event> getById(int id) async {
    final response = await ApiService.get('/events/$id');
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  // ── MÉTHODE : Créer un nouvel événement ───────────────────────────
  // CE QUE ÇA FAIT : Envoie les données d'un nouvel événement au serveur
  // ROUTE : POST /events
  Future<Event> create(EventRequest request) async {
    final response = await ApiService.post('/events', request.toJson());
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  // ── MÉTHODE : Modifier un événement existant ──────────────────────
  // CE QUE ÇA FAIT : Envoie les nouvelles données d'un événement au serveur
  // ROUTE : PUT /events/{id}
  Future<Event> update(int id, EventRequest request) async {
    final response = await ApiService.put('/events/$id', request.toJson());
    return Event.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }

  // ── MÉTHODE : Supprimer un événement ─────────────────────────────
  // CE QUE ÇA FAIT : Demande au serveur de supprimer un événement
  // ROUTE : DELETE /events/{id}
  Future<void> delete(int id) async {
    final response = await ApiService.delete('/events/$id');
    ApiService.parseResponse(response);
  }

  // ── MÉTHODE : Récupérer toutes les catégories ─────────────────────
  // CE QUE ÇA FAIT : Demande au serveur la liste des catégories d'événements
  // ROUTE : GET /categories
  Future<List<Category>> getCategories() async {
    final response = await ApiService.get('/categories');
    final list = ApiService.parseResponse(response) as List<dynamic>;
    return list
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  // ── MÉTHODE : Créer une nouvelle catégorie ────────────────────────
  // CE QUE ÇA FAIT : Envoie un nouveau nom de catégorie au serveur
  // ROUTE : POST /categories
  Future<Category> createCategory(String name) async {
    final response = await ApiService.post('/categories', {'name': name});
    return Category.fromJson(
        ApiService.parseResponse(response) as Map<String, dynamic>);
  }
}
