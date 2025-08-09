# IMR Theme Definition (v1.1)

This document defines the **single source of truth** for the IMR design system used across web and mobile form factors. All screens **must** consume tokens and component styles from this spec—no hard‑coded hex values or ad‑hoc spacing.

---

## 1) Brand & Color Tokens

### 1.1 Core Brand
- **Brand Orange**: `#F57C00` (Primary / CTAs / focus rings / highlights)
- **Brand Grey**: `#A7A9AC` (Secondary accents, icons, borders, muted chips)
- **Deep Grey**: `#4A4A4A` (Primary on-dark text, app backdrop)
- **Pure White**: `#FFFFFF` (Text on primary, cards, content surfaces)

### 1.2 Glass Surfaces
- **Glass Surface**: `rgba(255, 255, 255, 0.15)`
- **Glass Border**: `rgba(255, 255, 255, 0.30)`
- **Glass Hover**: `rgba(255, 255, 255, 0.22)`
- **Shadow Grey**: `rgba(0, 0, 0, 0.25)`

> **Rule:** All glass components must sit over a *low-contrast* dark gradient to preserve readability.

### 1.3 Semantic Status
- **Success**: `#2E7D32`
- **Warning**: `#F9A825`
- **Error**: `#D32F2F`
- **Info**: `#0288D1`

### 1.4 Data Visualization Palette
Primary series use **Brand Orange**. Secondary/comparison series use neutral greys.
- Series 1: `#F57C00`
- Series 2: `#8D8F93`
- Series 3: `#C9CACC`
- Series 4: `#4A4A4A`

---

## 2) Typography

### 2.1 Font Families
- **Headers**: `Poppins` (600/700)
- **Body & UI**: `Roboto` (400/500)

### 2.2 Type Scale (Desktop / Mobile)
- **H1**: 32/38 (D) · 26/32 (M)
- **H2**: 24/30 (D) · 22/28 (M)
- **H3**: 20/26 (D) · 18/24 (M)
- **Subtitle**: 18/24 (D) · 16/22 (M)
- **Body**: 16/24
- **Caption/Meta**: 13–14/18

> Use **Poppins** for headings only. All body, table, and form text is **Roboto** for legibility.

### 2.3 Usage
- Page title (H1), Section (H2), Card/Modal titles (H3), Captions for helper/error text.
- Avoid center-aligned long text; left align for readability.

---

## 3) Layout, Spacing & Elevation

### 3.1 Spacing (8-pt scale)
`4, 8, 12, 16, 24, 32, 48` — default paddings:
- **Card padding**: 16 (mobile), 24 (desktop)
- **Section spacing**: 24–32
- **Form field vertical gap**: 12–16

### 3.2 Radii
- **Cards**: 20
- **Inputs & Buttons**: 14
- **Chips/Badges**: 999 (pill)

### 3.3 Elevation / Shadows
- **Card**: `0 8px 30px rgba(0,0,0,0.25)`
- **Hover**: add glow `0 0 0 1px rgba(245,124,0,0.25)` + slight scale (1.02)

---

## 4) Glassmorphism

### 4.1 Base Recipe
- **Surface**: translucent white at 10–15% (`Glass Surface`)
- **Border**: `Glass Border` (1px)
- **Blur**: 20–30px backdrop-filter
- **Shadow**: `Shadow Grey`
- **Contrast**: body text min AA contrast; elevate opacity to 0.22 for dense content.

### 4.2 Backgrounds
- **Backdrop Gradient**: `#2F2F2F` → `#4A4A4A`
- Subtle, oversized blurred blobs of Brand Orange at 8–12% opacity to add depth.

---

## 5) Components

### 5.1 App Bars & Navigation
- **Top App Bar**: glass surface, 20px radius, left-aligned logo, right user menu.
- **Side Navigation (desktop)**: glass rail, icon + label, active item has orange left strip and subtle background.
- **Tabs**: underline indicator in Brand Orange; hover uses `Glass Hover`.

### 5.2 Cards
- **GlassCard** (default panel):
  - Padding 16/24, radius 20, glass recipe, header slot (title/subtitle/actions).
  - Optional subtle diagonal gradient overlay from Brand Orange → transparent 4% opacity.

### 5.3 Buttons
- **Primary**: Brand Orange bg, white text; hover = 1.02 scale + glow.
- **Secondary**: Outline (Brand Orange stroke); hover adds 8% orange fill.
- **Tertiary**: Text button (white/near-white), underline on hover.

