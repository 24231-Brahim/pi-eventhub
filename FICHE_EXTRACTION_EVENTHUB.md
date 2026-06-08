# FICHE D'EXTRACTION — EventHub

> **Plateforme mobile de gestion, découverte et réservation d'événements**
> Architecture : Clean Architecture (Flutter) + Supabase (Backend as a Service)

---

## 1. VUE D'ENSEMBLE DU PROJET

```
pi-eventhub/
├── eventhub/                          ← Application Flutter (Frontend Mobile)
│   ├── lib/                           ← Code source Dart
│   ├── test/                          ← Tests (unitaires, widget, intégration)
│   ├── pubspec.yaml                   ← Dépendances Flutter
│   ├── assets/                        ← Images, Lottie, Icônes
│   └── l10n/                          ← Fichiers de traduction (ARB)
│
├── supabase_schema.sql                ← Schéma PostgreSQL Supabase + RLS
└── FICHE_EXTRACTION_EVENTHUB.md       ← Ce document
```

---

## 2. DIAGRAMME DE L'ARCHITECTURE GLOBALE

```mermaid
graph TB
    subgraph "📱 Flutter App (Frontend)"
        PRES["Presentation Layer<br/>Pages + Blocs + Widgets"]
        DOM["Domain Layer<br/>Entities + UseCases + Repositories (abstract)"]
        DATA["Data Layer<br/>Models + Datasources + Repository Impl"]
        CORE["Core<br/>Network + DI + Router + Errors"]
    end

    subgraph "☁️ Supabase (Backend as a Service)"
        AUTH["Supabase Auth<br/>Login / Register / Session"]
        DB[("PostgreSQL Database<br/>RLS Policies")]
        STORAGE["Supabase Storage<br/>Images"]
    end

    PRES --> DOM
    DOM --> DATA
    DATA --> AUTH
    DATA --> DB
    DATA --> STORAGE
```

**FLUX D'AUTHENTIFICATION :** `Flutter → Supabase Auth (JWT) → SecureStorage`
**FLUX DONNÉES :** `Flutter → Supabase SDK (postgrest) → PostgreSQL`

---

## 3. DIAGRAMME DE L'ARCHITECTURE FLUTTER (CLEAN ARCHITECTURE)

```mermaid
graph TB
    subgraph "lib/"
        CORE["core/"]
        FEATURES["features/"]
        SHARED["shared/"]
        PRES["presentation/"]
    end

    subgraph "core/"
        CONST["constants/<br/>api_constants<br/>app_constants<br/>supabase_constants"]
        DI["di/<br/>injection_container"]
        ERR["errors/<br/>exceptions<br/>failures"]
        NET["network/<br/>api_client<br/>network_info"]
        ROUTER["router/<br/>app_router"]
        UTILS["utils/<br/>date_utils<br/>token_manager<br/>validators"]
    end

    subgraph "shared/"
        WID["widgets/<br/>empty_widget<br/>error_widget<br/>loading_widget"]
        THEME["themes/<br/>app_colors<br/>app_theme"]
        SRV["services/<br/>local_storage_service"]
    end

    subgraph "presentation/"
        PAGES["pages/<br/>splash_page<br/>onboarding_page<br/>home_shell<br/>settings_page"]
    end

    subgraph "feature_template"
        DATA_LAYER["data/<br/>datasources<br/>models<br/>repositories/impl"]
        DOM_LAYER["domain/<br/>entities<br/>repositories/abstract<br/>usecases"]
        PRES_LAYER["presentation/<br/>bloc (events+states)<br/>pages<br/>widgets"]
    end

    DATA_LAYER --> DOM_LAYER
    DOM_LAYER --> PRES_LAYER

    FEATURES --> DATA_LAYER
    FEATURES --> DOM_LAYER
    FEATURES --> PRES_LAYER
```

### Structure des features (7 modules)

```
lib/features/
├── auth/           ← Authentification (Login, Register, Forgot Password, Logout)
├── events/         ← Événements (CRUD, liste, détail, gestion, dashboard)
├── bookings/       ← Réservations (création, historique)
├── tickets/        ← Billets (liste, QR code, scanner)
├── payments/       ← Paiements (Stripe intent, confirmation)
├── notifications/  ← Notifications (liste)
└── profile/        ← Profil (affichage, édition)
```

---

## 4. DIAGRAMME ENTITÉ-RELATION (FLUTTER)

