# EventHub — État d'avancement du projet

> Projet Flutter (Clean Architecture + BLoC) + Supabase (Backend as a Service)
> Date : 10/06/2026

---

## Légende

| Symbole | Signification |
|---------|---------------|
| ✅ | Terminé / fonctionnel |
| 🟡 | Partiellement terminé (avec problèmes) |
| ❌ | Non implémenté / manquant |
| 🐛 | Bug connu |

---

## 1. AUTH (Authentification)

### ✅ Terminé
- **Domain :** `User` entity, `AuthRepository` interface, all 4 use cases (`Login`, `Register`, `ForgotPassword`, `Logout`)
- **Data :** `UserModel`, `AuthSupabaseDataSourceImpl`, `AuthRepositoryImpl`
- **Presentation :** Events/States BLoC, `LoginPage`, `RegisterPage`, `ForgotPasswordPage`
- **Tests :** 25 tests (use cases, repository, bloc, pages, integration flows)

### 🟡 Partiel / Problèmes
- `AuthWrapper` → n'affiche qu'un `SizedBox()` quand non authentifié (pas de redirection vers `/login`)
- `_onCheckAuth` dans `AuthBloc` → contourne le repository en appelant `Supabase.instance.client` directement
- `LoginPage` / `RegisterPage` → pas de navigation après succès (`Authenticated` émis mais pas de `context.go('/')`)
- `ForgotPasswordPage` → pas de navigation après succès (reste sur la page après le dialog)
- Messages de validation en dur (anglais) dans les 3 pages, pas via `l10n`
- Validation email faible (`value.contains('@')`) dans login/register

### 🐛 Bugs
- ~~**`ForgotPasswordPage` ligne 33 :** double annotation `@override` → erreur de compilation Dart~~ ✅ **Corrigé**
- Validation email du `ForgotPasswordPage` : ne vérifie que la non-vacuité (pas de `@`)

### ❌ Manquant
- Écoute du stream `onAuthStateChange` de Supabase (session expirée non détectée)
- `ChangePasswordUseCase` / `DeleteAccountUseCase`
- Redirection automatique vers login quand session expirée

---

## 2. EVENTS (Événements)

### ✅ Terminé
- **Domain :** `Event` entity (avec `isFree`, `isFull`, `isPast`), `EventRepository` interface, 7 use cases
- **Data :** `EventModel`, `EventSupabaseDataSourceImpl` (CRUD complet), `EventRepositoryImpl`
- **Presentation :** BLoC complet (6 events gérés), `EventListPage`, `EventDetailPage`, `CreateEventPage`, `ManageEventsPage`, `OrganizerDashboardPage`, `EventCard`
- Création/édition/suppression d'événements
- Filtres par catégorie sur `EventListPage`
- Dashboard organisateur avec statistiques dynamiques
- Favoris (toggle)
- **Tests :** 12 tests (bloc, event card widget)

### 🟡 Partiel / Problèmes
- `ToggleFavoriteEvent` → erreur silencieuse (failure → `null`), pas d'état d'erreur émis
- ~~`EventDetailPage` → requête Supabase directe pour les favoris (contourne le BLoC)~~ ✅ **Corrigé**
- ~~`CreateEventPage` → image pickée jamais uploadée ni attachée à l'événement~~ ✅ **Corrigé** (upload Supabase Storage)
- `EventListPage` → seulement 4 catégories sur 8 affichées dans les filtres
- ~~`EventState` → pas de métadonnées de pagination (`hasReachedMax`)~~ ✅ **Corrigé**
- ~~`manage_events_page.dart` → navigation mixte (`go_router` + `Navigator.pushNamed`)~~ ✅ **Corrigé**
- `create_event_page.dart` → `initialValue` déprécié sur `DropdownButtonFormField`
- ~~Pas de champ `endDate` dans le formulaire de création~~ ✅ **Corrigé**

### ❌ Manquant
- ~~`GetUserFavoriteIdsEvent` / `FavoriteIdsLoaded` → définis dans `event_event.dart` mais **aucun handler** dans le BLoC~~ ✅ **Corrigé** (dead code supprimé)
- ~~`GetUserFavoriteIdsUseCase` → enregistré dans DI mais jamais injecté dans `EventBloc`~~ ✅ **Corrigé**
- ~~`updateEvent` → pas testé dans `event_bloc_test.dart`~~ ✅ **Corrigé**
- Tests use cases individuels manquants (7 use cases non testés)
- Tests pages événements manquants

