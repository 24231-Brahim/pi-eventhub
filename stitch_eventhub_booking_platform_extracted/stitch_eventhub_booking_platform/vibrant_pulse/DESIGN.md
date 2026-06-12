---
name: Vibrant Pulse
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#bdcbb2'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#88957e'
  outline-variant: '#3e4a37'
  surface-tint: '#67e037'
  primary: '#79f349'
  on-primary: '#0e3900'
  primary-container: '#5dd62c'
  on-primary-container: '#1a5800'
  inverse-primary: '#226d00'
  secondary: '#91d971'
  on-secondary: '#0e3900'
  secondary-container: '#1e5f00'
  on-secondary-container: '#91d870'
  tertiary: '#dad8d7'
  on-tertiary: '#303030'
  tertiary-container: '#bebcbc'
  on-tertiary-container: '#4c4c4b'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#83fe52'
  primary-fixed-dim: '#67e037'
  on-primary-fixed: '#052100'
  on-primary-fixed-variant: '#185200'
  secondary-fixed: '#acf68a'
  secondary-fixed-dim: '#91d971'
  on-secondary-fixed: '#062100'
  on-secondary-fixed-variant: '#195200'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1b1c1c'
  on-tertiary-fixed-variant: '#474746'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  headline-lg:
    fontFamily: Poppins
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Poppins
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Poppins
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Poppins
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 16px
  gutter: 12px
  stack-sm: 4px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

The design system is engineered for a high-energy event discovery environment. It targets a modern, mobile-first audience that values speed, excitement, and clarity. The aesthetic combines **Modern Corporate** structure with **High-Contrast** energy, utilizing a deep obsidian backdrop to make vibrant accents and event imagery pop.

The emotional response is one of "electric professionalism"—reliable enough to handle financial transactions for tickets, yet energetic enough to reflect the nightlife and entertainment industry. The style leverages Material 3 logic but injects a more aggressive, saturated personality through its primary color and dark-mode-first architecture.

## Colors

The palette is optimized for OLED displays and low-light environments typical of event venues. 

- **Main Dark (#0F0F0F):** Used for the base canvas to provide maximum contrast.
- **Surface (#202020):** Used for cards, sheets, and input backgrounds to create depth against the base.
- **Vibrant Green (#5DD62C):** The "Pulse" of the system. Reserved for primary actions, active states, and critical brand moments.
- **Semantic Colors:** Error Red and Warning Amber are tuned for high visibility against dark surfaces, ensuring user safety and clarity during the booking flow.

## Typography

This design system uses a dual-font strategy to balance character with readability. 

- **Headlines (Poppins):** Set in Bold or Semi-Bold. The geometric nature of Poppins provides a modern, friendly, yet high-impact feel for event titles and section headers.
- **Body & UI (Inter):** Chosen for its exceptional legibility at small sizes. Used for all descriptive text, metadata, and form labels.
- **Button Labels:** Specifically set to `label-lg` (16px, Medium weight) to ensure clear call-to-actions within high-energy layouts.

## Layout & Spacing

The system follows a strict **8px grid** to ensure mathematical harmony across mobile screens. 

- **Grid Model:** A 4-column fluid grid for mobile with 16px side margins and 12px gutters.
- **Touch Targets:** Minimum touch target size is 48px, specifically for buttons and navigation items.
- **Safe Areas:** Adhere to bottom-bar safe areas for gesture-based navigation, ensuring the 4-tab bottom nav is easily accessible.

## Elevation & Depth

Depth is communicated through **Tonal Layering** rather than heavy shadows. 

- **Level 0 (Base):** #0F0F0F - Background layer.
- **Level 1 (Cards/Inputs):** #202020 - Floating elements like event cards and bottom sheets.
- **Level 2 (Overlays):** #2C2C2C - Popovers or high-priority modals.
- **Shadows:** Use a single, subtle shadow for Level 1 elements: `0px 4px 12px rgba(0, 0, 0, 0.5)`. This adds a crisp edge to cards without muddying the dark aesthetic.

## Shapes

The design system utilizes a "Rounded" (Level 2) corner strategy. 

- **Standard Elements:** 12px (0.75rem) radius for cards, input fields, and buttons.
- **Large Elements:** 24px (1.5rem) for bottom sheets and featured hero banners.
- **Small Elements:** 8px (0.5rem) for tags and chips.
- **Selection:** Use fully pill-shaped (rounded-full) containers for category chips to distinguish them from actionable buttons.

## Components

### Buttons
- **Primary:** 48px height, solid #5DD62C background, #0F0F0F text. Rounded 12px.
- **Secondary:** 48px height, #202020 background with a 1px #5DD62C stroke.
- **States:** Hover/Press state for Primary is Primary Dark (#337418).

### Form Fields
- **Inputs:** "Filled" style using #202020 background, 12px rounded top corners, with a subtle bottom stroke that illuminates to #5DD62C on focus.
- **Labels:** Floating label style (Material 3) using Inter 12px for the focused state.

### Cards
- **Event Card:** Uses #202020 surface. Features a top-aligned image with a 12px radius. Content padding is 16px. Primary Green is used for price points or "Book Now" text links.

### Bottom Navigation
- **Structure:** 4 tabs (Explore, Tickets, Notifications, Profile).
- **Active State:** The active icon and label shift to #5DD62C. Use an "active indicator" pill behind the icon if consistent with Material 3 patterns.

### Chips & Tags
- **Category Chips:** Pill-shaped, #202020 background, #F8F8F8 text. On selection, the background becomes #5DD62C and text becomes #0F0F0F.