```mermaid
erDiagram
    User {
        string id PK
        string email
        string name
        string phone "nullable"
        string photoUrl "nullable"
        enum role "organizer | participant"
        datetime createdAt
    }

    Event {
        string id PK
        string title
        string description
        string imageUrl "nullable"
        datetime date
        datetime endDate "nullable"
        string location
        string city "nullable"
        float latitude "nullable"
        float longitude "nullable"
        float price
        int maxParticipants
        int currentParticipants
        enum category "conference | concert | etc."
        enum status "draft | published | etc."
        string organizerId FK
    }

    Booking {
        string id PK
        string eventId FK
        string userId FK
        int quantity
        float totalAmount
        enum status "pending | confirmed | cancelled | refunded"
        datetime createdAt
    }

    Ticket {
        string id PK
        string eventId FK
        string userId FK
        string bookingId FK
        string qrCode
        enum status "active | used | cancelled"
        datetime createdAt
    }

    Payment {
        string id PK
        string bookingId FK
        float amount
        string currency
        enum status "pending | completed | failed | refunded"
        string stripePaymentIntentId "nullable"
        datetime createdAt
    }

    AppNotification {
        string id PK
        string title
        string body
        enum type "bookingConfirmation | paymentConfirmed | etc."
        string data "nullable"
        bool isRead
        datetime createdAt
    }

    User ||--o{ Event : "organizes"
    User ||--o{ Booking : "makes"
    User ||--o{ Ticket : "owns"
    User ||--o{ AppNotification : "receives"
    Event ||--o{ Booking : "has"
    Event ||--o{ Ticket : "generates"
    Booking ||--o{ Ticket : "produces"
    Booking ||--o{ Payment : "requires"
```

---

## 5. DIAGRAMME DE CLASSES UML — FRONTEND (FLUTTER)