### 5.4 Inputs
- Filled glass style (opacity 0.12–0.15), radius 14.
- **Focus**: 2px Brand Orange focus ring + subtle outer glow.
- Clear inline error text (Caption), success state optional (Success green border).

### 5.5 Tables
- Sticky header with glass surface and slightly higher opacity (0.22).
- Row hover uses `Glass Hover`.
- Zebra rows: additional 4–6% white overlay.
- Compact density toggle; responsive collapse to cards on mobile.

### 5.6 Chips/Badges
- Rounded pills. Status colors map to **Semantic Status**.
  - Example: `lead:new` = Info, `lead:won` = Success, `claim:breach` = Error.

### 5.7 Steppers/Wizards
- Use horizontal on desktop, vertical on mobile.
- Active step circle filled with Brand Orange, completed steps use Brand Grey.

### 5.8 Charts
- Series 1 = Brand Orange; comparisons neutral greys.
- Tooltips and legends adopt glass surfaces with 16px radius.

---

## 6) Responsiveness

### Breakpoints
- **Mobile**: < 600
- **Tablet**: 600–1024
- **Desktop**: > 1024

### Layout Rules
- Mobile: single column, drawers for filters, bottom sheets for actions.
- Tablet: 2-column where possible; side nav collapsible.
- Desktop: 12-column grid; persistent activity drawer on wide screens.

> Tables must switch to card lists below 600px. Keep critical fields visible in first 3 rows.

---

## 7) Motion

- **Durations**: 120–200ms for UI feedback; 250–300ms for modal/route transitions.
- **Easing**: standard Material ease-in-out; spring for subtle button presses.
- **Reduce Motion**: honor OS “reduce motion” and disable scale/glow transitions.

---

## 8) Accessibility

- **Contrast**: AA minimum on text; avoid light text over 10% glass unless on dark backdrop.
- **Focus**: visible focus states (Brand Orange ring).
- **Keyboard**: tab order logical; focus trap in dialogs.
- **Labels**: semantic labels for icons; error messages tied to fields with `aria-describedby` equivalents.

---

## 9) PDF Theme (for generated documents)

- **Header**: IMR logo left, company details right, thin orange rule underneath.
- **Type**: Poppins (titles), Roboto (body).
- **Tables**: grey headers, alternating row fill 3%; totals row highlighted with Brand Orange rule.
- **Footer**: page number, contact, confidentiality note.

---

## 10) Token Map for Flutter (Theme Extension)

Expose these in `theme/theme.dart` via a `ThemeExtension<IMRTokens>`:

```dart
class IMRTokens extends ThemeExtension<IMRTokens> {
  final Color brandOrange;
  final Color brandGrey;
  final Color deepGrey;
  final Color glassSurface;
  final Color glassBorder;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const IMRTokens({
    required this.brandOrange,
    required this.brandGrey,
    required this.deepGrey,
    required this.glassSurface,
    required this.glassBorder,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  @override
  IMRTokens copyWith({...}) => throw UnimplementedError();

  @override
  IMRTokens lerp(IMRTokens? other, double t) => this;
}
```

**Usage Example**
```dart
final tokens = Theme.of(context).extension<IMRTokens>()!;
Container(
  decoration: BoxDecoration(
    color: tokens.glassSurface,
    border: Border.all(color: tokens.glassBorder),
    borderRadius: BorderRadius.circular(20),
  ),
  child: ...
);
```

---

## 11) Do/Don’t Checklist

- ✅ Use theme tokens for all colors, radii, spacing, elevations.
- ✅ Use GlassCard, IMRButton, IMRTextField shared widgets.
- ✅ Test at 360, 768, 1280 widths; ensure tables degrade to cards.
- ❌ No hard-coded hex or magic numbers in widgets.
- ❌ No dense text blocks on 10% glass without dark backdrop.
- ❌ No mixed fonts; headers = Poppins only, body = Roboto only.

---

## 12) Future (Dark Mode – Optional Later)
- Keep contrast by inverting: darker backdrop, **increase glass opacity to 0.22–0.28**, maintain Brand Orange as accent.

---

**Versioning**: Update this file when tokens or component specs change. Reflect changes in `theme/theme.dart` and shared widgets in the same PR.
