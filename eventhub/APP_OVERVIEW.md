# EventHub - Application Overview

EventHub is a **Flutter mobile app** for event management with Supabase backend. Built with **Clean Architecture** + **BLoC pattern** + **GetIt DI**.

---

## 🏗️ Architecture
- **Features**: 8 modules (Auth, Events, Bookings, Tickets, Payments, Notifications, Profile, Admin)
- **Layers**: Domain (entities/use-cases/repos) → Data (models/datasources/repos) → Presentation (pages/blocs/widgets)
- **Navigation**: GoRouter with auth/admin guards
- **State**: flutter_bloc (8 Blocs)
- **Localization**: EN/FR/AR (flutter_localizations + intl)
- **Theming**: Light/Dark + responsive (flutter_screenutil)

---

## 🔐 Auth Feature
| Capability | Details |
|---|---|
| **Login/Register** | Email/password via Supabase Auth |
| **Forgot Password** | Reset email flow |
| **Roles** | `admin`, `organizer`, `participant` (UserRole enum) |
| **Session** | Auto-check on splash, secure token storage (flutter_secure_storage) |
| **Auth Guard** | Routes protected; redirects to `/login` if unauthenticated |

---

## 🎪 Events Feature
| Capability | Details |
|---|---|
| **Browse Events** | List with filters, search, pagination |
| **Event Detail** | Full info, image, location, map coords, price, capacity |
| **Categories** | conference, concert, exhibition, training, workshop, sports, seminar, community |
| **Statuses** | draft, published, cancelled, completed |
| **Favorites** | Toggle + list user's favorite IDs |
| **Organizer Tools** | Create/Edit/Delete events, dashboard, manage events list |
| **Event Visibility** | Public (anyone can book) or Private (only invited people can book) |
| **Invitations** | Add by email, bulk import from CSV file |
| **Admin Review** | Events require approval (rejectionReason field) |

---

## 📅 Bookings Feature
| Capability | Details |
|---|---|
| **Create Booking** | Select quantity → creates pending booking |
| **My Bookings** | List with event details, status (pending/confirmed/cancelled/refunded) |
| **Confirm Booking** | Free events: direct confirm → ticket → QR code. Paid events: payment → confirm → ticket → QR code |
| **Cancel Booking** | Cancel existing bookings |
| **Payment Integration** | Triggers payment intent creation for paid events |

---

## 🎫 Tickets Feature
| Capability | Details |
|---|---|
| **My Tickets** | List linked to bookings |
| **QR Code Display** | Unique QR per ticket (qr_flutter) |
| **QR Scanner** | Organizer-only validation (mobile_scanner), distinct dialogs per status |
| **Validation** | Marks ticket as `used` / `active` / `cancelled`, organizer ownership check |

---

## 💳 Payments Feature
| Capability | Details |
|---|---|
| **Stripe Integration** | PaymentIntent creation + confirmation |
| **Currency** | TND (Tunisian Dinar) |
| **Statuses** | pending, completed, failed, refunded |
| **Flow** | Booking → PaymentIntent → Confirm → Ticket generated |

---

## 🔔 Notifications Feature
| Capability | Details |
|---|---|
| **Types** | bookingConfirmation, paymentConfirmed, eventCancelled, eventReminder, general |
| **Inbox** | List with read/unread, tap to mark read |
| **Real-time** | Supabase Realtime (implied by datasource) |

---

## 👤 Profile Feature
| Capability | Details |
|---|---|
| **View Profile** | Name, email, phone, photo, role, join date |
| **Edit Profile** | Update name, phone, photo (image_picker → Supabase Storage) |
| **Settings** | Theme (light/dark), Language (EN/FR/AR) persisted locally |

---

## 🛠️ Admin Feature (Role: Admin only)
| Page | Function |
|---|---|
| **Dashboard** | Stats: users, events, bookings, tickets, revenue |
| **Users** | List all, filter by role, manage |
| **Events** | Review/approve/reject organizer events |
| **Bookings** | View all bookings across platform |
| **Tickets** | View/validate all tickets |
| **Analytics** | Revenue, engagement charts |

---

## 🧱 Core/Shared
| Module | Purpose |
|---|---|
| **DI** | GetIt registers all repos, use-cases, blocs, services |
| **Network** | ConnectivityPlus check before API calls |
| **Storage** | SharedPreferences (theme/locale) + FlutterSecureStorage (tokens) |
| **TokenManager** | JWT handling for Supabase |
| **Validators** | Email, password, phone, required fields |
| **DateUtils** | Formatting helpers |
| **Themes** | Material 3 light/dark with custom colors |
| **Widgets** | Loading, Error, Empty states, Shimmer placeholders |

---

## 📱 Key Pages (from Router)
```
/splash → /onboarding → /login|/register|/forgot-password
  ↓ authenticated
/ (EventList) → /event-details/:id → /booking/:eventId → /qr-code
/tickets → /qr-scanner
/notifications
/profile → /edit-profile → /my-bookings
/organizer-dashboard → /manage-events → /create-event|/edit-event
/settings
/admin → /admin/users|/admin/events|/admin/bookings|/admin/tickets|/admin/analytics
```

---

## 🔑 Key Dependencies
- **Backend**: supabase_flutter (Auth, Database, Storage, Realtime)
- **State**: flutter_bloc, equatable, dartz (Either for failures)
- **Nav**: go_router
- **QR**: qr_flutter (generate), mobile_scanner (scan)
- **Media**: image_picker, cached_network_image
- **Utils**: intl, share_plus, path_provider, connectivity_plus

---

This is a **production-ready event platform** with role-based access, full booking→payment→ticket flow, organizer tools, and admin panel.