```mermaid
classDiagram
    %% ── Core ────────────────────────────────────────────────
    class ApiConstants {
        <<static>>
        +String baseUrl
        +String auth
        +String login
        +String register
        +String events
        +String bookings
        +String tickets
        +String payments
        +String notifications
        +Duration connectTimeout
        +Duration receiveTimeout
    }

    class AppConstants {
        <<static>>
        +String localeKey
        +String themeModeKey
        +String jwtTokenKey
        +String onboardingKey
        +int minPasswordLength
        +int maxEventTitle
        +int maxEventDescription
        +int pageSize
    }

    class TokenManager {
        -FlutterSecureStorage storage
        +saveToken(String) Future~void~
        +getToken() Future~String?~
        +saveRefreshToken(String) Future~void~
        +getRefreshToken() Future~String?~
        +clearTokens() Future~void~
    }

    class ApiClient {
        -Dio dio
        -TokenManager tokenManager
        +get(String, Map?) Future~Response~
        +post(String, dynamic) Future~Response~
        +put(String, dynamic) Future~Response~
        +delete(String) Future~Response~
    }

    class NetworkInfo {
        <<abstract>>
        +isConnected() Future~bool~
    }
    class NetworkInfoImpl {
        -Connectivity connectivity
        +isConnected() Future~bool~
    }

    %% ── Failures ────────────────────────────────────────────
    class Failure {
        <<abstract>>
        +String message
    }
    class ServerFailure
    class CacheFailure
    class NetworkFailure
    class AuthFailure
    class ValidationFailure

    %% ── Domain Entities ─────────────────────────────────────
    class User {
        +String id
        +String email
        +String name
        +String? phone
        +String? photoUrl
        +UserRole role
        +DateTime? createdAt
    }
    class UserRole {
        <<enumeration>>
        organizer
        participant
    }

    class Event {
        +String id
        +String title
        +String description
        +String? imageUrl
        +DateTime date
        +DateTime? endDate
        +String location
        +String? city
        +double? lat/lng
        +double price
        +int maxParticipants
        +int currentParticipants
        +EventCategory category
        +EventStatus status
        +String organizerId
        +String? organizerName
        +DateTime? createdAt
        +DateTime? updatedAt
        +isFree() bool
        +isFull() bool
        +isPast() bool
    }
    class EventCategory {
        <<enumeration>>
        conference, concert, exhibition
        training, workshop, sports
        seminar, community
    }
    class EventStatus {
        <<enumeration>>
        draft, published
        cancelled, completed
    }

    class Booking {
        +String id
        +String eventId
        +String userId
        +String? eventTitle
        +String? eventImageUrl
        +DateTime? eventDate
        +String? eventLocation
        +int quantity
        +double totalAmount
        +BookingStatus status
        +DateTime? createdAt
    }
    class BookingStatus {
        <<enumeration>>
        pending, confirmed
        cancelled, refunded
    }

    class Ticket {
        +String id
        +String eventId
        +String userId
        +String bookingId
        +String? eventTitle
        +String? eventDate
        +String? eventLocation
        +String qrCode
        +TicketStatus status
        +DateTime? createdAt
    }
    class TicketStatus {
        <<enumeration>>
        active, used, cancelled
    }

    class Payment {
        +String id
        +String bookingId
        +double amount
        +String currency
        +PaymentStatus status
        +String? stripePaymentIntentId
        +DateTime? createdAt
    }
    class PaymentStatus {
        <<enumeration>>
        pending, completed
        failed, refunded
    }

    class AppNotification {
        +String id
        +String title
        +String body
        +NotificationType type
        +String? data
        +bool isRead
        +DateTime? createdAt
    }
    class NotificationType {
        <<enumeration>>
        bookingConfirmation, paymentConfirmed
        eventCancelled, eventReminder, general
    }

    class Profile {
        +String id
        +String email
        +String name
        +String? phone
        +String? photoUrl
        +UserRole role
        +DateTime? createdAt
    }

    %% ── Repository Interfaces ───────────────────────────────
    class AuthRepository {
        <<abstract>>
        +login(String, String) Future~Either~Failure, User~~
        +register(String, String, String, String) Future~Either~Failure, User~~
        +forgotPassword(String) Future~Either~Failure, void~~
        +logout() Future~Either~Failure, void~~
    }

    class EventRepository {
        <<abstract>>
        +getEvents(int, int, String?, String?, double?, double?, DateTime?) Future~Either~Failure, List~Event~~~
        +getEventById(String) Future~Either~Failure, Event~~
        +createEvent(Event) Future~Either~Failure, Event~~
        +updateEvent(Event) Future~Either~Failure, Event~~
        +deleteEvent(String) Future~Either~Failure, void~~
    }

    class BookingRepository {
        <<abstract>>
        +createBooking(Booking) Future~Either~Failure, Booking~~
        +getUserBookings(String) Future~Either~Failure, List~Booking~~
    }

    class TicketRepository {
        <<abstract>>
        +getUserTickets(String) Future~Either~Failure, List~Ticket~~
        +validateTicket(String) Future~Either~Failure, Ticket~~
    }

    class PaymentRepository {
        <<abstract>>
        +createPaymentIntent(double, String) Future~Either~Failure, String~~
        +confirmPayment(String) Future~Either~Failure, Payment~~
    }

    class NotificationRepository {
        <<abstract>>
        +getNotifications(String) Future~Either~Failure, List~AppNotification~~
    }

    %% ── BLoCs ───────────────────────────────────────────────
    class AuthBloc {
        +LoginUseCase loginUseCase
        +RegisterUseCase registerUseCase
        +ForgotPasswordUseCase forgotPasswordUseCase
        +LogoutUseCase logoutUseCase
        +_onLogin(LoginEvent, Emitter) void
        +_onRegister(RegisterEvent, Emitter) void
        +_onForgotPassword(ForgotPasswordEvent, Emitter) void
        +_onLogout(LogoutEvent, Emitter) void
        +_onCheckAuth(CheckAuthEvent, Emitter) void
    }

    class EventBloc {
        +GetEventsUseCase getEventsUseCase
        +GetEventByIdUseCase getEventByIdUseCase
        +CreateEventUseCase createEventUseCase
        +UpdateEventUseCase updateEventUseCase
        +DeleteEventUseCase deleteEventUseCase
    }

    class BookingBloc {
        +CreateBookingUseCase createBookingUseCase
        +GetUserBookingsUseCase getUserBookingsUseCase
    }

    class TicketBloc {
        +GetUserTicketsUseCase getUserTicketsUseCase
        +ValidateTicketUseCase validateTicketUseCase
    }

    class PaymentBloc {
        +CreatePaymentIntentUseCase createPaymentIntentUseCase
        +ConfirmPaymentUseCase confirmPaymentUseCase
    }

    class NotificationBloc {
        +GetNotificationsUseCase getNotificationsUseCase
    }

    class ProfileBloc {
        +GetProfileUseCase getProfileUseCase
        +UpdateProfileUseCase updateProfileUseCase
    }

    %% ── Use Cases ───────────────────────────────────────────
    class LoginUseCase {
        +call(String, String) Future~Either~Failure, User~~
    }
    class RegisterUseCase {
        +call(String, String, String, String) Future~Either~Failure, User~~
    }
    class CreateEventUseCase {
        +call(Event) Future~Either~Failure, Event~~
    }
    class ValidateTicketUseCase {
        +call(String) Future~Either~Failure, Ticket~~
    }

    %% ── Relations ───────────────────────────────────────────
    NetworkInfoImpl ..|> NetworkInfo
    Failure <|-- ServerFailure
    Failure <|-- CacheFailure
    Failure <|-- NetworkFailure
    Failure <|-- AuthFailure
    Failure <|-- ValidationFailure

    User --> UserRole
    Event --> EventCategory
    Event --> EventStatus
    Booking --> BookingStatus
    Ticket --> TicketStatus
    Payment --> PaymentStatus
    AppNotification --> NotificationType
    Profile --> UserRole

    AuthBloc --> LoginUseCase
    AuthBloc --> RegisterUseCase
    AuthBloc --> ForgotPasswordUseCase
    AuthBloc --> LogoutUseCase
    EventBloc --> GetEventByIdUseCase
    EventBloc --> GetEventsUseCase
    EventBloc --> CreateEventUseCase
    EventBloc --> UpdateEventUseCase
    EventBloc --> DeleteEventUseCase
    BookingBloc --> CreateBookingUseCase
    BookingBloc --> GetUserBookingsUseCase
    TicketBloc --> ValidateTicketUseCase
    TicketBloc --> GetUserTicketsUseCase
    PaymentBloc --> CreatePaymentIntentUseCase
    PaymentBloc --> ConfirmPaymentUseCase

    LoginUseCase --> AuthRepository
    RegisterUseCase --> AuthRepository
    CreateEventUseCase --> EventRepository
    ValidateTicketUseCase --> TicketRepository
```

