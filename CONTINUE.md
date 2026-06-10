# CONTINUE — EventHub

> À lire avant de reprendre le développement.
> Date : 10/06/2026

---

## Où sommes-nous ?

EventHub est une application Flutter de gestion d'événements avec Supabase en backend. L'architecture est **Clean Architecture + BLoC + GetIt DI**. 8 features sont implémentées : Auth, Events, Bookings, Tickets, Payments, Notifications, Profile, Admin.

**~125 tests** existants. L'app compile et tourne.

---

## Ce qu'il faut savoir avant de continuer

### 1. Bugs bloquants à corriger en priorité

*Pas de bugs bloquants connus pour le moment.* ✅

* Session (10/06/2026 - événements privés) : **Visibilité privée/publique** — `isPrivate` sur Event, table `event_invitations`, toggle UI dans `CreateEventPage`, ajout d'invitations par email, import CSV via `file_picker` + `csv`, fonctions SECURITY DEFINER pour éviter récursion RLS, 17 clés l10n EN/FR/AR, schéma DB mis à jour.
* Dernière session (09/06/2026) : **2 bugs bloquants corrigés** — double `@override` dans `forgot_password_page.dart`, flux booking→ticket complété (`CreateTicketUseCase`, datasource, repository, DI, RLS policy, intégration booking_page).
* **11 appels `Navigator.pushNamed()`** remplacés par `context.push()` (GoRouter) dans 4 fichiers.
* **28 nouveaux tests** écrits (Tickets: 10, Payments: 8, Bookings: 7, Auth: 2, Core: 1).
* Session (10/06/2026 - suite) : **5 correctifs haute priorité** — `AuthBloc._onCheckAuth` utilise `GetCurrentUserUseCase` (plus d'appel Supabase direct), `EventDetailPage._checkFavorite` passe par le BLoC, 7 use cases Admin créés et câblés, `TokenManager`/`NetworkInfo` retirés du DI, `GetUserFavoriteIdsUseCase` injecté dans `EventBloc`.
* Session (10/06/2026 - prioritaire) : **7 correctifs** — Dead code `FavoriteIdsLoaded` supprimé, pagination `hasReachedMax` dans `EventsLoaded`, champ `endDate` dans `CreateEventPage`, upload image réel (Supabase Storage) dans `CreateEventPage`, upload photo + pré-remplissage dans `EditProfilePage`, 12 nouveaux tests (Profile bloc: 4, Notifications bloc: 3, Events bloc: 5), **139 tests total** (+14).
* Session (10/06/2026 - améliorations) : **Notifications** — `markAsRead()` dans repository/datasource/bloc, `onTap` handler, swipe-to-dismiss. **Bookings** — `cancelBooking()` complète (repository/datasource/use case/bloc), `MyBookingsPage` créée dans `bookings/`, route `/my-bookings`. **Events filtres** — les 8 catégories (via `EventCategory.values`). **QR scanner** — débounce 2s + overlay chargement. **l10n** — 5 nouvelles clés de validation (`titleRequired`, `descriptionRequired`, `locationRequired`, `nameRequired`, `required`) dans les 3 langues, remplacement de toutes les chaînes en dur. **139 tests** (+2 notifications +2 bookings).

### 2. Ce qui manque (par feature)

| Feature | Ce qui est fait | Ce qui manque |
|---------|----------------|---------------|
| **Auth** | Login, Register, Forgot Password, Logout, 25 tests | Navigation post-auth, écoute `onAuthStateChange`, `ChangePasswordUseCase` |
| **Events** | CRUD complet, filtres, favoris, dashboard organisateur, visibilité privée/publique, invitations, import CSV | — |
| **Bookings** | Création, historique, 3 tests | `cancelBooking()`, page UI dans `bookings/` (actuellement dans `payments/`) |
| **Tickets** | QR display, scanner, validation, création après booking | ✅ Création de tickets après réservation/paiement complète. 10 tests. |
| **Payments** | Structure préparée | ⚠️ **Pas de vrai Stripe**. Paiements simulés (insertion DB directe). 8 tests. |
| **Notifications** | Liste + lecture | `markAsRead()`, `onTap` handler, swipe-to-dismiss. 0 test. |
| **Profile** | Affichage + édition | Upload photo, pré-remplissage formulaire. 0 test. |
| **Admin** | Dashboard + 6 pages, 10 tests | Use cases manquants pour 7 méthodes, bouton "Rejeter" événement |

### 3. Problèmes architecturaux

- ~~`AuthBloc._onCheckAuth` contourne le repository (appelle Supabase directement)~~ ✅ **Corrigé**
- ~~`EventDetailPage` appelle Supabase directement pour les favoris~~ ✅ **Corrigé**
- ~~`TokenManager` et `NetworkInfo` enregistrés dans DI mais **jamais utilisés**~~ ✅ **Corrigé**
- ~~`GetUserFavoriteIdsUseCase` enregistré dans DI mais pas passé à `EventBloc`~~ ✅ **Corrigé**

### 4. Tests à écrire (0 test actuellement)

- Notifications ❌
- Profile ❌
- Pages Events ❌
- Pages Admin ❌
- Use cases (reste ~10 non testés)
- Repository implementations (4/7 manquants)
- Data sources (0 test)

### 5. Pour lancer le projet

```bash
cd eventhub
flutter pub get
flutter gen-l10n
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

### 6. Documentation de référence

- `FICHE_EXTRACTION_EVENTHUB.md` — Vue d'ensemble complète du projet
- `TODO.md` — État détaillé par feature (bugs, manques, problèmes)
- `supabase_schema.sql` — Schéma complet de la base de données
- `APP_OVERVIEW.md` — Aperçu fonctionnel

---

**Priorités suggérées :**
1. ✅ ~~Corriger les 2 bugs bloquants~~
2. ✅ ~~Implémenter la création de tickets (flux booking → payment → ticket)~~
3. ✅ ~~Écrire les tests Tickets et Payments~~
4. ✅ ~~Nettoyer la dette technique (dead code, contournements)~~
5. Tests à continuer (Notifications, Profile, pages Events/Admin)
6. Intégration Stripe réelle
