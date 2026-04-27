/*
 * FICHIER : event_provider.dart
 * RÔLE : Gère l'état des événements (liste, chargement, erreurs)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est le "centre de données" pour les événements.
 * Il garde en mémoire la liste des événements, les catégories, et gère le chargement.
 * Quand on crée/modifie/supprime un événement, il met à jour sa liste locale
 * et prévient l'interface graphique de se rafraîchir.
 * UTILISÉ PAR : Toutes les pages qui affichent ou modifient des événements
 */

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  // Le service qui communique avec le serveur
  final EventService _eventService = EventService();

  // La liste des événements (stockée en mémoire)
  List<Event> _events = [];
  // La liste des catégories d'événements
  List<Category> _categories = [];
  // Indique si une opération est en cours (chargement)
  bool _loading = false;
  // Message d'erreur éventuel
  String? _error;

  // ── GETTERS (POUR LIRE LES DONNÉES) ──────────────────────────

  // Renvoie la liste des événements
  List<Event> get events => _events;

  // Renvoie la liste des catégories
  List<Category> get categories => _categories;

  // Indique si une opération est en cours (pour afficher un chargement)
  bool get loading => _loading;

  // Renvoie le message d'erreur (null si pas d'erreur)
  String? get error => _error;

  // ── MÉTHODES (POUR MODIFIER LES DONNÉES) ─────────────────────

  // MÉTHODE : Charger tous les événements depuis le serveur
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Demande au serveur la liste des événements via EventService
  // 3. Si succès : sauvegarde la liste, vide l'erreur
  // 4. Si échec : sauvegarde le message d'erreur
  // 5. Désactive le mode "chargement"
  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      _events = await _eventService.getAll();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // MÉTHODE : Charger les catégories depuis le serveur
  // CE QUE ÇA FAIT : Récupère la liste des catégories (Musique, Sport, etc.)
  Future<void> loadCategories() async {
    try {
      _categories = await _eventService.getCategories();
      notifyListeners(); // Prévient l'interface de se rafraîchir
    } catch (_) {}
  }

  // MÉTHODE : Créer un nouvel événement
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Envoie les données au serveur via EventService
  // 3. Si succès : ajoute le nouvel événement au début de la liste locale
  // 4. Si échec : sauvegarde l'erreur
  // 5. Désactive le mode "chargement"
  // 6. Retourne true si succès, false si échec
  Future<bool> createEvent(EventRequest request) async {
    _setLoading(true);
    try {
      final newEvent = await _eventService.create(request);
      // Ajoute le nouvel événement au début de la liste (pour l'afficher en premier)
      _events = [newEvent, ..._events];
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

  // MÉTHODE : Modifier un événement existant
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Envoie les nouvelles données au serveur
  // 3. Si succès : remplace l'ancien événement par le nouveau dans la liste locale
  // 4. Si échec : sauvegarde l'erreur
  // 5. Désactive le mode "chargement"
  Future<bool> updateEvent(int id, EventRequest request) async {
    _setLoading(true);
    try {
      final updated = await _eventService.update(id, request);
      // Trouve l'index de l'événement à modifier
      final idx = _events.indexWhere((e) => e.id == id);
      if (idx != -1) _events[idx] = updated; // Remplace par la version modifiée
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

  // MÉTHODE : Supprimer un événement
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Active le mode "chargement"
  // 2. Demande au serveur de supprimer l'événement
  // 3. Si succès : retire l'événement de la liste locale
  // 4. Si échec : sauvegarde l'erreur
  // 5. Désactive le mode "chargement"
  Future<bool> deleteEvent(int id) async {
    _setLoading(true);
    try {
      await _eventService.delete(id);
      // Retire l'événement de la liste locale
      _events.removeWhere((e) => e.id == id);
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
