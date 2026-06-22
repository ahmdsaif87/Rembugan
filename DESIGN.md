---
name: Rembugan
description: Platform Kolaborasi, Matchmaking Proyek, dan Portofolio
colors:
  primary: "#4E61F6"
  primary-soft: "#EDEFFE"
  primary-tint: "#C8CEFC"
  primary-deep: "#3745AF"
  neutral-bg: "#FFFFFF"
  neutral-surface: "#FFFFFF"
  neutral-surface-secondary: "#F9FAFB"
  neutral-text-primary: "#131927"
  neutral-text-secondary: "#6D717F"
  neutral-text-tertiary: "#9EA2AE"
  neutral-border: "#E5E7EA"
  neutral-border-strong: "#D2D5DB"
  success: "#43B75D"
  error: "#EE443F"
  warning: "#FFAA00"
  info: "#0095FF"
  dark-bg: "#0F1119"
  dark-surface: "#181B25"
  dark-surface-elevated: "#1E2130"
  dark-text-primary: "#F0F1F5"
  dark-text-secondary: "#9EA2AE"
  dark-border: "#2A2E3D"
typography:
  display:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.12
  headline:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.25
  body:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.45
  label:
    fontFamily: "Inter, system-ui, -apple-system, sans-serif"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.3
rounded:
  sm: "12px"
  md: "16px"
  lg: "20px"
  pill: "999px"
spacing:
  xxs: "4px"
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.sm}"
    padding: "16px 24px"
  button-outlined:
    backgroundColor: "{colors.neutral-bg}"
    textColor: "{colors.neutral-text-primary}"
    rounded: "{rounded.sm}"
    padding: "16px 20px"
  card-default:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.md}"
    padding: "20px"
  input-default:
    backgroundColor: "{colors.neutral-surface-secondary}"
    rounded: "{rounded.sm}"
    padding: "16px"
---

# Design System: Rembugan

## 1. Overview

**Creative North Star: "The Campus Studio"**

Rembugan is a student collaboration platform that feels like a creative studio on campus — energetic but focused, collaborative without being chaotic. The design serves the primary job: finding teammates and building projects together.

The system is flat by default with tonal layering. Surfaces distinguish themselves through subtle borders and background shifts rather than shadows. Color is used with restraint: the indigo primary appears on interactive elements and key accents, never as decoration. The cool grey neutral palette keeps the interface quiet enough that content — projects, people, conversations — carries the visual energy.

This system explicitly rejects: the sterile corporate aesthetic of LinkedIn-clone dashboards, the childish gamification of badge-heavy student platforms, and the generic SaaS template of gradient heroes and identical card grids.

**Key Characteristics:**
- Flat surfaces with 1px borders; no shadows at rest
- Cool-grey neutral palette with a single indigo accent used sparingly
- Single sans-serif typeface (Inter) across all hierarchies
- Rounded but not pill-shaped corners (12–16px for surfaces)
- Mobile-first, action-oriented layout density
- Dark mode with inverted grey scale preserving the same hierarchy

## 2. Colors

The palette is restrained: a cool grey neutral base with one indigo accent. The indigo is reserved for interactive elements (buttons, links, active nav, selected states) and should cover ≤15% of any screen.