---

## 6. MODÈLE CONCEPTUEL DE DONNÉES (MCD)

```mermaid
erDiagram
    UTILISATEUR ||--o{ EVENEMENT : "organise"
    UTILISATEUR ||--o{ RESERVATION : "effectue"
    UTILISATEUR ||--o{ TICKET : "possède"
    UTILISATEUR ||--o{ NOTIFICATION : "reçoit"
    UTILISATEUR ||--o{ PROFIL : "a"
    CATEGORIE ||--o{ EVENEMENT : "classe"
    EVENEMENT ||--o{ RESERVATION : "concerne"
    EVENEMENT ||--o{ TICKET : "génère"
    RESERVATION ||--o{ PAIEMENT : "nécessite"
    RESERVATION ||--o{ TICKET : "produit"

    UTILISATEUR {
        string id PK
        string email
        string nom
        string telephone "nullable"
        string photo_url "nullable"
        string role "organisateur | participant"
        datetime date_creation
    }

    CATEGORIE {
        string id PK
        string libelle
    }

    EVENEMENT {
        string id PK
        string titre
        text description
        string image_url "nullable"
        datetime date_debut
        datetime date_fin "nullable"
        string lieu
        string ville "nullable"
        float latitude "nullable"
        float longitude "nullable"
        float prix
        int participants_max
        int participants_actuels
        string categorie_id FK
        string organisateur_id FK
        string statut "brouillon | publié | annulé | terminé"
        datetime date_creation
        datetime date_modification
    }

    RESERVATION {
        string id PK
        string evenement_id FK
        string utilisateur_id FK
        int quantite
        float montant_total
        string statut "en_attente | confirmée | annulée | remboursée"
        datetime date_creation
    }

    TICKET {
        string id PK
        string evenement_id FK
        string utilisateur_id FK
        string reservation_id FK
        string code_qr
        string statut "actif | utilisé | annulé"
        datetime date_creation
    }

    PAIEMENT {
        string id PK
        string reservation_id FK
        float montant
        string devise
        string statut "en_attente | complété | échoué | remboursé"
        string stripe_intent_id "nullable"
        datetime date_creation
    }

    NOTIFICATION {
        string id PK
        string utilisateur_id FK
        string titre
        string corps
        string type "confirmation | paiement | annulation | rappel | general"
        text donnees "nullable"
        bool lue
        datetime date_creation
    }

    PROFIL {
        string id PK
        string utilisateur_id FK
        string biographie "nullable"
        string site_web "nullable"
        string reseaux_sociaux "nullable"
    }
```

### Légende du MCD

| Symbole | Signification |
|---------|---------------|
| `||--o{` | 1 → N (un à plusieurs) |
| `id PK` | Clé primaire |
| `FK` | Clé étrangère |
| `?` | Optionnel (nullable) |

### Règles de gestion

| Règle | Description |
|-------|-------------|
| RG01 | Un **Utilisateur** ne peut avoir qu'un seul **Profil** |
| RG02 | Un **Utilisateur** peut organiser 0 ou plusieurs **Événements** |
| RG03 | Un **Utilisateur** peut effectuer 0 ou plusieurs **Réservations** |
| RG04 | Un **Utilisateur** peut posséder 0 ou plusieurs **Tickets** |
| RG05 | Un **Utilisateur** peut recevoir 0 ou plusieurs **Notifications** |
| RG06 | Une **Catégorie** peut classer 0 ou plusieurs **Événements** |
| RG07 | Un **Événement** peut avoir 0 ou plusieurs **Réservations** |
| RG08 | Un **Événement** peut générer 0 ou plusieurs **Tickets** |
| RG09 | Une **Réservation** nécessite 0 ou 1 **Paiement** |
| RG10 | Une **Réservation** produit 0 ou plusieurs **Tickets** |
| RG11 | Un **Ticket** ne peut être scanné qu'une seule fois (statut → USED) |
| RG12 | Un **Paiement** est obligatoire pour les événements payants (prix > 0) |
| RG13 | Un **Utilisateur** de rôle `organisateur` peut créer/modifier/supprimer ses événements |
| RG14 | Un **Utilisateur** de rôle `participant` peut réserver et annuler ses réservations |

---

## 7. DIAGRAMME DE NAVIGATION (GO ROUTER)

