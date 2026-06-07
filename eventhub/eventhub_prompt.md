# EventHub — Prompt Claude Code

---

## ROLE

Tu es un architecte logiciel senior spécialisé en Flutter, Dart, Clean Architecture et Supabase.

Ton objectif est de concevoir et développer une application mobile professionnelle nommée **EventHub**.

Tu dois agir comme un développeur senior expérimenté et produire une architecture évolutive, maintenable, testable et prête pour la production.

---

## OBJECTIF DE L'APPLICATION

EventHub est une plateforme mobile complète de gestion, découverte et réservation d'événements.

Elle permet :

- Aux **administrateurs** de gérer et superviser toute la plateforme
- Aux **organisateurs** de créer et gérer leurs événements
- Aux **participants** de découvrir et réserver des événements
- La génération et la validation de billets QR Code
- La gestion des paiements
- Le suivi statistique des événements

**Types d'événements :**

- Conférences
- Concerts
- Expositions
- Formations
- Ateliers
- Compétitions sportives
- Séminaires
- Événements communautaires

---

## RÔLES UTILISATEURS

### Organisateur

**Fonctionnalités :**

- Créer, modifier, supprimer un événement
- Publier ou dépublier un événement
- Définir un prix (gratuit ou payant)
- Gérer les participants inscrits
- Scanner les QR Codes pour valider les entrées
- Voir les statistiques

**Dashboard — afficher :**

- Nombre total d'événements
- Événements actifs / terminés
- Nombre d'inscriptions
- Revenus générés
- Taux de participation
- Revenus mensuels (graphique)

---

### Participant

**Fonctionnalités :**

- Parcourir et rechercher les événements
- Filtrer par : catégorie, date, ville, prix
- Réserver une place
- Payer un billet
- Ajouter aux favoris
- Voir ses billets et son historique
- Afficher son QR Code

---

### Admin (Super Administrateur)

> L'Admin est le responsable de la plateforme EventHub. Il dispose d'un accès total à toutes les données et fonctionnalités de l'application.

**Fonctionnalités :**

- Accéder à un dashboard d'administration global
- Gérer tous les utilisateurs (Organisateurs + Participants)
  - Voir la liste complète des utilisateurs
  - Activer / Désactiver un compte
  - Supprimer un compte
  - Changer le rôle d'un utilisateur
- Gérer tous les événements de la plateforme
  - Voir, modifier ou supprimer n'importe quel événement
  - Approuver ou rejeter les événements soumis par les organisateurs
  - Mettre en avant (featured) certains événements sur la Home
- Gérer les catégories d'événements
- Voir toutes les transactions et paiements
- Gérer les remboursements
- Envoyer des notifications globales à tous les utilisateurs
- Voir les statistiques globales de la plateforme

**Dashboard Admin — afficher :**

- Nombre total d'utilisateurs (par rôle)
- Nombre total d'événements (actifs / en attente / terminés)
- Revenus totaux de la plateforme
- Nouvelles inscriptions (graphique hebdomadaire)
- Événements en attente d'approbation
- Signalements et incidents

**Accès Admin :**

- L'Admin ne peut pas s'inscrire via l'interface publique
- Le compte Admin est créé manuellement dans Supabase (rôle défini dans la table `profiles`)
- L'interface Admin est une section séparée dans l'application, accessible uniquement si `role = 'admin'`
- GoRouter doit bloquer l'accès à toutes les routes Admin pour les autres rôles

---

## AUTHENTIFICATION

- **Méthode :** Email + Password uniquement
- Login / Register / Logout / Forgot Password
- Refresh Token + Session persistante
- Validation stricte : email valide, mot de passe fort
- **JWT obligatoire**

---

## MULTILINGUE

L'application doit être entièrement internationalisée.

**Langues minimum :**

- 🇫🇷 Français
- 🇬🇧 Anglais
- 🇸🇦 Arabe

**Exigences :**

- `flutter_localizations` + `intl` + fichiers ARB
- Changement dynamique de langue
- Persistance de la langue choisie
- Support RTL pour l'arabe

---

## THÈMES

- Light Mode et Dark Mode obligatoires
- Material Design 3
- Persistance du thème choisi
- Adaptation automatique au système

**Couleurs principales :**

- Violet : `#6C63FF`
- Blanc : `#FFFFFF`
- Accent CTA : `#FF6B35`

---

## RESPONSIVE DESIGN

L'application doit fonctionner sur téléphones et tablettes Android.

> **Règle stricte :** Ne jamais utiliser de dimensions fixes.

Utiliser :

