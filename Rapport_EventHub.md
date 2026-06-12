# Rapport de Projet — EventHub

**Plateforme mobile de gestion, découverte et réservation d'événements**

---

## Introduction

EventHub est une application mobile cross-platform de gestion d'événements développée avec Flutter et Supabase. Elle permet à trois types d'acteurs (administrateurs, organisateurs et participants) de gérer, découvrir, réserver et valider des événements via un système de billetterie basé sur des codes QR. Le projet adopte une architecture Clean Architecture avec gestion d'état via BLoC, injection de dépendances avec GetIt, et une base de données PostgreSQL hébergée sur Supabase avec des politiques de sécurité Row Level Security (RLS). L'application supporte trois langues (français, anglais, arabe) et propose un thème Material 3 avec mode clair/sombre. Ce rapport présente le contexte, la méthodologie, les réalisations techniques et les fonctionnalités principales de l'application.

---

## Chapitre 1 : Contexte et problématique

### 1.1 Contexte

La gestion d'événements (conférences, concerts, formations, ateliers, etc.) implique de multiples acteurs et processus : création d'événements, inscription des participants, réservation de billets, paiement, validation d'entrée, notifications, et suivi statistique. Les solutions existantes sont souvent lourdes, coûteuses, ou ne couvrent pas l'ensemble du cycle de vie d'un événement.

Le projet EventHub a été conçu dans le cadre d'un projet de développement logiciel pour répondre à ce besoin. L'objectif est de fournir une solution mobile complète, moderne et accessible, permettant :

- Aux **organisateurs** de créer, publier et gérer leurs événements ;
- Aux **participants** de découvrir et réserver des événements ;
- Aux **administrateurs** de superviser l'ensemble de la plateforme.

L'application se veut cross-platform (Android, iOS, Web, bureau), multilingue, et dotée d'une architecture robuste et maintenable.

### 1.2 Problématique

La problématique centrale est la suivante :

> **Comment concevoir et développer une plateforme mobile de gestion d'événements complète, sécurisée, multilingue et maintenable, couvrant l'ensemble du cycle de vie d'un événement — de la création à la validation des billets — tout en garantissant une expérience utilisateur fluide et une architecture évolutive ?**

Cette problématique se décline en plusieurs sous-questions :
- Comment assurer une séparation claire des responsabilités et une maintenabilité du code ?
- Comment garantir la sécurité des données via des politiques d'accès fines ?
- Comment offrir une expérience utilisateur riche et réactive sur plusieurs plateformes ?
- Comment gérer la billetterie avec validation par QR code ?
- Comment supporter le multilinguisme (français, anglais, arabe) ?

### 1.3 Objectifs du projet

#### 1.3.1 Objectif général

Développer une application mobile cross-platform complète de gestion d'événements permettant à trois types d'utilisateurs (administrateur, organisateur, participant) d'interagir autour du cycle de vie complet d'un événement : création, publication, réservation, paiement, billetterie QR, validation et suivi analytique.

#### 1.3.2 Objectifs spécifiques

1. **Authentification et gestion des rôles** : Mettre en place un système d'authentification sécurisé (email/mot de passe) avec trois rôles distincts (admin, organizer, participant) et des routes protégées.
2. **Gestion des événements** : Permettre aux organisateurs de créer, modifier, publier et gérer des événements avec différentes catégories, statuts et visibilités (public/privé).
3. **Système de réservation et billetterie** : Implémenter un système de réservation avec génération de billets contenant des codes QR uniques.
4. **Validation par QR code** : Développer un scanner QR permettant aux organisateurs de valider les billets des participants en temps réel.
5. **Système de paiement** : Intégrer un flux de paiement (simulé) pour les événements payants avec gestion des statuts.
6. **Notifications** : Notifier les utilisateurs des changements de statut des réservations et des événements.
7. **Panneau d'administration** : Fournir un tableau de bord complet avec analytics, gestion des utilisateurs, des événements et des réservations.
8. **Support multilingue** : Proposer l'application en français, anglais et arabe (avec support RTL).
9. **Tests et déploiement** : Assurer la qualité via des tests automatisés et un pipeline CI/CD.

### 1.4 Les diagrammes

#### 1.4.1 Description des cas d'utilisation

