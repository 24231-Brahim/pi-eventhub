# 🎯 Prompt Google Stitch — EventHub

```
PROJECT NAME: EventHub
PLATFORM: Mobile (iOS/Android) — 390x844 viewport
FRAMEWORK: Flutter (Material 3)

---

DESIGN SYSTEM (DESIGN.md):

Brand colors:
- Background dark: #0F0F0F (main dark bg)
- Surface/Cards dark: #202020 (card backgrounds)
- Primary: #5DD62C (vibrant green — buttons, active states, highlights)
- Primary dark: #337418 (darker green — pressed states, badges)
- Text/BG light: #F8F8F8 (light text on dark, main bg light mode)
- Error: #E53935
- Warning: #FFC107

Light mode:
- Background: #F8F8F8
- Cards: #FFFFFF
- Text primary: #0F0F0F
- Buttons: #5DD62C

Dark mode:
- Background: #0F0F0F
- Cards: #202020
- Text primary: #F8F8F8
- Buttons: #5DD62C

Typography:
- Headings: Poppins or Inter, bold
- Body: Inter or Roboto, regular
- Button labels: Medium weight, 16sp, #F8F8F8 on #5DD62C

UI Patterns:
- Material 3 with rounded corners (border-radius: 12)
- Cards: #202020 bg in dark mode, subtle elevation
- Input fields: filled style, rounded 12px
- Buttons: full-width, 48px height, rounded 12px, solid #5DD62C
- Bottom nav: Material 3 NavigationBar with 4 tabs
- Green accent (#5DD62C) for all active states, icons, links

---

SCREENS TO GENERATE (5-screen canvas):

=== SCREEN 1: SPLASH & ONBOARDING ===

1A. Splash Screen:
- Solid #0F0F0F background
- Centered white/green glowing logo
- Tagline "Discover amazing events near you" in #F8F8F8
- Green accent line animation (#5DD62C)

1B. Onboarding (3-step carousel):
- Step 1: "Browse Events" — icon + "Explore concerts, conferences & more"
- Step 2: "Book Tickets" — icon + "Secure your spot in seconds"
- Step 3: "Enjoy & Share" — icon + "QR tickets, share with friends"
- Dot indicators: active #5DD62C, inactive #202020
- "Get Started" button: #5DD62C bg, #F8F8F8 text
- "Skip" top-right in #F8F8F8 60% opacity

=== SCREEN 2: AUTHENTICATION ===

2A. Login Page:
- #0F0F0F background
- App name/logo at top in #5DD62C
- Email field: #202020 bg, #F8F8F8 text, rounded
- Password field with eye toggle
- "Forgot Password?" in #5DD62C
- "Sign In" button: #5DD62C bg
- Divider "or continue with" in #F8F8F8 50%
- Google sign-in outlined button
- "Don't have an account? Sign Up" — "Sign Up" in #5DD62C

2B. Register:
- Same style + Name, Phone, Confirm password
- "Create Account" in #5DD62C
- Back to login link

2C. Forgot Password:
- Centered, email field, "Send Reset Link" green button

=== SCREEN 3: HOME / EVENT EXPLORER ===

- Top bar: "EventHub" in #F8F8F8 + bell icon + avatar
- Search bar: #202020 bg, #F8F8F8 text
- Category chips: All, Music, Tech, Sports, Food, Art, Business
  - Active: #5DD62C bg, #0F0F0F text
  - Inactive: #202020 bg, #F8F8F8 text
- Featured hero card: large image, gradient overlay, title in #F8F8F8, "Featured" badge in #5DD62C
- Event list cards: #202020 bg, image left, title + date + location + price
- Bottom Nav (4 tabs):
  - Explore, Tickets, Notifications, Profile
  - Active: #5DD62C icon + label
  - Inactive: #F8F8F8 50%
- Shimmer loading in #202020
- Empty state: illustration + "No events yet" in #F8F8F8

=== SCREEN 4: EVENT DETAILS & BOOKING ===

4A. Event Details:
- #0F0F0F bg
- Full-width hero image, back arrow + heart icon (#5DD62C when liked)
- Category badge: #202020 bg, #5DD62C text
- Title in #F8F8F8, organizer row
- Info icons in #5DD62C: calendar, location pin, people
- Price highlight: #5DD62C text
- Description in #F8F8F8 80%
- Fixed bottom: "Book Now" — #5DD62C full-width button

4B. Booking:
- Event summary card: #202020 bg
- Quantity selector: - | 2 | + in green
- Price breakdown: subtotal, fee, total (green highlight)
- "Pay Now" — #5DD62C button
- Success: checkmark in #5DD62C, "Booking Confirmed!" in #F8F8F8
- Error state: red message + "Try Again"

=== SCREEN 5: TICKETS, NOTIFICATIONS & PROFILE ===

5A. My Tickets:
- Segments: "Upcoming" | "Past" — active underline #5DD62C
- Ticket cards: #202020 bg
  - Event thumbnail, title, date, venue in #F8F8F8
  - QR code preview
  - Status: Active (#5DD62C) / Used (#202020) / Cancelled (#E53935)
- QR Detail: large QR, event info, ticket ID
- Organizer Scanner: camera viewfinder, green success overlay, red invalid

5B. Notifications:
- List items: #202020 bg cards
- Icon dot: unread = #5DD62C dot
- Time ago in #F8F8F8 60%
- "Mark all read" in #5DD62C
- Empty: bell icon + "No notifications"

5C. Profile:
- Avatar with green #5DD62C edit icon
- Name + email + role badge (#5DD62C outline)
- Stats row in #F8F8F8
- Menu items with icons:
  - My Bookings, Edit Profile, Settings (theme/language),
  - About, Log Out (#E53935 red)
- Organizer extra: Dashboard, My Events, Create Event (+), Scan Tickets
- Admin extra: Admin Panel, Users, Analytics

---

INTERACTIONS:
- Green (#5DD62C) active states everywhere
- Tappable feedback on all cards
- Pull-to-refresh on lists
- Shimmer skeletons #202020
- Error: red illustration + "Try Again"
- Empty: illustration + #F8F8F8 text + #5DD62C CTA
- Dark mode default: #0F0F0F bg, #202020 cards, #F8F8F8 text, #5DD62C accent
- Smooth slide transitions
```

---

## 💡 Tips pour Stitch

1. **Copie-colle** toute la prompte dans Stitch
2. Sélectionne le modèle **Gemini 3.1 Pro** pour la meilleure qualité
3. Commande d'abord : *"Generate the DESIGN.md design system first"*
4. Ensuite : *"Generate all 5 screens following this design system exactly"*
5. Utilise **"Instant Prototype"** pour lier les écrans
6. Dark mode : *"Create a dark mode variant for every screen"*
7. Export : *"Export all screens as HTML/CSS code"*