### ✅ Nouveau — Visibilité privée/publique + Invitations
- `Event.isPrivate` booléen pour définir la visibilité
- `EventInvitation` entity + model avec sérialisation JSON
- Table `event_invitations` dans Supabase avec RLS
- Interface UI : toggle privé/public dans le formulaire de création d'événement
- Ajout d'invitations par email + nom
- Import CSV via `FileImportService` (fichier `file_picker` + parsing `csv`)
- Fonctions SECURITY DEFINER `is_invited_to_event()` et `is_organizer_of_event()` pour éviter la récursion RLS
- Politique SELECT sur `events` : les invités peuvent voir les événements privés
- 17 nouvelles clés de traduction (EN/FR/AR) pour l'UI d'invitation

---

## 3. BOOKINGS (Réservations)

### ✅ Terminé
- **Domain :** `Booking` entity, `BookingRepository` interface, `CreateBookingUseCase`, `GetUserBookingsUseCase`
- **Data :** `BookingModel`, `BookingSupabaseDataSourceImpl`, `BookingRepositoryImpl`
- **Presentation :** BLoC complet (2 events gérés)
- **Tests :** 3 tests (bloc)

### ❌ Manquant
- `cancelBooking()` / `refundBooking()` / `getBookingById()` → pas dans le repository
- Page UI des réservations dans le dossier `bookings/` → **absente** (le fichier `booking_page.dart` est dans `payments/`)
- Tests use cases individuels (2 use cases non testés)
- Tests repository

---

## 4. TICKETS (Billets / QR Code)

### ✅ Terminé
- **Domain :** `Ticket` entity, `TicketRepository` interface, `GetUserTicketsUseCase`, `ValidateTicketUseCase`, `CreateTicketUseCase`
- **Data :** `TicketModel`, `TicketSupabaseDataSourceImpl`, `TicketRepositoryImpl`
- **Presentation :** BLoC complet, `TicketsPage`, `QrCodePage`, `QrScannerPage`
- **Création de tickets après réservation/paiement** : flux booking → payment → ticket complet ✅
- **Navigation** : `Navigator.pushNamed` → `context.push()` (GoRouter) dans `tickets_page.dart` ✅
- **Tests :** 10 tests (bloc, use cases, repository)

### 🟡 Partiel / Problèmes
- `QrScannerPage` → `MobileScanner` pas de débounce → scans multiples possibles
- `QrScannerPage` → pas d'indicateur de chargement (`TicketLoading` émis mais pas affiché)
- `validateTicket()` → retourne succès même pour tickets déjà `used` ou `cancelled`

---

## 5. PAYMENTS (Paiements)

### ✅ Terminé
- **Domain :** `Payment` entity, `PaymentRepository` interface, `CreatePaymentIntentUseCase`, `ConfirmPaymentUseCase`
- **Data :** `PaymentModel`, `PaymentSupabaseDataSourceImpl`, `PaymentRepositoryImpl`
- **Presentation :** BLoC complet, `BookingPage`
- **Tests :** 8 tests (bloc, use cases, repository)

### 🐛 Problèmes critiques
- **Aucune intégration Stripe réelle** : pas de dépendance `flutter_stripe`, pas d'appels API Stripe
- `createPaymentIntent()` → insère juste une ligne en DB avec status `'pending'` (pas de vrai PaymentIntent)
- `confirmPayment()` → met juste à jour le status en DB, stocke l'ID comme `stripe_payment_intent_id`
- **`clientSecret` (payment_bloc.dart ligne 30) est en fait un UUID de base de données**, pas un vrai client secret Stripe
- `confirmPayment` filtre par `booking_id` au lieu de `id` → risque de mise à jour multiple

### ❌ Manquant
- `getUserPayments` → pas de méthode dans le repository
- Page historique des paiements
- Gestion des remboursements / échecs de paiement

---

## 6. NOTIFICATIONS

### ✅ Terminé
- **Domain :** `AppNotification` entity, `NotificationRepository` interface, `GetNotificationsUseCase`
- **Data :** `NotificationModel`, `NotificationSupabaseDataSourceImpl`, `NotificationRepositoryImpl`
- **Presentation :** BLoC, `NotificationsPage` (affichage liste avec indicateur de lecture)

### ❌ Manquant
- `markAsRead()` / `markAllAsRead()` / `deleteNotification()` → pas dans le repository
- `getUnreadCount()` → pas implémenté
- `onTap` sur les notifications → pas de handler (aucune action au clic)
- Swipe-to-dismiss → pas implémenté
- `data` dans `AppNotification` typé comme `String?` au lieu d'un type JSON structuré
- Tests : 0 test pour toute la feature notifications

---

## 7. PROFILE (Profil)

### ✅ Terminé
- **Domain :** `Profile` entity, `ProfileRepository` interface, `GetProfileUseCase`, `UpdateProfileUseCase`
- **Data :** `ProfileModel`, `ProfileSupabaseDataSourceImpl`, `ProfileRepositoryImpl`
- **Presentation :** BLoC complet, `ProfilePage`, `EditProfilePage`

