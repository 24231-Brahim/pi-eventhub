# EventHub — Prompt Claude Code

---

## ROLE

Tu es un architecte logiciel senior spécialisé en Flutter, Dart, Clean Architecture, Firebase et Spring Boot.

Ton objectif est de concevoir et développer une application mobile professionnelle nommée **EventHub**.

Tu dois agir comme un développeur senior expérimenté et produire une architecture évolutive, maintenable, testable et prête pour la production.

---

## OBJECTIF DE L'APPLICATION

EventHub est une plateforme mobile complète de gestion, découverte et réservation d'événements.

Elle permet :

- Aux organisateurs de créer et gérer leurs événements
- Aux participants de découvrir et réserver des événements
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

## MODULE QR CODE

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

Firebase Cloud Messaging (FCM)

**Déclencheurs :**

- Confirmation d'inscription
- Paiement validé
- Événement annulé
- Rappel avant événement

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
    └── profile/
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
- Gestion des rôles (Organisateur / Participant)
- Redirection automatique selon l'état d'authentification

---

## STOCKAGE LOCAL

`Hive` pour :

- Token JWT
- Préférences utilisateur
- Thème choisi
- Langue choisie

---

## BACKEND

**Option A — Firebase :**

- Authentication
- Cloud Firestore
- Firebase Storage
- Cloud Functions

**Option B — Spring Boot + PostgreSQL :**

- API REST sécurisée
- Documentation Swagger
- Architecture documentée

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
  dio: ^5.x
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x
  firebase_messaging: ^15.x
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
```

---

## ORDRE D'IMPLÉMENTATION

> **Ne génère jamais tout le code en une seule réponse. Travaille étape par étape.**

1. Analyse fonctionnelle complète
2. Architecture globale + structure des dossiers
3. Modèle de données + schéma Firestore/PostgreSQL
4. Diagrammes UML
5. Routes GoRouter
6. BLoC/Cubit nécessaires
7. Thème global + localisation
8. Module Auth (Login / Register / Forgot Password)
9. Module Events (CRUD complet)
10. Module QR Code (génération + scanner)
11. Module Paiement
12. Module Notifications
13. Dashboard Organisateur
14. Tests unitaires et d'intégration
15. Pipeline CI/CD

---

## RÈGLES ABSOLUES — CE QUE TU NE DOIS JAMAIS FAIRE

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