```mermaid
graph TD
    START["/splash<br/>SplashPage"] -->|"2s"| ONBOARD["/onboarding<br/>OnboardingPage"]
    START -->|"si déjà onboardé"| LOGIN["/login<br/>LoginPage"]
    ONBOARD --> LOGIN
    LOGIN -->|"s'inscrire"| REG["/register<br/>RegisterPage"]
    LOGIN -->|"mdp oublié"| FP["/forgot-password<br/>ForgotPasswordPage"]
    LOGIN -->|"succès"| HOME

    subgraph "ShellRoute (Bottom Nav)"
        HOME["/<br/>EventListPage"]
        TICK["/tickets<br/>TicketsPage"]
        NOTIF["/notifications<br/>NotificationsPage"]
        PROF["/profile<br/>ProfilePage"]
    end

    HOME -->|"event"| DETAIL["/event-details<br/>EventDetailPage"]
    HOME -->|"créer"| CREATE["/create-event<br/>CreateEventPage"]
    HOME -->|"+"| CREATE
    DETAIL -->|"réserver"| BOOK["/booking<br/>BookingPage"]
    TICK -->|"voir QR"| QR["/qr-code<br/>QrCodePage"]
    TICK -->|"scanner"| SCAN["/qr-scanner<br/>QrScannerPage"]
    PROF -->|"modifier"| EDIT["/edit-profile<br/>EditProfilePage"]
    PROF -->|"paramètres"| SETT["/settings<br/>SettingsPage"]

    HOME -->|"organizer"| DASH["/organizer-dashboard<br/>OrganizerDashboardPage"]
    DASH -->|"gérer"| MGMT["/manage-events<br/>ManageEventsPage"]
    MGMT -->|"éditer"| EDIT_EVT["/edit-event<br/>CreateEventPage(edit)"]
    MGMT -->|"créer"| CREATE
    SCAN -->|"résultat"| VALID{"Ticket<br/>Valide/Invalide"}
```

### Protection des routes

| Condition | Redirection |
|-----------|-------------|
| Non authentifié → route protégée | → `/login` |
| Authentifié → `/login`, `/register`, `/forgot-password`, `/splash`, `/onboarding` | → `/` |
| Sinon | Route demandée |

---

## 8. DIAGRAMME DE SÉQUENCE — FLUX D'AUTHENTIFICATION

> **Backend :** Supabase Auth (JWT) — pas de serveur Spring Boot

```mermaid
sequenceDiagram
    actor User as Utilisateur
    participant UI as LoginPage
    participant BLOC as AuthBloc
    participant UC as LoginUseCase
    participant REPO as AuthRepositoryImpl
    participant SUPABASE as Supabase Auth
    participant SS as SecureStorage

    User->>UI: Saisit email + password
    UI->>BLOC: LoginEvent(email, password)
    BLOC->>BLOC: emit(AuthLoading)
    BLOC->>UC: call(email, password)
    UC->>REPO: login(email, password)
    REPO->>SUPABASE: signIn(email, password)
    SUPABASE-->>REPO: AuthResponse (session + user)
    REPO->>SS: save JWT token
    SS-->>REPO: done
    REPO-->>UC: Right(User)
    UC-->>BLOC: Right(User)
    BLOC->>BLOC: emit(Authenticated(user))
    UI->>UI: Navigate to Home
```

---

## 9. DIAGRAMME DE SÉQUENCE — FLUX QR CODE

> **Backend :** Supabase PostgreSQL (table `tickets`) — pas de serveur Spring Boot

```mermaid
sequenceDiagram
    actor Org as Organisateur
    participant SCAN as QrScannerPage
    participant TBLOC as TicketBloc
    participant UC as ValidateTicketUseCase
    participant REPO as TicketRepositoryImpl
    participant API as Supabase (PostgREST)
    participant DB as PostgreSQL

    Org->>SCAN: Scanne QR code
    SCAN->>TBLOC: ValidateTicketEvent(qrCode)
    TBLOC->>UC: call(qrCode)
    UC->>REPO: validateTicket(qrCode)
    REPO->>API: supabase.from('tickets').select().eq('qr_code', qr)
    API->>DB: SELECT * FROM tickets WHERE qr_code = ?
    DB-->>API: Ticket (active)
    REPO->>API: supabase.from('tickets').update({'status': 'used'})
    API->>DB: UPDATE tickets SET status = 'used'
    DB-->>API: done
    API-->>REPO: Ticket mis à jour
    REPO-->>UC: Right(Ticket)
    UC-->>TBLOC: Right(Ticket)
    TBLOC->>TBLOC: emit(TicketValidated)
    SCAN->>SCAN: Affiche "✅ Billet valide"
```

---

## 10. DIAGRAMME DE DÉPLOIEMENT

```mermaid
graph TB
    subgraph "Client Mobile"
        A["Appareil Android / iOS<br/>Flutter App"]
    end

    subgraph "Supabase Cloud"
        B["Supabase Auth<br/>JWT + Sessions"]
        C["Supabase PostgreSQL<br/>RLS Policies"]
        D["Supabase Storage<br/>Images"]
    end

    A -->|"Supabase SDK"| B
    A -->|"postgrest (SQL)"| C
    A -->|"Storage API"| D
```

---

## 11. TABLEAUX DES ENDPOINTS API

> **Note :** Le projet utilise Supabase comme unique backend. Les endpoints ci-dessous sont fournis à titre de référence pour une éventuelle API REST mais ne sont pas implémentés dans le code actuel.

