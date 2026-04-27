/*
 * FICHIER : events_list_screen.dart
 * RÔLE : Affiche la liste de tous les événements disponibles
 * DESCRIPTION (POUR DÉBUTANTS) : C'est la page d'accueil après connexion.
 * Elle affiche tous les événements sous forme de cartes (cartes avec date, titre, lieu).
 * On peut rechercher un événement par titre ou lieu, et les organisateurs peuvent ajouter un nouvel événement.
 * Les invités peuvent accéder à leurs invitations via l'icône en haut à droite.
 * UTILISÉ PAR : main.dart (via le système de navigation)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventhub_app/l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import '../invitations/my_invitations_screen.dart';

// Widget principal de la liste des événements
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  // Contrôleur pour le champ de recherche
  final _searchCtrl = TextEditingController();
  // Texte de recherche saisi par l'utilisateur
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Quand l'écran s'affiche, on charge la liste des événements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    // Nettoie le contrôleur quand l'écran disparaît
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // Traductions
    final auth = context.watch<AuthProvider>(); // État d'authentification
    final events = context.watch<EventProvider>(); // État des événements
    final lang = context.read<LanguageProvider>(); // Gestionnaire de langue

    // Filtre les événements selon le texte de recherche (titre ou lieu)
    final filtered = events.events
        .where((e) =>
            e.title.toLowerCase().contains(_query.toLowerCase()) ||
            e.location.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Fond gris clair
      appBar: AppBar(
        title: Text(l.events, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Bouton de changement de langue
          _AppBarLangToggle(lang: lang),
          // Bouton "Mes invitations" (visible seulement pour les invités)
          if (!auth.isOrganizer)
            IconButton(
              icon: const Icon(Icons.confirmation_number_outlined),
              tooltip: l.myInvitations,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyInvitationsScreen()),
              ),
            ),
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l.logout,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                // Retourne à la page de connexion en vidant l'historique
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '${l.events}...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _query = v), // Met à jour la recherche
            ),
          ),
          // Bannière de bienvenue avec avatar et nom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  child: Text(
                    auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      auth.isOrganizer ? l.organizer : l.guest,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Liste des événements (ou chargement/erreur/vide)
          Expanded(
            child: events.loading
                ? const Center(child: CircularProgressIndicator()) // Chargement
                : events.error != null
                    ? _ErrorView( // Erreur
                        message: events.error!,
                        onRetry: () => context.read<EventProvider>().loadEvents())
                    : filtered.isEmpty
                        ? Center( // Aucun événement
                            child: Text(l.noEvents, style: const TextStyle(color: Colors.grey)))
                        : RefreshIndicator( // Liste avec pull-to-refresh
                            onRefresh: () => context.read<EventProvider>().loadEvents(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _EventCard(event: filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
      // Bouton flottant pour ajouter un événement (organisateurs seulement)
      floatingActionButton: auth.isOrganizer
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventFormScreen())),
              icon: const Icon(Icons.add),
              label: Text(l.addEvent),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

// Widget pour afficher une carte d'événement
class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push( // Clic sur la carte → détails
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bloc date (jour/mois)
              Container(
                width: 56, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(event.date.day.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(_monthAbbr(event.date.month),
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(event.location,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (event.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(event.categoryName!,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Renvoie l'abréviation du mois en français
  String _monthAbbr(int month) {
    const months = ['JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUI', 'JUI', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'];
    return months[month - 1];
  }
}

// Widget pour afficher une erreur avec bouton réessayer
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// Widget pour le bouton de changement de langue dans l'AppBar
class _AppBarLangToggle extends StatelessWidget {
  final LanguageProvider lang;
  const _AppBarLangToggle({required this.lang});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (code) => lang.setLocale(code),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'fr', child: Text('🇫🇷  Français')),
        const PopupMenuItem(value: 'ar', child: Text('🇩🇿  العربية')),
      ],
    );
  }
}
