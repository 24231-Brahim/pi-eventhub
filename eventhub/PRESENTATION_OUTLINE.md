# EventHub — Saturday Demo Presentation Outline

---

## 1. Architecture Overview — Clean Architecture + BLoC

EventHub follows **Clean Architecture**, applied per feature module under `lib/features/`
(`admin`, `auth`, `bookings`, `events`, `notifications`, `payments`, `profile`, `tickets`).
Each feature is split into three layers:

| Layer | Folder | Responsibility | Examples |
|---|---|---|---|
| **Presentation** | `presentation/bloc`, `presentation/pages`, `presentation/widgets` | UI + state management (flutter_bloc). Pages dispatch Events, rebuild on States. | `EventBloc`, `event_list_page.dart`, `event_card.dart` |
| **Domain** | `domain/entities`, `domain/repositories`, `domain/usecases` | Pure business logic. Framework-independent. Entities (Equatable), abstract repository contracts, single-purpose UseCases. | `Event`, `EventRepository`, `CreateEventUseCase` |
| **Data** | `data/datasources`, `data/models`, `data/repositories` | Talks to Supabase, maps JSON ↔ Models ↔ Entities, implements the domain repository interfaces. | `EventSupabaseDataSource`, `EventModel`, `EventRepositoryImpl` |

**Cross-cutting layers (`lib/core` and `lib/shared`):**
- `core/di/injection_container.dart` — GetIt service locator wiring every datasource → repository → usecase → bloc
- `core/router/app_router.dart` — go_router config + auth/role guards
- `core/errors` — `Failure` / `Exception` hierarchy used by the `Either` pattern
- `core/network`, `core/utils` — connectivity check, date formatting helpers
- `shared/themes` — "Vibrant Pulse" design system (colors, typography, spacing, radius, shadows)
- `shared/widgets` — reusable Loading / Error / Empty states, `FadeSlideIn` animation wrapper
- `shared/services` — local storage (Hive/SharedPreferences), CSV/Excel import service

### Suggested diagram (for the slide)

```
        ┌─────────────────────────────────────────────┐
        │                PRESENTATION                  │
        │   Pages / Widgets  ⇄  BLoC (Event → State)   │
        └───────────────────────┬───────────────────────┘
                                 │ calls
        ┌───────────────────────▼───────────────────────┐
        │                   DOMAIN                       │
        │  UseCases  →  Repository (abstract interface)  │
        │           Entities (pure Dart objects)         │
        └───────────────────────┬───────────────────────┘
                                 │ implements
        ┌───────────────────────▼───────────────────────┐
        │                    DATA                        │
        │  RepositoryImpl → DataSource → Models          │
        │        Either<Failure, T> wrapping             │
        └───────────────────────┬───────────────────────┘
                                 │
                       ┌─────────▼─────────┐
                       │     Supabase       │
                       │ Auth / Postgres /  │
                       │  Storage + RLS     │
                       └────────────────────┘

   Wiring: GetIt (sl<T>()) injects concrete implementations
           into UseCases and UseCases into BLoCs.
   Navigation: go_router (with AuthBloc-driven redirect guard)
```

Arrows point **inward** (Data depends on Domain via interfaces, Presentation depends on Domain) —
classic Dependency Inversion, enabling each layer to be tested/replaced independently.

---

## 2. Features Developed