### Authentification

| Méthode | Path | Auth | Body | Réponse |
|---------|------|------|------|---------|
| `POST` | `/api/auth/register` | ❌ | `RegisterRequest` | `201` → `AuthResponse` (JWT + user) |
| `POST` | `/api/auth/login` | ❌ | `LoginRequest` | `200` → `AuthResponse` (JWT + user) |

### Catégories

| Méthode | Path | Auth | Body | Réponse |
|---------|------|------|------|---------|
| `GET` | `/api/categories` | ✅ | — | `200` → `List<Category>` |
| `POST` | `/api/categories` | ✅ | `CategoryRequest` | `201` → `Category` |

### Événements

| Méthode | Path | Rôle | Body | Réponse |
|---------|------|------|------|---------|
| `GET` | `/api/events` | ✅ Auth any | — | `200` → `List<EventResponse>` |
| `GET` | `/api/events/{id}` | ✅ Auth any | — | `200` → `EventResponse` |
| `POST` | `/api/events` | 🔒 ORGANIZER | `EventRequest` | `201` → `EventResponse` |
| `PUT` | `/api/events/{id}` | 🔒 ORGANIZER (owner) | `EventRequest` | `200` → `EventResponse` |
| `DELETE` | `/api/events/{id}` | 🔒 ORGANIZER (owner) | — | `204` No Content |

### Invitations (QR Code)

| Méthode | Path | Auth | Body | Réponse |
|---------|------|------|------|---------|
| `POST` | `/api/invitations` | ✅ | `InvitationRequest` | `201` → `InvitationResponse` |
| `GET` | `/api/invitations/my` | ✅ | — | `200` → `List<InvitationResponse>` |
| `POST` | `/api/invitations/verify` | ✅ | `QrVerifyRequest` | `200` → `{ message, status }` |

---

## 12. SCHÉMA DE LA BASE DE DONNÉES (PostgreSQL — Supabase)

Le schéma complet est défini dans `supabase_schema.sql` à la racine du projet. Il inclut les tables :

- `profiles` — utilisateurs (lié à Supabase Auth)
- `events` — événements avec RLS
- `bookings` — réservations
- `tickets` — billets avec QR codes
- `payments` — paiements
- `notifications` — notifications

Avec politiques Row Level Security (RLS) pour la sécurité au niveau ligne.

---

## 13. STACK TECHNIQUE

### Frontend (Flutter)

| Technologie | Version | Usage |
|-------------|---------|-------|
| Dart SDK | `^3.12.1` | Langage |
| `flutter_bloc` | `^8.1.6` | State management (BLoC pattern) |
| `go_router` | `^14.8.1` | Navigation avec guards |
| `supabase_flutter` | `^2.8.4` | HTTP client + Auth + Database SDK |
| `supabase_flutter` | `^2.8.4` | Auth backend |
| `get_it` | `^8.0.3` | Injection de dépendances |
| `dartz` | `^0.10.1` | Functional (Either pour error handling) |
| `equatable` | `^2.0.7` | Value equality |
| `json_annotation` | `^4.9.0` | JSON serialization |
| `flutter_secure_storage` | `^9.2.4` | Stockage sécurisé JWT |
| `connectivity_plus` | `^6.1.2` | Vérification réseau |
| `qr_flutter` | `^4.1.0` | Génération QR code |
| `mobile_scanner` | `^6.0.6` | Scanner QR code (caméra) |
| `image_picker` | `^1.1.2` | Sélection photo |
| `cached_network_image` | `^3.4.1` | Cache images réseau |
| `lottie` | `^3.3.1` | Animations Lottie |
| `shimmer` | `^3.0.0` | Effet de chargement |
| `flutter_localizations` | SDK | Internationalisation |
| `intl` | `^0.20.2` | i18n + ARB files |
| `flutter_screenutil` | `^5.9.3` | Responsive design |
| `flutter_svg` | `^2.0.17` | SVG rendering |

### Backend

| Technologie | Usage |
|-------------|-------|
| Supabase Auth | Authentification (JWT) |
| Supabase PostgreSQL | Base de données avec Row Level Security |
| Supabase Storage | Stockage d'images |

### Tests

| Technologie | Type | Status |
|-------------|------|--------|
| `flutter_test` | Widget | ✅ |
| `bloc_test` | Bloc | ✅ |
| `mocktail` | Mocking | ✅ |

---

## 14. DIAGRAMME DES ÉTATS BLOC

### AuthBloc

```mermaid
graph LR
    INIT["AuthInitial"] -->|"CheckAuthEvent"| LOADING["AuthLoading"]
    LOADING -->|"session != null"| AUTH["Authenticated"]
    LOADING -->|"session == null"| UNAUTH["Unauthenticated"]
    INIT -->|"LoginEvent / RegisterEvent"| LOADING
    LOADING -->|"succès"| AUTH
    LOADING -->|"erreur"| ERROR["AuthError"]
    AUTH -->|"LogoutEvent"| LOADING
    LOADING -->|"succès"| UNAUTH
    ERROR -->|"LoginEvent / RegisterEvent"| LOADING
    UNAUTH -->|"LoginEvent / RegisterEvent"| LOADING
```

