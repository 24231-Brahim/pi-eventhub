/*
 * FICHIER : main.dart
 * RÔLE : Point d'entrée principal de l'application Flutter (comme le "bouton ON" de l'app)
 * DESCRIPTION (POUR DÉBUTANTS) : Ce fichier est le premier qui s'exécute quand on lance l'application.
 * Il fait 3 choses importantes :
 * 1. Initialise les paramètres de langue (français ou arabe)
 * 2. Met en place les "providers" (comme des réservoirs de données partagées)
 * 3. Lance l'interface graphique avec le thème visuel et la première page (LoginScreen)
 * UTILISÉ PAR : Flutter au démarrage de l'application
 */

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/invitation_provider.dart';
import 'providers/language_provider.dart';
import 'views/auth/login_screen.dart';

// Fonction principale : c'est le point de départ de l'application
void main() async {
  // S'assure que Flutter est bien initialisé avant de faire quoi que ce soit
  WidgetsFlutterBinding.ensureInitialized();

  // Crée et initialise le gestionnaire de langue (français ou arabe)
  final langProvider = LanguageProvider();
  await langProvider.init(); // Charge la langue sauvegardée (ou français par défaut)

  // Lance l'application avec les "providers" (conteneurs de données)
  runApp(
    // MultiProvider permet de partager des données entre plusieurs pages
    MultiProvider(
      providers: [
        // Fournit le gestionnaire de langue à toute l'application
        ChangeNotifierProvider.value(value: langProvider),
        // Fournit l'état d'authentification (connecté ou non)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Fournit la liste des événements
        ChangeNotifierProvider(create: (_) => EventProvider()),
        // Fournit la liste des invitations
        ChangeNotifierProvider(create: (_) => InvitationProvider()),
      ],
      // L'application principale
      child: const EventHubApp(),
    ),
  );
}

// Widget principal de l'application
class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupère le gestionnaire de langue depuis le provider
    final lang = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'EventHub',
      // Enlève le bandeau "Debug" en haut à droite
      debugShowCheckedModeBanner: false,

      // ── THÈME VISUEL DE L'APPLICATION ────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        // Couleurs principales (indigo et violet)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0), // Indigo
          secondary: const Color(0xFF7E57C2), // Violet
          brightness: Brightness.light,
        ),
        // Police d'écriture (Cairo pour supporter l'arabe)
        fontFamily: 'Cairo',
        // Style des textes
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        // Style des champs de saisie
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        // Style des cartes
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18))),
        ),
        // Style des boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        // Style de la barre d'application (AppBar)
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      // ── PARAMÈTRES DE LANGUE (FRANÇAIS / ARABE) ─────────────────────
      // La langue actuelle (français ou arabe)
      locale: lang.locale,
      // Les délégués de localisation (pour charger les traductions)
      localizationsDelegates: [
        AppLocalizations.delegate, // Nos traductions personnalisées
        GlobalMaterialLocalizations.delegate, // Traductions de Flutter (dates, boutons)
        GlobalWidgetsLocalizations.delegate, // Suppo rt RTL/LTR
        GlobalCupertinoLocalizations.delegate, // Pour iOS
      ],
      // Les langues supportées
      supportedLocales: const [
        Locale('fr'), // Français
        Locale('ar'), // Arabe
      ],

      // ── SUPPORT DE L'ARABE (LECTURE DE DROITE À GAUCHE) ────────────
      builder: (context, child) {
        final isAr = lang.locale.languageCode == 'ar';
        return Directionality(
          // Si c'est l'arabe, le texte va de droite à gauche (RTL)
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      // ── PREMIÈRE PAGE AFFICHÉE ──────────────────────────────────────
      // Au lancement, on affiche l'écran de connexion
      home: const LoginScreen(),
    );
  }
}