### Primary
- **Studio Indigo** (#4E61F6): Primary actions, active navigation, links, key accents. Use on interactive elements only — not for decorative backgrounds or section headers.
- **Indigo Soft** (#EDEFFE: Tinted backgrounds for selected/focused inputs, selected states, icon-button containers.
- **Indigo Deep** (#3745AF): Pressed state for primary buttons.

### Neutral
- **White** (#FFFFFF): App background, cards, surfaces in light mode.
- **Cool Slate 50** (#F9FAFB): Secondary surfaces, input fill backgrounds.
- **Cool Slate 200** (#E5E7EA): Borders, dividers, card strokes.
- **Cool Slate 300** (#D2D5DB): Stronger borders, disabled elements.
- **Cool Slate 400** (#9EA2AE): Tertiary text, placeholder text, muted icons.
- **Cool Slate 500** (#6D717F): Secondary body text.
- **Cool Slate 900** (#131927): Primary body text, headings.

### Semantic
- **Success** (#43B75D): Positive actions, status indicators.
- **Error** (#EE443F): Destructive actions, error states, notification badges.
- **Warning** (#FFAA00): Caution states, pending indicators.
- **Info** (#0095FF): Informational states, link alternatives.

### Dark Mode
- **Night Surface** (#0F1119): App background.
- **Night Surface Elevated** (#181B25): Card and surface backgrounds.
- **Night Surface High** (#1E2130): Elevated surfaces, modals.
- **Night Text** (#F0F1F5): Primary text, headings.
- **Night Text Muted** (#9EA2AE): Secondary text.
- **Night Border** (#2A2E3D): Subtle borders.

### Named Rules
**The One Accent Rule.** Studio Indigo is used on ≤15% of any given screen. Its rarity is the point — color carries meaning, not decoration.

## 3. Typography

**Display Font:** Inter (with system-ui, -apple-system, sans-serif fallback)
**Body Font:** Inter (same family)
**Label Font:** Inter (same family)

**Character:** A single sans-serif family across the entire hierarchy. Inter's tall x-height and open counters keep the interface legible at small mobile sizes. Weight shifts (700 for headings, 600 for labels, 400 for body) provide hierarchy without font switching. The single-family approach reinforces the "tool, not decoration" design principle.

### Hierarchy
- **Display** (700, 32px, 1.12): Screen-level headings, hero titles on onboarding and empty states.
- **Headline** (700, 24px, 1.2): Section headings, modal titles.
- **Title** (700, 20px, 1.25): Card titles, sheet headers.
- **Body** (400, 14px, 1.45): Primary reading text, form labels, descriptions. Max line length 65–75ch.
- **Small** (400, 12px, 1.4): Captions, timestamps, secondary metadata.
- **Label** (600, 14px, 1.3): Button text, tab labels. Also 12px (600) for chip labels, 11px (600) for small labels.
- **Display (Mobile)** (700, 28px, 1.15): Used on small screens where 32px is too large.

### Named Rules
**The Single Voice Rule.** One typeface, weight is the only hierarchy axis. Never mix a second font for "personality" — the personality is in the content, not the font stack.

## 4. Elevation

The system is flat by default. Depth is conveyed through tonal layering: surfaces at different levels of the grey ramp stack on top of each other, with 1px borders separating them. This avoids shadow pollution while maintaining clear visual hierarchy.

The bottom navigation bar is the only exception — it uses a top shadow (0 -4px 18px rgba(0,0,0,0.08)) to lift above scroll content.

### Shadow Vocabulary
- **Ambient Soft** (`0 4px 10px rgba(0,0,0,0.03)`): Optional light shadow for cards on warm-tinted surfaces where borders alone don't separate.
- **Ambient Medium** (`0 8px 16px rgba(0,0,0,0.05)`): Dropdown menus, modals, popups.
- **Brand Glow** (`0 8px 16px rgba(78,97,246,0.14)`): Interactive feedback on primary elements (hover states).
- **Bottom Nav Lift** (`0 -4px 18px rgba(0,0,0,0.08)`): The single structural shadow in the system, reserved for the bottom navigation bar.

### Named Rules
**The Flat-By-Default Rule.** Surfaces are flat at rest. Shadows appear only as a response to state (hover, elevation, focus) or as the single structural exception (bottom nav).

## 5. Components

### Buttons
- **Shape:** Gently curved corners (12px radius).
- **Primary:** Filled Studio Indigo (#4E61F6) background, white text (600 weight, 16px). Padding: 16px vertical, 24px horizontal. Minimum height: 54px. No shadow. On press: Indigo Deep (#3745AF). On disable: Cool Slate 300 (#D2D5DB).
- **Outlined:** White background, Cool Slate 200 border (1px), primary text color. Same shape and padding as primary. Interactive states follow the border shift.
- **Text:** Link-style without background. Studio Indigo text, padded at 12px horizontal. Used for secondary actions within cards.

### Cards / Containers
- **Corner Style:** Curved corners (16px radius).
- **Background:** White (#FFFFFF) in light mode, Night Surface Elevated (#181B25) in dark.
- **Shadow Strategy:** None at rest. Optional soft shadow (Ambient Soft) on cards that need lift.
- **Border:** 1px solid Cool Slate 200 (#E5E7EA) / Night Border (#2A2E3D) in dark.
- **Internal Padding:** 20px (spacing scale `lg`).

### Inputs / Fields
- **Style:** Filled background (Cool Slate 50 #F9FAFB), 1px Cool Slate 200 border, 12px radius. Minimum height derived from 16px vertical padding + typography.
- **Focus:** Background shifts to Indigo Soft (#EDEFFE), border shifts to Studio Indigo (1.2px). No glow, no shadow.
- **Hint Text:** Cool Slate 400 (#9EA2AE) at bodyMedium weight.
- **Error:** Border shifts to Error (#EE443F, 1.2px). Background remains filled.
- **Disabled:** Background shifts to Cool Slate 200 (#E5E7EA).

### Bottom Navigation
- **Style:** White background with a single top shadow (Bottom Nav Lift). Fixed at bottom, covers full width. Contains 4 nav destinations + center create button.
- **States:** Active item uses Studio Indigo icon + label; inactive uses Cool Slate 400 (#9EA2AE). Icons are 23px. Labels are 11px (600 weight).
- **Top Shadow:** Only structural shadow in the system.

### Chips / Tags
- **Style:** Filled background (Indigo Soft #EDEFFE or Cool Slate 100 #F3F4F6), 8px radius. Compact padding (8px horizontal, 4px vertical).
- **State:** Selected chips use Studio Indigo background with white text.

### Empty State
- **Style:** Centered layout with a tinted circular icon container (58px), heading, and supporting message. Icon container uses Indigo Soft gradient background with a Cool Slate 200 border.

## 6. Do's and Don'ts

### Do:
- **Do** use Studio Indigo on interactive elements only — buttons, links, active nav, selected states.
- **Do** keep surfaces flat at rest; reserve shadows for state changes.
- **Do** use the cool grey scale for all non-interactive surfaces and text.
- **Do** use weight as the primary hierarchy axis (700 → 600 → 400).
- **Do** test all text on the actual surface color: body text (#6D717F on #FFFFFF = 4.6:1, just above AA).
- **Do** use the same 12px radius for all interactive elements (buttons, inputs) and 16px for containers (cards, sheets).

### Don't:
- **Don't** use Studio Indigo as a decorative background wash or section color. The accent earns its place through interaction.
- **Don't** use gradient text, glassmorphism, or side-stripe borders anywhere.
- **Don't** pair a second typeface with Inter — one family carries the full hierarchy.
- **Don't** use repeated identical card grids with icon + heading + text as a layout default.
- **Don't** use uppercase tracked eyebrow labels ("ABOUT", "PROCESS") above every section.
- **Don't** use numbered section markers (01 / 02 / 03) as default scaffolding.
- **Don't** over-round corners: cards cap at 16px, buttons at 12px. Pill shapes (999px) only for tags and avatars.
- **Don't** add shadows to cards and buttons that already have a 1px border — choose one strategy per element.
- **Don't** make the app feel corporate or LinkedIn-clone sterile. Student-native means approachable, not professional-dark.
- **Don't** gamify with excessive badges, ribbons, or achievement patterns. The platform's value is in connecting people, not collecting points.