L'application EventHub définit trois acteurs principaux avec les cas d'utilisation suivants :

**Participant :**
- Créer un compte et se connecter
- Parcourir et rechercher des événements par catégorie
- Filtrer les événements (par date, lieu, prix, etc.)
- Ajouter des événements aux favoris
- Réserver des billets (gratuits ou payants)
- Payer pour des événements payants
- Consulter ses billets avec code QR
- Participer à des événements privés sur invitation
- Modifier son profil (photo, nom, téléphone)
- Changer la langue et le thème de l'application
- Consulter ses notifications

**Organisateur :**
- Créer et gérer ses événements
- Définir la visibilité (public/privé)
- Inviter des participants par email (individuel ou CSV)
- Consulter un tableau de bord avec statistiques
- Scanner et valider les billets des participants
- Gérer les réservations

**Administrateur :**
- Accéder au panneau d'administration complet
- Gérer les utilisateurs (rôles, activation/désactivation)
- Approuver ou rejeter les événements avec motif
- Consulter les analytics (revenus, engagement, tendances)
- Superviser l'ensemble des réservations et billets

#### 1.4.2 Diagramme de classes

Le diagramme de classes principal de l'application comprend les entités suivantes :

- **User** : id, email, name, phone, photoUrl, role (enum : admin/organizer/participant), isActive, createdAt
- **Event** : id, title, description, imageUrl, date, endDate, location, city, price, maxParticipants, currentParticipants, category (enum), status (enum : draft/published/cancelled/completed), organizerId, organizerName, isFeatured, isPrivate, rejectionReason, createdAt, updatedAt
- **Booking** : id, eventId, userId, quantity, totalAmount, status (enum : pending/confirmed/cancelled/refunded), createdAt
- **Ticket** : id, eventId, userId, bookingId, qrCode, status (enum : active/used/cancelled), createdAt
- **Payment** : id, bookingId, amount, currency, status (enum : pending/completed/failed/refunded), stripePaymentIntentId, createdAt
- **AppNotification** : id, userId, title, body, type (enum), data, isRead, createdAt
- **EventInvitation** : id, eventId, email, name, status (enum : pending/accepted/declined), createdAt
- **Favorite** : id, userId, eventId, createdAt

