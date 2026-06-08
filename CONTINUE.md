# CONTINUE — EventHub

> À lire avant de reprendre le développement.
> Date : 08/06/2026

---

## Où sommes-nous ?

EventHub est une application Flutter de gestion d'événements avec Supabase en backend. L'architecture est **Clean Architecture + BLoC + GetIt DI**. 8 features sont implémentées : Auth, Events, Bookings, Tickets, Payments, Notifications, Profile, Admin.

**~97 tests** existants. L'app compile et tourne.

---

## Ce qu'il faut savoir avant de continuer

### 1. Bugs bloquants à corriger en priorité

| # | Bug | Fichier |
|---|-----|---------|
| 🔴 | Double `@override` → erreur de compilation | `lib/features/auth/presentation/pages/forgot_password_page.dart:33` |
| 🔴 | Flux réservation → ticket cassé (aucune création de ticket après booking) | Cross-feature : bookings → tickets manque `CreateTicketUseCase` |

### 2. Ce qui manque (par feature)

| Feature | Ce qui est fait | Ce qui manque |
|---------|----------------|---------------|
| **Auth** | Login, Register, Forgot Password, Logout, 25 tests | Navigation post-auth, écoute `onAuthStateChange`, `ChangePasswordUseCase` |
| **Events** | CRUD complet, filtres, favoris, dashboard organisateur | Pagination (`hasReachedMax`), upload image réel, `endDate` dans formulaire, handler `FavoriteIdsLoaded` |
| **Bookings** | Création, historique, 3 tests | `cancelBooking()`, page UI dans `bookings/` (actuellement dans `payments/`) |
| **Tickets** | QR display, scanner, validation | ⚠️ **Aucune création de tickets** après réservation/paiement. 0 test. |
| **Payments** | Structure préparée | ⚠️ **Pas de vrai Stripe**. Paiements simulés (insertion DB directe). 0 test. |
| **Notifications** | Liste + lecture | `markAsRead()`, `onTap` handler, swipe-to-dismiss. 0 test. |
| **Profile** | Affichage + édition | Upload photo, pré-remplissage formulaire. 0 test. |
| **Admin** | Dashboard + 6 pages, 10 tests | Use cases manquants pour 7 méthodes, bouton "Rejeter" événement |

### 3. Problèmes architecturaux

- `AuthBloc._onCheckAuth` contourne le repository (appelle Supabase directement)
- `EventDetailPage` appelle Supabase directement pour les favoris
- `TokenManager` et `NetworkInfo` enregistrés dans DI mais **jamais utilisés**
- `GetUserFavoriteIdsUseCase` enregistré dans DI mais pas passé à `EventBloc`

### 4. Tests à écrire (0 test actuellement)

- Payments ❌
- Notifications ❌
- Profile ❌
- Tickets ❌
- Pages Events ❌
- Pages Admin ❌
- Use cases (17 non testés)
- Repository implementations (6/7 manquants)
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
1. Corriger les 2 bugs bloquants
2. Implémenter la création de tickets (flux booking → payment → ticket)
3. Écrire les tests manquants (commencer par Tickets et Payments)
4. Nettoyer la dette technique (dead code, contournements)
5. Intégration Stripe réelle
