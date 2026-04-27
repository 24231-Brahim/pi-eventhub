/*
 * FICHIER : language_provider.dart
 * RÔLE : Gère le changement de langue dans l'application (Français ↔ Arabe)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier permet à l'utilisateur de changer
 * la langue de l'application. La langue choisie est sauvegardée dans le téléphone
 * (SharedPreferences) pour être conservée quand on ferme l'application.
 * UTILISÉ PAR : main.dart (pour configurer l'app) et tous les écrans (boutons de changement)
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // La langue actuelle (par défaut : Français)
  Locale _locale = const Locale('fr');
  // Clé pour sauvegarder la langue dans le téléphone
  static const _key = 'app_locale';

  // Renvoie la langue actuelle
  Locale get locale => _locale;

  // Initialise la langue au démarrage de l'application
  // CE QUE ÇA FAIT : Récupère la langue sauvegardée ou utilise le français par défaut
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_key) ?? 'fr'; // Par défaut : français
    _locale = Locale(lang);
    notifyListeners(); // Prévient l'application du changement
  }

  // Change la langue de l'application
  // CE QUE ÇA FAIT ÉTAPE PAR ÉTAPE :
  // 1. Met à jour la langue en mémoire
  // 2. Sauvegarde le choix dans le téléphone
  // 3. Prévient toute l'application (pour recharger les textes)
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode); // Sauvegarde permanente
    notifyListeners(); // L'interface se met à jour automatiquement
  }
}