### EventBloc

```mermaid
graph LR
    INIT["EventInitial"] -->|"GetEventsEvent"| EVLOAD["EventLoading"]
    EVLOAD -->|"succès"| LOADED["EventsLoaded"]
    EVLOAD -->|"erreur"| ERR["EventError"]
    INIT -->|"CreateEventEvent"| EVLOAD
    EVLOAD -->|"créé"| CREATED["EventCreated"]
    EVLOAD -->|"update"| UPDATED["EventUpdated"]
    EVLOAD -->|"supprimé"| DELETED["EventDeleted"]
```

---

## 15. FICHIERS DE TRADUCTION (ARB)

| Clé | Anglais (`app_en.arb`) | Français (`app_fr.arb`) | Arabe (`app_ar.arb`) |
|-----|------------------------|-------------------------|----------------------|
| `app_name` | EventHub | EventHub | إيفنت هب |
| `login` | Login | Connexion | تسجيل الدخول |
| `register` | Register | S'inscrire | إنشاء حساب |
| `email` | Email | Email | البريد الإلكتروني |
| `password` | Password | Mot de passe | كلمة المرور |
| `events` | Events | Événements | الأحداث |
| `tickets` | Tickets | Billets | التذاكر |
| `notifications` | Notifications | Notifications | الإشعارات |
| `profile` | Profile | Profil | الملف الشخصي |
| *(total: 45 clés par langue)* | | | |

---

## 16. SCHÉMA D'INJECTION DE DÉPENDANCES (GetIt)

```mermaid
graph TD
    subgraph "Core"
        FSS["FlutterSecureStorage"]
        TM["TokenManager"]
        API["ApiClient (Dio)"]
        NI["NetworkInfo"]
    end

    subgraph "Features"
        subgraph "Auth"
            ASD["AuthSupabaseDataSource"]
            ARepo["AuthRepositoryImpl"]
            LUC["LoginUseCase"]
            RUC["RegisterUseCase"]
            FUC["ForgotPasswordUseCase"]
            LoUC["LogoutUseCase"]
            AB["AuthBloc"]
        end

        subgraph "Events"
            EDS["EventRemoteDataSource"]
            ERepo["EventRepositoryImpl"]
            GE["GetEventsUseCase"]
            GEBID["GetEventByIdUseCase"]
            CE["CreateEventUseCase"]
            UE["UpdateEventUseCase"]
            DE["DeleteEventUseCase"]
            EB["EventBloc"]
        end

        subgraph "Other"
            B["Bookings Feature"]
            T["Tickets Feature"]
            P["Payments Feature"]
            N["Notifications Feature"]
            PR["Profile Feature"]
        end
    end

    TM --> FSS
    API --> TM
    ARepo --> ASD
    ARepo --> NI
    LUC --> ARepo
    RUC --> ARepo
    AB --> LUC
    AB --> RUC
    AB --> FUC
    AB --> LoUC

    ERepo --> EDS
    ERepo --> NI
    EB --> GE
    EB --> GEBID
    EB --> CE
    EB --> UE
    EB --> DE
```

---

## 17. DÉPENDANCES ENTRE PACKAGES (FRONTEND)

```
main.dart
├── supabase_flutter (initialization)
├── get_it (DI container)
└── MultiBlocProvider (7 blocs)

core/
├── constants/       ← api_constants, app_constants, supabase_constants
├── di/              ← injection_container (importe TOUS les blocs/repos/usecases)
├── errors/          ← exceptions, failures (utilisés par toutes les features)
├── network/         ← Supabase client, network_info (connectivity)
├── router/          ← app_router (importe toutes les pages)
└── utils/           ← date_utils, token_manager, validators

features/{feature}/
├── data/
│   ├── datasources/ ← Appelle Supabase (via supabase_flutter SDK)
│   ├── models/       ← JSON serialization
│   └── repositories/ ← Implémente l'interface domain
├── domain/
│   ├── entities/     ← Classes métier (extends Equatable)
│   ├── repositories/ ← Interfaces abstraites
│   └── usecases/     ← Appellent le repository
└── presentation/
    ├── bloc/         ← Bloc + Events + States
    ├── pages/        ← Screens Flutter
    └── widgets/      ← Composants réutilisables
```

---

## 18. COUVERTURE DE TESTS