| Feature | One-line description |
|---|---|
| **Auth** | Email/password login, registration, forgot-password flow, and role-based access (admin / organizer / participant) backed by Supabase Auth. |
| **Events** | Full CRUD for events (create/edit/delete), categories, favorites, search & filtering, and public/private event visibility. |
| **Bookings** | Create, confirm, and cancel bookings with capacity/availability validation against event participant limits. |
| **Tickets** | Automatic QR ticket generation on booking confirmation, in-app QR scanner (with runtime camera permission handling) for check-in/validation. |
| **Payments** | End-to-end flow from booking → payment intent → confirmation → automatic ticket issuance. |
| **Notifications** | In-app inbox with read/unread state, swipe-to-dismiss, and human-readable "time ago" timestamps. |
| **Profile** | Edit profile info, upload profile photo, and switch theme/language preferences. |
| **Admin** | Dashboard with live stats (users, events, bookings, tickets, revenue) plus management screens for users, events, bookings, tickets, and analytics. |
| **Private Events** | Email-based guest invitation system, bulk invite import via CSV/Excel, invite status tracking (pending/accepted/declined), and booking access restricted to invited guests. |
| **UI / Design System** | "Vibrant Pulse" dark Material 3 theme (custom color/typography/spacing tokens), fade/slide entrance animations, and full multilingual support (English, French, Arabic — 203 translated strings each, including RTL for Arabic). |

---

## 3. Suggested Work Distribution — Brahim & Ammar

> Note: the git history on this repo is committed under a single shared account, so the
> split below is proposed by **feature ownership / vertical slice** rather than literal
> commit attribution — matching the areas each of you has been driving recently.

| Owner | Suggested Modules | Rationale |
|---|---|---|
| **Brahim** | Auth, Bookings, Payments, Admin, Notifications, Profile | These form the core backend-integration and account/management foundation — early commits ("backend", "structure de projet") established Supabase wiring, auth flow, and admin/booking data models. |
| **Ammar** | Events (incl. Private Events/Invitations), Tickets/QR (scanner + permissions), UI/Design System & Localization | Recent work has centered on the events feature (CRUD, private events, invitations, CSV import), the QR ticket/scanner flow (camera permissions, ticket redesign), and the Vibrant Pulse theme + EN/FR/AR translations. |

**Demo split suggestion:** Brahim presents Auth → Booking → Payment → Admin (the "transaction" path);
Ammar presents Events → Private Event Invitations → Ticket/QR → Notifications/UI polish (the "experience" path).

---

## 4. Key Technical Choices to Highlight

- **Supabase Row-Level Security (RLS)** — Access control (organizer sees only their events, admins see everything, invited guests see only their own invitation) is enforced at the **database level**, not just in app code — reducing risk of client-side bypass.
- **go_router with centralized redirect guards** — `AppRouter`'s single `redirect` callback, driven by an `AuthNotifier` listening to `AuthBloc`'s stream, handles: unauthenticated → `/login`, authenticated users skipping auth screens, and `/admin/*` routes restricted to the `admin` role.
- **GetIt dependency injection** — `lib/core/di/injection_container.dart` wires every DataSource → Repository → UseCase → BLoC as a single composition root (`sl<T>()`), keeping features decoupled and easily testable/mockable.
- **dartz `Either<Failure, T>` pattern** — every repository method (40+ across the app) returns `Either<Failure, T>` instead of throwing, forcing explicit success/failure handling (`.fold(...)`) at the BLoC layer with no uncaught exceptions reaching the UI.
- **ARB-based localization** — 203 keys per language across `app_en.arb`, `app_fr.arb`, `app_ar.arb`, generated into type-safe `AppLocalizations` via `flutter gen-l10n`, with full Arabic RTL support.

---

## 5. Closing / Demo Flow Suggestion

1. **Login / role switch** — show participant vs organizer vs admin views (Auth + guards)
2. **Browse & book** — search/filter events, book, pay, receive QR ticket (Events → Bookings → Payments → Tickets)
3. **Private event** — organizer invites a guest via CSV import, guest logs in and books (Private Events)
4. **Check-in** — scan the QR ticket with camera permission flow (Tickets/QR scanner)
5. **Notifications** — show inbox, swipe to dismiss
6. **Admin dashboard** — stats overview, manage users/events/bookings
7. **Polish** — theme (Vibrant Pulse dark mode), language switch EN ↔ FR ↔ AR (RTL)