Les relations entre entités :
- Un **User** peut créer plusieurs **Event** (en tant qu'organisateur)
- Un **User** peut effectuer plusieurs **Booking**
- Un **User** peut avoir plusieurs **Ticket** et **AppNotification**
- Un **Event** peut avoir plusieurs **Booking**, **Ticket**, **EventInvitation** et **Favorite**
- Un **Booking** est lié à un **Payment** et plusieurs **Ticket**

---

## Chapitre 2 : Méthodologie et Réalisation Technique

### 2.1 Méthodologie

Le projet a été développé selon une approche **Clean Architecture** couplée au pattern **BLoC (Business Logic Component)** pour la gestion d'état. Cette méthodologie garantit :

- **La séparation des préoccupations** : Chaque fonctionnalité est divisée en trois couches (présentation, domaine, données).
- **La testabilité** : Les couches sont indépendantes et testables unitairement grâce à l'injection de dépendances.
- **La maintenabilité** : Le code est organisé par fonctionnalité, facilitant les évolutions.
- **L'évolutivité** : L'architecture permet d'ajouter facilement de nouvelles fonctionnalités.

Le développement s'est fait de manière itérative, en commençant par le noyau (core) et l'authentification, puis en ajoutant progressivement les fonctionnalités métier (événements, réservations, billets, paiements, notifications, administration).

### 2.2 Démarche de développement

La démarche de développement s'est articulée autour des étapes suivantes :

1. **Conception et modélisation** : Création des diagrammes (architecture, classes, cas d'utilisation, séquence, navigation, sécurité, base de données).
2. **Mise en place du socle technique** : Initialisation du projet Flutter, configuration de Supabase (authentification, base de données PostgreSQL, stockage), mise en place de l'architecture Clean Architecture et des dossiers.
3. **Développement du noyau (core)** : Implémentation des composants transversaux (gestion des erreurs, connectivité réseau, routeur, injection de dépendances, thèmes, widgets partagés, localisation).
4. **Module d'authentification** : Création du système d'authentification avec inscription, connexion, mot de passe oublié, persistance de session et protection des routes.
5. **Module des événements** : Développement du CRUD complet des événements, recherche et filtres, favoris, et tableau de bord organisateur.
6. **Module des réservations et billets** : Implémentation du système de réservation, génération de QR codes, scanner de validation.
7. **Module des paiements** : Intégration du flux de paiement simulé avec gestion des statuts.
8. **Module des notifications** : Système de notifications in-app avec indicateurs de lecture.
9. **Module d'administration** : Panneau d'administration complet (dashboard, utilisateurs, événements, réservations, billets, analytics).
10. **Tests et validation** : Écriture de tests unitaires et widget (~125+ tests), analyse statique du code, pipeline CI/CD.
11. **Internationalisation** : Traduction de l'application en français, anglais et arabe.

### 2.3 Outils et technologies utilisés

**Frontend (Flutter) :**

| Technologie | Rôle |
|---|---|
| Dart 3.12 | Langage de programmation |
| Flutter 3.29 | Framework cross-platform |
| flutter_bloc 8.x | Gestion d'état (BLoC Pattern) |
| go_router 14.x | Navigation avec guards d'authentification |
| supabase_flutter 2.x | Client Supabase (Auth, DB, Storage) |
| get_it 8.x | Injection de dépendances |
| dartz 0.10 | Gestion fonctionnelle des erreurs (Either) |
| equatable 2.x | Égalité structurelle |
| json_annotation 4.x | Sérialisation JSON |
| shared_preferences | Stockage local (thème, langue) |
| flutter_secure_storage | Stockage sécurisé des tokens JWT |
| connectivity_plus | Vérification de connectivité réseau |
| qr_flutter 4.x | Génération de codes QR |
| mobile_scanner 6.x | Scan de codes QR via caméra |
| image_picker | Sélection de photos |
| cached_network_image | Cache d'images réseau |
| lottie 3.x | Animations Lottie |
| shimmer 3.x | Effets de chargement |
| flutter_screenutil | Design responsive |
| flutter_svg | Rendu SVG |
| share_plus | Partage d'événements |
| file_picker / csv | Import CSV d'invitations |
| intl / flutter_localizations | Internationalisation |
| hive / hive_flutter | Cache local |

**Backend (Supabase) :**

| Technologie | Rôle |
|---|---|
| Supabase Auth | Authentification (email/mot de passe, JWT) |
| Supabase PostgreSQL | Base de données relationnelle avec RLS |
| Supabase Storage | Hébergement d'images |
| Supabase Realtime | Notifications en temps réel |

**Tests et qualité :**

| Technologie | Rôle |
|---|---|
| flutter_test | Tests unitaires et widget |
| bloc_test 9.x | Tests de blocs |
| mocktail 1.x | Mocking |
| flutter_lints | Règles de linting |

**CI/CD :**
- GitHub Actions : analyse statique (`flutter analyze`) + exécution des tests (`flutter test`) sur Ubuntu avec Flutter 3.29.0 stable

### 2.4 Références du projet

- **Dépôt GitHub** : Projet hébergé sous licence MIT
- **Documentation technique** : FICHE_EXTRACTION_EVENTHUB.md (1316 lignes avec 20+ diagrammes Mermaid)
- **Spécifications fonctionnelles** : eventhub_prompt.md (488 lignes)
- **Guide de démarrage** : README.md
- **Notes de développement** : CONTINUE.md
- **État d'avancement** : TODO.md (356 lignes par fonctionnalité)
- **Design UI/UX** : PROMPT_FRONT.md avec palette de couleurs et spécifications d'écrans
- **Schéma base de données** : supabase_schema.sql (372 lignes avec politiques RLS)
- **Design export** : stitch_eventhub_booking_platform.zip

---

## Chapitre 3 : Résolution

### 3.1 Fonctionnalités principales réalisées

L'application EventHub a été développée avec succès et comprend les fonctionnalités suivantes :

1. **Authentification complète** : Inscription, connexion, déconnexion, mot de passe oublié, persistance de session JWT, protection des routes par rôle.

2. **Gestion des événements** : CRUD complet avec 8 catégories (conférence, concert, exposition, formation, atelier, sports, séminaire, communauté), 4 statuts (brouillon, publié, annulé, terminé), visibilité publique/privée, et invitation par email (individuelle ou import CSV).

3. **Réservation et billetterie** : Réservation avec validation des contraintes (capacité, date, statut), génération automatique de code QR unique par billet, affichage plein écran du QR.

4. **Scanner et validation QR** : Scan via caméra avec debounce de 2 secondes, validation côté serveur avec détection du statut (actif, utilisé, annulé), dialogues distincts pour chaque cas.

5. **Paiement** : Flux de paiement simulé (Stripe Intent) pour événements payants, contournement pour événements gratuits, gestion des statuts (en attente, complété, échoué, remboursé).

6. **Notifications in-app** : 5 types de notifications (confirmation réservation, paiement confirmé, événement annulé, rappel, général), indicateurs de lecture, swipe-to-dismiss.

7. **Profil utilisateur** : Affichage et modification (nom, téléphone, photo via Supabase Storage), changement de thème (clair/sombre) et de langue (FR/EN/AR).

8. **Panneau d'administration** : 6 pages (dashboard avec statistiques, gestion des utilisateurs, revue des événements avec approbation/rejet, supervision des réservations et billets, analytics).

9. **Multilinguisme** : 161+ clés de traduction par langue (français, anglais, arabe avec support RTL).

10. **Tests et qualité** : 125+ tests unitaires et widget, pipeline CI/CD avec analyse statique et tests automatisés.

### 3.2 Illustrations de l'application

Voici les principales interfaces de l'application :

| Page | Description |
|---|---|
| **Splash Screen** | Écran de démarrage avec animation Lottie (2 secondes) |
| **Onboarding** | Carousel de 3 pages de présentation |
| **Connexion / Inscription** | Formulaire avec validation (email, mot de passe, confirmation) |
| **Mot de passe oublié** | Envoi d'email de réinitialisation |
| **Accueil (4 tabs)** | Navigation inférieure : Événements, Billets, Notifications, Profil |
| **Liste des événements** | Grille/liste avec recherche, filtres par catégorie |
| **Détail d'un événement** | Image, description, date, lieu, prix, réservation, favoris |
| **Réservation** | Sélection de quantité, résumé, paiement si payant |
| **QR Code billet** | Affichage plein écran du QR avec informations |
| **Scanner QR** | Scan via caméra avec retour visuel |
| **Profil** | Photo, informations, modification |
| **Paramètres** | Thème (clair/sombre), langue (FR/EN/AR) |
| **Dashboard organisateur** | Statistiques des événements de l'organisateur |
| **Création d'événement** | Formulaire complet avec catégorie, date, prix, image |
| **Panneau admin** | Dashboard, utilisateurs, événements, réservations, tickets, analytics |

---

## Conclusion

Le projet EventHub a permis de développer une application mobile cross-platform complète de gestion d'événements, répondant aux besoins des trois types d'acteurs identifiés : administrateurs, organisateurs et participants.

**Les principaux résultats obtenus sont :**

- Une architecture **Clean Architecture / BLoC** robuste, maintenable et testable, avec 8 modules fonctionnels indépendants.
- Une application **cross-platform** (Android, iOS, Web, bureau) avec une seule base de code Dart.
- Un système de **billetterie QR** complet : génération, affichage et validation par scan caméra.
- Un **support multilingue** (français, anglais, arabe avec RTL) pour une accessibilité élargie.
- Un **panneau d'administration** complet avec analytics et gestion de la plateforme.
- Une **sécurité des données** assurée par les politiques RLS de Supabase et le stockage sécurisé des tokens JWT.
- Une **couverture de tests** de 125+ tests unitaires et widget, avec pipeline CI/CD intégré.

**Les perspectives d'évolution incluent :**
- L'intégration réelle de Stripe pour les paiements (actuellement simulé)
- Les notifications push (FCM/APNs)
- Les fonctionnalités sociales (partage, commentaires, évaluations)
- L'optimisation des performances avec pagination avancée
- Le déploiement sur les stores (Google Play, App Store)

EventHub constitue une solution moderne, scalable et complète pour la gestion d'événements, démontrant l'efficacité de la combinaison Flutter + Supabase pour le développement rapide d'applications mobiles professionnelles.