- `LayoutBuilder`
- `MediaQuery`
- Responsive Breakpoints

---

## ÉCRANS COMMUNS

- Splash Screen
- Onboarding (3 pages)
- Login / Register / Forgot Password
- Profil utilisateur modifiable
- Paramètres (langue, thème)
- Notifications

---

## ÉCRANS PARTICIPANT

| Écran | Contenu |
|---|---|
| Home | Liste événements, recherche, filtres, pagination |
| Event Details | Image, description, date, lieu, prix, organisateur |
| Réservation | Formulaire + paiement |
| Mes Billets | Liste des billets avec QR |
| QR Code | Affichage plein écran, téléchargement, partage |
| Favoris | Liste des événements sauvegardés |

---

## ÉCRANS ORGANISATEUR

| Écran | Contenu |
|---|---|
| Dashboard | Statistiques complètes |
| Gestion événements | Créer / Modifier / Supprimer |
| Participants | Liste des inscrits par événement |
| Scanner QR | Caméra + validation temps réel |

---

## ÉCRANS ADMIN

| Écran | Contenu |
|---|---|
| Dashboard Global | Statistiques complètes de la plateforme |
| Gestion Utilisateurs | Liste, filtres, activation/désactivation, suppression |
| Détail Utilisateur | Profil, historique, rôle, statut |
| Gestion Événements | Tous les événements, approbation, mise en avant |
| Approbation Événement | Approuver / Rejeter avec motif |
| Gestion Paiements | Toutes les transactions, remboursements |
| Gestion Catégories | Ajouter / Modifier / Supprimer des catégories |
| Notifications Globales | Envoyer une notification à tous les utilisateurs |
| Rapports | Export des données (CSV) |

---



### Génération

Chaque billet génère un QR Code contenant :

```json
{
  "ticketId": "...",
  "eventId": "...",
  "userId": "...",
  "timestamp": "...",
  "paymentStatus": "..."
}
```

Package : `qr_flutter`

### Validation (Scanner)

Package : `mobile_scanner`

Résultats possibles :

- ✅ Valide
- ❌ Invalide
- ⚠️ Déjà utilisé

> **Règle critique :** La validation doit être effectuée **côté serveur**.  
> Ne jamais considérer un QR valide uniquement côté client.

---

## PAIEMENT

- Intégration **Stripe** (ou simulation Stripe pour le prototype)
- Événements gratuits → inscription directe
- Événements payants → flux paiement sécurisé avant génération du QR
- Confirmation + reçu par email
- Gestion des remboursements (annulation avant la date)

---

## NOTIFICATIONS

**Supabase Realtime** pour les mises à jour en temps réel.

**Déclencheurs :**

- Confirmation d'inscription
- Paiement validé
- Événement annulé
- Rappel avant événement

> Utiliser les **Supabase Edge Functions** pour envoyer des emails transactionnels (confirmation, reçu de paiement).

---

## ARCHITECTURE

Architecture obligatoire : **Clean Architecture**

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── shared/
│   ├── widgets/
│   ├── themes/
│   └── services/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── events/
    ├── bookings/
    ├── tickets/
    ├── payments/
    ├── notifications/
    ├── profile/
    └── admin/
        ├── data/
        ├── domain/
        └── presentation/
            ├── dashboard/
            ├── users/
            ├── events/
            ├── payments/
            ├── categories/
            └── notifications/
