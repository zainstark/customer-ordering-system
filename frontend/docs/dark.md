---
name: Vibrant Cravings Dark
colors:
  surface: '#1d100a'
  surface-dim: '#1d100a'
  surface-bright: '#46362e'
  surface-container-lowest: '#170b06'
  surface-container-low: '#261812'
  surface-container: '#2b1c16'
  surface-container-high: '#362720'
  surface-container-highest: '#41312a'
  on-surface: '#f8ddd2'
  on-surface-variant: '#e2bfb0'
  inverse-surface: '#f8ddd2'
  inverse-on-surface: '#3d2d26'
  outline: '#a98a7d'
  outline-variant: '#5a4136'
  surface-tint: '#ffb693'
  primary: '#ffb693'
  on-primary: '#561f00'
  primary-container: '#ff6b00'
  on-primary-container: '#572000'
  inverse-primary: '#a04100'
  secondary: '#c9c3e2'
  on-secondary: '#312d46'
  secondary-container: '#4a465f'
  on-secondary-container: '#bab5d3'
  tertiary: '#fabd00'
  on-tertiary: '#3f2e00'
  tertiary-container: '#c19100'
  on-tertiary-container: '#402e00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbcc'
  primary-fixed-dim: '#ffb693'
  on-primary-fixed: '#351000'
  on-primary-fixed-variant: '#7a3000'
  secondary-fixed: '#e5defe'
  secondary-fixed-dim: '#c9c3e2'
  on-secondary-fixed: '#1c192f'
  on-secondary-fixed-variant: '#47445d'
  tertiary-fixed: '#ffdf9e'
  tertiary-fixed-dim: '#fabd00'
  on-tertiary-fixed: '#261a00'
  on-tertiary-fixed-variant: '#5b4300'
  background: '#1d100a'
  on-background: '#f8ddd2'
  surface-variant: '#41312a'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
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
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-max: 1280px
  gutter: 24px
---

## Brand & Style
This design system translates a high-energy culinary aesthetic into a sophisticated, nocturnal environment. The brand personality is energetic, premium, and immersive, designed to make food imagery "pop" against a recessed, dark backdrop. 

The style is **Modern Minimalist with Glassmorphic accents**. It relies on deep charcoal surfaces to provide a canvas for the vibrant orange primary color. By utilizing subtle transparency and blur effects on elevated layers, the UI maintains a sense of depth and hierarchy without relying on traditional drop shadows. The emotional response is one of late-night indulgence, professional culinary precision, and modern convenience.

## Colors
The palette is anchored by the signature **Vibrant Orange (#FF6B00)**, which serves as the primary action color. To optimize for dark mode, the background uses a near-black charcoal to reduce eye strain while maintaining true black levels for OLED displays.

The secondary color, **Deep Indigo (#1D1A31)**, provides a moody, tonal depth to the system. Unlike a high-contrast accent, it is used for deep structural elements, subtle overlays, and sophisticated secondary containers that ground the high-energy orange. **Amber (#FFC107)** is reserved for warnings or loyalty-tier accents. Surfaces are tiered using increasing lightness (gray values) to indicate elevation. Text contrast ratios strictly adhere to WCAG AA standards, using pure white for titles and varying shades of light gray for secondary and tertiary information.

## Typography
The design system utilizes **Plus Jakarta Sans** for its friendly yet modern geometric construction. The typeface's open counters ensure high legibility on dark backgrounds where "glow" or "bleeding" can often occur with thinner fonts.

Display and Headline styles use extra-bold weights to create a strong visual anchor. Body text is set with generous line-height to ensure readability during long browsing sessions. Labels and small captions use a slightly increased letter-spacing and semi-bold weight to remain crisp at smaller scales.

## Layout & Spacing
The design system follows a strict **8px grid** for vertical rhythm and internal component spacing. The layout is a **fluid grid** that transitions to a max-width container on desktop screens to prevent overly long line lengths.

- **Mobile (0-599px):** 4-column grid, 16px margins, 16px gutters.
- **Tablet (600-1023px):** 8-column grid, 24px margins, 20px gutters.
- **Desktop (1024px+):** 12-column grid, auto margins, 24px gutters.

Horizontal padding should be generous to maintain the "Vibrant" feel, ensuring that imagery has enough room to breathe against the dark canvas.

## Elevation & Depth
Depth is communicated through **Tonal Layering** rather than heavy shadows. In this dark mode environment:
1. **Level 0 (Background):** #1d100a - The furthest back layer.
2. **Level 1 (Cards/Containers):** #261812 - Standard surface for content.
3. **Level 2 (Modals/Popovers):** #362720 - High elevation with a subtle 10% white inner stroke (border) to define edges against the background.

**Glassmorphism** is applied to navigation bars and floating action buttons. Use a `backdrop-filter: blur(20px)` with a semi-transparent fill of `#1d100a` at 80% opacity. This allows the vibrant colors of food photography to bleed through subtly as the user scrolls.

## Shapes
The design system uses a **Rounded** shape language to maintain its approachable and friendly character. 

- **Base Components:** 8px (0.5rem) radius for buttons and small input fields.
- **Large Components:** 16px (1rem) radius for cards, modals, and container sections.
- **Extra Large:** 24px (1.5rem) radius for promotional hero sections or large image containers.

Full pill shapes (rounded-full) are reserved specifically for interactive tags, chips, and the primary "Order" button to differentiate them from static containers.

## Components
### Buttons
Primary buttons use the Vibrant Orange background with dark text. Hover states should brighten the orange slightly. Secondary buttons use the Deep Indigo color as a subtle, low-contrast background or as a thick ghost-border to provide a more recessed alternative to the primary action.

### Input Fields
Fields use a low-elevation surface color with a 1px border. On focus, the border transitions to Vibrant Orange. Placeholder text uses muted high-contrast text.

### Cards
Cards for food items should use a low-elevation surface. Images should be top-aligned with no margin, bleeding to the edges of the card's top rounded corners. Text inside cards should follow the hierarchy of `title-md` for the dish name and `body-md` for description.

### Chips & Tags
Used for categories (e.g., "Vegan", "Spicy"). Chips should have a pill-shape and use a semi-transparent orange background (15% opacity) or a Deep Indigo background for premium/special filters, ensuring they provide a distinct but muted visual cue.

### Bottom Navigation (Mobile)
A glassmorphic bar with blurred background. Active icons use Vibrant Orange; inactive icons use muted neutral tones. A 1px border-top provides separation from the main content.