### 🟡 Partiel / Problèmes
- ~~`EditProfilePage` → `onTap: () {}` sur l'avatar (photo upload est un stub vide)~~ ✅ **Corrigé** (upload Supabase Storage)
- ~~`EditProfilePage` → champs non pré-remplis avec les valeurs actuelles du profil~~ ✅ **Corrigé**

### ❌ Manquant
- `UploadPhotoUseCase` → pas défini
- `ChangePasswordUseCase` / `DeleteAccountUseCase` → pas définis
- Tests : 0 test pour toute la feature profile

---

## 8. ADMIN (Panneau d'administration)

### ✅ Terminé
- **Domain :** `DashboardStats` entity, `AdminRepository` interface (10 méthodes), 3 use cases
- **Data :** `AdminSupabaseDataSourceImpl`, `AdminRepositoryImpl`
- **Presentation :** BLoC (10 events), `AdminDashboardPage`, `AdminUsersPage`, `AdminEventsPage`, `AdminBookingsPage`, `AdminTicketsPage`, `AdminAnalyticsPage`
- **Tests :** 10 tests (bloc)

### 🟡 Partiel / Problèmes
- **7 méthodes du repository sans use case** : `UpdateUserRoleUseCase`, `ToggleUserActiveUseCase`, `ApproveEventUseCase`, `ToggleEventFeaturedUseCase`, `DeleteEventUseCase`, `GetAllBookingsUseCase`, `GetAllTicketsUseCase` → BLoC appelle `adminRepository` directement
- Handlers de mutation (`_onUpdateUserRole`, etc.) → pas d'état `AdminLoading` émis
- `AdminBookingsPage` ligne 42 → utilise `l10n.noTickets` au lieu de `l10n.noBookings`
- `AdminEventsPage` → pas de bouton "Rejeter" (seulement "Approuver")

### ❌ Manquant
- Tests pages admin (aucune page testée)
- Tests use cases (3 use cases non testés)
- Tests repository

---

## 9. CORE (Fondation)

### ✅ Terminé
- `failures.dart` / `exceptions.dart` → hiérarchie complète
- `token_manager.dart` → JWT + refresh token avec `FlutterSecureStorage`
- `validators.dart` → email, password, name, phone, URL
- `date_utils.dart` → formatage, time-ago, ISO
- `supabase_constants.dart` / `app_constants.dart`
- `network_info.dart` → `connectivity_plus`
- `app_router.dart` → 21 routes avec auth redirect
- `injection_container.dart` → DI pour 8 features
- **Tests :** 27 tests (validators, date_utils, token_manager, network_info)

### 🟡 Problèmes
- `TokenManager` → **enregistré dans DI mais jamais utilisé** (dead code)
- `NetworkInfo` → **enregistré dans DI mais jamais injecté** dans les repositories (dead code)
- `GetUserFavoriteIdsUseCase` → enregistré dans DI mais pas passé à `EventBloc`
- `AuthBloc._onCheckAuth` → requête Supabase directe (contourne repository)

---

## 10. SHARED (Partagé)

### ✅ Terminé
- `app_theme.dart` → thèmes Material 3 light/dark
- `app_colors.dart` → palette de couleurs
- `local_storage_service.dart` → wrapper `SharedPreferences`
- `loading_widget.dart` / `error_widget.dart` / `empty_widget.dart`
- **Tests :** 9 tests (3 widgets)

---

## 11. PRESENTATION (Pages globales)

### ✅ Terminé
- `SplashPage` → 2s, vérification onboarding
- `OnboardingPage` → 3 pages, flow skip/get-started
- `HomeShell` → BottomNavigationBar 4 tabs
- `SettingsPage` → dark mode, langue (EN/FR/AR), version

---

## 12. LOCALISATION (l10n)

### ✅ Terminé
- 3 langues : Anglais (`app_en.arb`), Français (`app_fr.arb`), Arabe (`app_ar.arb`)
- 45+ clés par langue
- Génération automatique avec `flutter gen-l10n`

### 🟡 Problèmes
- Messages de validation dans les pages auth/events → en dur en anglais, pas via `l10n`

---

## 13. BASE DE DONNÉES (Supabase)

### ✅ Terminé
- `supabase_schema.sql` complet : tables `profiles`, `events`, `bookings`, `tickets`, `payments`, `notifications`, `favorites`
- Triggers : auto-création de profil à l'inscription
- Politiques RLS complètes pour toutes les tables
- Politiques admin avec fonction `is_admin()`
- Politiques organisateur pour voir les réservations de ses événements

### ❌ Manquant
- Trigger DB pour auto-création des tickets après confirmation de réservation

---

## 14. CI / CD