| Feature | Type | Fichier | Tests |
|---------|------|---------|-------|
| ✅ Core | Unitaire | `network_info_test.dart` | 3 |
| ✅ Core | Unitaire | `date_utils_test.dart` | 4 |
| ✅ Core | Unitaire | `token_manager_test.dart` | 4 |
| ✅ Core | Unitaire | `validators_test.dart` | 20+ |
| ✅ Shared | Widget | `empty_widget_test.dart` | 3 |
| ✅ Shared | Widget | `error_widget_test.dart` | 3 |
| ✅ Shared | Widget | `loading_widget_test.dart` | 3 |
| ✅ Auth | Repository | `auth_repository_impl_test.dart` | 8 |
| ✅ Auth | UseCase | `login_usecase_test.dart` | 2 |
| ✅ Auth | UseCase | `register_usecase_test.dart` | 2 |
| ✅ Auth | UseCase | `forgot_password_usecase_test.dart` | 2 |
| ✅ Auth | Bloc | `auth_bloc_test.dart` | 5 |
| ✅ Auth | Widget | `login_page_test.dart` | 6 |
| ✅ Auth | Widget | `register_page_test.dart` | 4 |
| ✅ Auth | Widget | `forgot_password_page_test.dart` | 2 |
| ✅ Auth | Intégration | `login_flow_integration_test.dart` | 4 |
| ✅ Auth | Intégration | `register_flow_integration_test.dart` | 3 |
| ✅ Bookings | Bloc | `booking_bloc_test.dart` | 3 |
| ✅ Events | Bloc | `event_bloc_test.dart` | 5 |
| ✅ Events | Widget | `event_card_test.dart` | 7 |
| ✅ General | Smoke | `widget_test.dart` | 1 |
| ❌ Payments | Bloc | `payment_bloc_test.dart` | **0 test** |
| ❌ Notifications | — | — | **0 test** |
| ❌ Profile | — | — | **0 test** |
| ❌ Admin | — | — | **0 test** |

---

## 19. SCHÉMA DE SÉCURITÉ

```mermaid
graph TD
    subgraph "Supabase Auth"
        USER["Utilisateur"] --> LOGIN["Login / Register"]
        LOGIN --> SUPABASE["Supabase Auth"]
        SUPABASE --> JWT["JWT Token"]
        JWT --> STORAGE["FlutterSecureStorage"]
    end

    subgraph "Row Level Security (RLS)"
        DB["PostgreSQL"] --> POLICY["RLS Policies"]
        POLICY -->|"profiles"| PROF_P["Users can read/write own profile"]
        POLICY -->|"events"| EVT_P["Organizers CRUD own events<br/>Participants read published"]
        POLICY -->|"bookings"| BOOK_P["Users CRUD own bookings<br/>Organizers read event bookings"]
        POLICY -->|"tickets"| TICK_P["Users read own tickets<br/>Organizers read event tickets"]
    end

    SUPABASE --> DB
    JWT --> DB
```

---

## 20. VARIABLES D'ENVIRONNEMENT / CONFIGURATION

```dart
// ===== Frontend (supabase_constants.dart) =====
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String anonKey = '...';
```

Les credentials peuvent être passés au build-time :

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## 21. THÈME MATERIAL 3 — PALETTE DE COULEURS

```dart
static const Color primary   = Color(0xFF6C63FF);  // Violet (branding)
static const Color accent    = Color(0xFFFF6B35);  // Orange (CTA)
static const Color white     = Color(0xFFFFFFFF);
static const Color black     = Color(0xFF1A1A2E);  // Texte foncé
static const Color error     = Color(0xFFE53935);  // Rouge erreur
static const Color success   = Color(0xFF4CAF50);  // Vert succès
static const Color warning   = Color(0xFFFFC107);  // Jaune avertissement
static const Color surfaceLight = Color(0xFFF5F5F5);
static const Color surfaceDark  = Color(0xFF121212);
```

---

## 22. OBSERVATIONS ET NOTES

| # | Observation | Détail |
|---|-------------|--------|
| 1 | **Spring Boot supprimé** | Le backend Spring Boot a été retiré du projet. L'architecture est désormais 100% Flutter + Supabase. La documentation a été mise à jour en conséquence. |
| 2 | **QR Codes** | Le frontend utilise `qr_flutter` pour l'affichage et `mobile_scanner` pour le scan. Les QR codes sont stockés en base Supabase. |
| 3 | **Paiements Stripe** | L'architecture est préparée (entité `Payment`, datasource Supabase) mais il n'y a pas d'intégration réelle du SDK Stripe. Les paiements sont simulés via des enregistrements en base. |
| 4 | **Tests** | ~90 tests (bonne couverture auth, events, bookings, shared widgets). Manque : tests pour payments, notifications, profile, admin. |
| 5 | **CI/CD** | Pipeline GitHub Actions présent (`.github/workflows/ci.yml`) : `flutter analyze` + `flutter test`. |
| 6 | **Thème/Langue** | Persistés localement via `SharedPreferences`. Pas de synchro backend (non nécessaire sans compte multi-appareil). |
| 7 | **Dashboard** | Les statistiques de `OrganizerDashboardPage` sont calculées dynamiquement depuis les événements chargés. |
| 8 | **Dépendances** | Plusieurs packages ont des versions majeures disponibles (`go_router`, `get_it`, `mobile_scanner`, etc.). |