```

**Séparation stricte :**

- Data Layer (repositories, datasources, models)
- Domain Layer (entities, use cases, interfaces)
- Presentation Layer (screens, blocs, cubits)

---

## STATE MANAGEMENT

- `flutter_bloc` — Cubit et Bloc
- Ne jamais utiliser `setState` pour la logique métier
- Chaque écran doit gérer les états : Loading / Error / Success

---

## NAVIGATION

- `GoRouter` avec guards et routes nommées
- Gestion des rôles (Admin / Organisateur / Participant)
- Redirection automatique selon l'état d'authentification
- Routes Admin entièrement protégées : inaccessibles pour Organisateur et Participant

---

## STOCKAGE LOCAL

`Hive` pour :

- Token JWT
- Préférences utilisateur
- Thème choisi
- Langue choisie

---

## BACKEND

**Supabase uniquement** (pas de Firebase, pas de Spring Boot)

| Service Supabase | Usage |
|---|---|
| `supabase_flutter` | Client officiel Flutter |
| **Auth** | Email + Password, JWT, sessions persistantes |
| **PostgreSQL** | Base de données relationnelle principale |
| **Storage** | Images des événements et photos de profil |
| **Edge Functions** | Logique métier serveur (validation QR, paiement) |
| **Realtime** | Mises à jour en temps réel (inscriptions, notifications) |
| **Row Level Security (RLS)** | Sécurité des données par rôle (obligatoire) |

**Schéma PostgreSQL — tables principales :**

- `profiles` (id, role **[admin | organizer | participant]**, full_name, avatar_url, is_active)
- `events` (id, organizer_id, title, description, date, location, price, status, is_approved, is_featured)
- `bookings` (id, event_id, user_id, status, created_at)
- `tickets` (id, booking_id, qr_data, is_used, scanned_at)
- `payments` (id, booking_id, amount, status, stripe_id)
- `favorites` (id, user_id, event_id)
- `notifications` (id, user_id, title, body, is_read, is_global)
- `categories` (id, name, icon)
- `admin_logs` (id, admin_id, action, target_type, target_id, created_at)

> **Règle stricte :** Toutes les tables doivent avoir des politiques RLS activées.  
> Ne jamais accéder à la base de données sans passer par les politiques RLS.

---

## TESTS

| Type | Cible | Couverture |
|---|---|---|
| Unitaires | Use Cases, Repos, Services, Cubits | 80% minimum |
| Widget | Écrans critiques, formulaires, navigation | Tous les états Bloc |
| Intégration | Login, Réservation, Paiement, QR Check-In | Flux complets |

---

## CI/CD

Pipeline **GitHub Actions** :

1. Analyse statique (`flutter analyze`)
2. Formatage (`dart format`)
3. Tests unitaires
4. Tests widget
5. Build Android

> Le pipeline échoue si un test échoue.

---

## QUALITÉ DU CODE

- Principes SOLID, DRY, KISS
- Documentation DartDoc
- Null Safety strict
- Linting strict (`flutter_lints`)
- Aucune clé API exposée dans le code source

---

## PACKAGES PRINCIPAUX

```yaml
dependencies:
  flutter_bloc: ^8.x
  go_router: ^13.x
  supabase_flutter: ^2.x
  qr_flutter: ^4.x
  mobile_scanner: ^5.x
  image_picker: ^1.x
  cached_network_image: ^3.x
  intl: ^0.19.x
  flutter_localizations:
    sdk: flutter
  lottie: ^3.x
  shimmer: ^3.x
  hive: ^2.x
  hive_flutter: ^1.x
  flutter_stripe: ^10.x
```

---

## ORDRE D'IMPLÉMENTATION

> **Ne génère jamais tout le code en une seule réponse. Travaille étape par étape.**

1. Analyse fonctionnelle complète
2. Architecture globale + structure des dossiers
3. Modèle de données + schéma PostgreSQL Supabase + politiques RLS
4. Diagrammes UML
5. Routes GoRouter
6. BLoC/Cubit nécessaires
7. Thème global + localisation
8. Module Auth (Login / Register / Forgot Password + Guards par rôle)
9. Module Events (CRUD complet + approbation Admin)
10. Module QR Code (génération + scanner)
11. Module Paiement
12. Module Notifications (+ notifications globales Admin)
13. Dashboard Organisateur
14. **Module Admin** (Dashboard global, gestion utilisateurs, gestion événements, paiements)
15. Tests unitaires et d'intégration
16. Pipeline CI/CD

---

## RÈGLES ABSOLUES — CE QUE TU NE DOIS JAMAIS FAIRE

- ❌ Ne jamais permettre à un Organisateur ou Participant d'accéder aux routes Admin
- ❌ Ne jamais créer le compte Admin via l'interface d'inscription publique
- ❌ Ne jamais utiliser `setState` pour la logique métier
- ❌ Ne jamais mélanger UI, logique métier et accès aux données
- ❌ Ne jamais écrire du code non testé
- ❌ Ne jamais générer des fichiers géants de plusieurs milliers de lignes
- ❌ Ne jamais créer de dépendances circulaires
- ❌ Ne jamais stocker des mots de passe en clair
- ❌ Ne jamais valider les QR Codes uniquement côté client
- ❌ Ne jamais exposer des clés API dans le code source
- ❌ Ne jamais ignorer les erreurs réseau
- ❌ Ne jamais utiliser de données mockées dans la version finale
- ❌ Ne jamais créer d'écran sans gestion des états Loading / Error / Success
- ❌ Ne jamais utiliser des tailles fixes qui cassent le responsive design
- ❌ Ne jamais casser la Clean Architecture
- ❌ Ne jamais générer du code obsolète ou incompatible avec les dernières versions stables de Flutter et Dart