### ✅ Terminé
- GitHub Actions (`.github/workflows/ci.yml`) : `flutter analyze` + `flutter test`

### 🟡 Améliorations possibles
- Pas de cache Flutter SDK / dépendances
- Pas de rapport de couverture de test
- Pas de matrix strategy (multi-plateforme)
- Ne tourne que sur `main`

---

## 15. TESTS — Résumé global

| Feature | Tests | Statut |
|---------|-------|--------|
| Core | 27 tests (validators, date_utils, token_manager, network_info) | ✅ Complet |
| Auth | 25 tests (use cases, repository, bloc, pages, intégration) | ✅ Bon |
| Shared Widgets | 9 tests | ✅ Complet |
| Admin | 10 tests (bloc uniquement) | 🟡 Partiel |
| Events | 12 tests (bloc + event_card) | 🟡 Partiel |
| Bookings | 3 tests (bloc uniquement) | 🟡 Minimal |
| Payments | 8 tests (bloc, use cases, repository) | ✅ Nouveau |
| Profile | 4 tests (bloc) | 🟡 Nouveau |
| Notifications | 3 tests (bloc) | 🟡 Nouveau |
| Tickets | 10 tests (bloc, use cases, repository) | ✅ Nouveau |
| Events | 17 tests (bloc + event_card + update/toggle/pagination) | ✅ Renforcé |
| **Total** | **~137 tests** | |

### ❌ Gaps critiques dans les tests
- **Profile** (4 tests) ✅ nouveau / **Notifications** (3 tests) ✅ nouveau
- **Repository implementations** : seuls `auth_repository_impl`, `ticket_repository_impl`, `payment_repository_impl` sont testés (4/7 manquants)
- **Use cases** : testés pour Auth + Tickets + Payments + Events (gaps réduits)
- **~20 pages** sans test (seules les pages auth + event_card sont testées)
- **Data sources** : 0 test pour toutes
- **Smoke test** : `widget_test.dart` = placeholder trivial (`expect(1+1, 2)`)

---

## 16. BUGS CRITIQUES (Blocage)

| # | Bug | Fichier | Statut |
|---|-----|---------|--------|
| 1 | Double `@override` → erreur de compilation | `lib/features/auth/presentation/pages/forgot_password_page.dart:33` | ✅ **Corrigé** |
| 2 | Flux réservation → ticket cassé (aucune création de ticket après booking) | Cross-feature : bookings → tickets | ✅ **Corrigé** |

---

## 17. PROBLÈMES ARCHITECTURAUX

| # | Problème | Fichier | Statut |
|---|----------|---------|--------|
| 1 | `AuthBloc._onCheckAuth` contourne le repository (appelle Supabase directement) | `lib/features/auth/presentation/bloc/auth_bloc.dart` | ✅ **Corrigé** |
| 2 | `EventDetailPage` contourne le BLoC pour les favoris (appelle Supabase directement) | `lib/features/events/presentation/pages/event_detail_page.dart:31-48` | ✅ **Corrigé** |
| 3 | 7 méthodes du repository admin sans use case | `lib/features/admin/presentation/bloc/admin_bloc.dart` | ✅ **Corrigé** |
| 4 | `TokenManager` et `NetworkInfo` enregistrés dans DI mais jamais utilisés | `lib/core/di/injection_container.dart` | ✅ **Corrigé** |
| 5 | `GetUserFavoriteIdsUseCase` enregistré dans DI mais pas utilisé par `EventBloc` | `lib/core/di/injection_container.dart:132` | ✅ **Corrigé** |
| 6 | Paiements simulés (pas de vrai Stripe) mais nommés comme si Stripe était intégré | `lib/features/payments/` | 🟡 Non corrigé |
| 7 | `BookingPage` située dans `payments/` au lieu de `bookings/` | `lib/features/payments/presentation/pages/booking_page.dart` | 🟡 Non corrigé |

---

## 18. AMÉLIORATIONS SOUHAITABLES

- Cache Flutter SDK + dépendances dans la CI
- Rapport de couverture de test (Codecov, Coveralls)
- `copyWith()` sur l'entité `Event` (évite les copies manuelles)
- ~~Métadonnées de pagination dans `EventState`~~ ✅ **Corrigé**
- Toutes les 8 catégories dans les filtres de `EventListPage`
- ~~Champ `endDate` dans le formulaire de création d'événement~~ ✅ **Corrigé**
- ~~Upload réel de l'image dans `CreateEventPage`~~ ✅ **Corrigé**
- Débounce sur le scanner QR
- Handler `onTap` sur les notifications
- ~~Pré-remplissage du formulaire dans `EditProfilePage`~~ ✅ **Corrigé**
- ~~Upload photo profil fonctionnel~~ ✅ **Corrigé**
- Bouton "Rejeter" dans `AdminEventsPage`
