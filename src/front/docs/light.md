---
name: Vibrant Cravings
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#5a4136'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#8e7164'
  outline-variant: '#e2bfb0'
  surface-tint: '#a04100'
  primary: '#a04100'
  on-primary: '#ffffff'
  primary-container: '#ff6b00'
  on-primary-container: '#572000'
  inverse-primary: '#ffb693'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#95490d'
  on-tertiary: '#ffffff'
  tertiary-container: '#dd8243'
  on-tertiary-container: '#532400'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbcc'
  primary-fixed-dim: '#ffb693'
  on-primary-fixed: '#351000'
  on-primary-fixed-variant: '#7a3000'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#ffdbc8'
  tertiary-fixed-dim: '#ffb68a'
  on-tertiary-fixed: '#321300'
  on-tertiary-fixed-variant: '#743500'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

This design system is built to evoke an immediate appetite through a high-energy, modern-minimalist aesthetic. By pairing a high-octane primary orange with expansive white space, the UI feels both premium and accessible. The design language prioritizes clarity and speed, mirroring the fast-paced nature of food delivery while maintaining the elegance of a high-end restaurant menu.

The visual style leans heavily into **Modern Minimalism** with a focus on "high-fidelity realism." This means the UI stays out of the way, acting as a clean frame for large, saturated food photography. Interaction cues are soft and inviting, utilizing generous padding and "squircle" roundedness to create a friendly, ergonomic experience.

## Colors

The palette is anchored by a vibrant "Electric Orange" (#FF6B00) used strategically for primary actions and brand moments. 

- **Primary:** Used for CTAs, price points, and active states. 
- **Neutrals:** A range of subtle grays (from #F4F4F4 to #666666) handles background layering and secondary text hierarchy.
- **Accents:** High-quality food imagery provides the rest of the "color," so the UI remains predominantly white and light gray to prevent visual fatigue.
- **Success:** A clean emerald green is reserved exclusively for "Order Complete" or "Payment Successful" states.

## Typography

This design system utilizes **Plus Jakarta Sans** for its friendly yet precise geometric construction. It strikes a balance between the corporate rigor of Inter and the marketing punch of Montserrat.

- **Weight Strategy:** Use Bold (700) and ExtraBold (800) for dish names and prices to ensure they pop against imagery. 
- **Readability:** Body text uses a generous 1.5x line height to ensure ingredient lists and descriptions are highly legible during quick scrolling.
- **Micro-copy:** Labels for nutritional info or delivery times use Medium (500) weights with slightly increased letter spacing for clarity at small sizes.

## Layout & Spacing

The layout follows a 4px baseline grid to maintain strict vertical rhythm. 

- **Mobile:** A 4-column fluid grid with 20px outside margins. Most cards will span the full 4 columns or appear in a 2-column horizontal scroll for categories.
- **Whitespace:** Use "Generous Padding" (24px+) between major sections (e.g., "Recently Ordered" vs "Popular Near You") to give the user's eyes a place to rest.
- **Visual Grouping:** Use 8px (XS) for internal card padding and 16px (SM) for spacing between related list items.

## Elevation & Depth

This design system uses **Ambient Shadows** to create a sense of physical layering without cluttering the interface.

- **Level 1 (Cards):** Very soft, diffused shadows (Y: 4px, Blur: 20px, Opacity: 4%) to lift menu items off the background.
- **Level 2 (Active/Floating):** Higher elevation (Y: 10px, Blur: 30px, Opacity: 8%) for floating action buttons like the "View Cart" bar.
- **Tonal Depth:** Instead of borders, use slight color shifts (Background #FFFFFF to Surface #F9F9F9) to define different content areas like the cart summary or filter bars.

## Shapes

The shape language is defined by a **"Rounded"** philosophy (Radius: 0.5rem - 1.5rem).

- **Standard Elements:** Buttons and small chips use an 8px (0.5rem) radius.
- **Large Containers:** Menu cards and bottom sheets use a 24px (1.5rem) radius at the top or on all corners to emphasize a soft, modern feel.
- **Photography:** Food images should always mirror the container's roundedness to maintain a cohesive "packaged" look.

## Components

### Category Chips
Pill-shaped containers for food types (e.g., "Burgers", "Sushi").
- **Inactive:** Light gray background (#F4F4F4) with dark text.
- **Active:** Primary orange (#FF6B00) background with white text and a soft glow shadow.

### Menu Cards
- **Structure:** Full-width image at the top (aspect ratio 16:9), followed by dish name in `headline-md`, a short description in `body-md` (max 2 lines), and the price in `headline-md` using the primary orange.
- **Interaction:** A "+" icon in a circular orange button in the bottom-right corner for quick-add.

### Order Status Tracker
- **Visuals:** A horizontal step-indicator using thick lines. 
- **States:** Completed steps are Primary Orange; the current step pulses slightly; upcoming steps are soft gray. Use custom iconography for "Preparing," "On the Way," and "Delivered."

### Sleek Cart Summary
- **Style:** A persistent floating bottom bar or a clean bottom sheet.
- **Detail:** Use a "Glassmorphic" blur effect if positioned over content, or a solid white surface with a Level 2 shadow. Total price is always `headline-lg`.

### Input Fields
- **Style:** Ghost-style inputs with a subtle 1px border (#E0E0E0) that turns Primary Orange on focus. Use icons (search, location pin) in muted gray within the field.