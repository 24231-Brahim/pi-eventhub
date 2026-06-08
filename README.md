# EventHub

Mobile event management platform built with Flutter and Supabase.

## Features

- **Event Discovery** - Browse, search, and filter events
- **Booking & Ticketing** - Book events with QR code tickets
- **Organizer Dashboard** - Create and manage events, scan tickets
- **Admin Panel** - Platform-wide management and analytics
- **Multi-language** - English, French, Arabic
- **Dark/Light Theme** - Persisted theme preference
- **Favorites** - Save events for later

## Tech Stack

- **Frontend:** Flutter (Dart), Clean Architecture, BLoC State Management
- **Backend:** Supabase (Authentication, Database, Storage)
- **Localization:** flutter_localizations + ARB files
- **Routing:** go_router with auth guards

## Prerequisites

- Flutter SDK ^3.12.1
- A Supabase project (or use the existing demo one)

## Getting Started

1. Clone the repository
2. Navigate to the Flutter app:
   ```bash
   cd eventhub
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Generate localization files:
   ```bash
   flutter gen-l10n
   ```
5. Run the app:
   ```bash
   flutter run
   ```

### Using your own Supabase project

Pass your Supabase credentials at build time:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or update the defaults in `lib/core/constants/supabase_constants.dart`.

## Project Structure

```
eventhub/
├── lib/
│   ├── core/           # Constants, DI, errors, router, utils
│   ├── features/       # Feature modules (auth, events, bookings, etc.)
│   │   ├── data/       # Data sources, repositories, models
│   │   ├── domain/     # Entities, use cases, repository interfaces
│   │   └── presentation/ # BLoC, pages, widgets
│   ├── l10n/           # Localization ARB files
│   ├── presentation/   # Shared pages (splash, onboarding, settings)
│   └── shared/         # Themes, widgets, services
└── test/               # Unit and widget tests
```

## Testing

```bash
flutter test
```

## License

MIT
