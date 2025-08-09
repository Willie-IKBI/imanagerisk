# IMR Design System & Layout Rules

## Table of Contents
1. [Design Philosophy](#1-design-philosophy)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Glassmorphism](#4-glassmorphism)
5. [Layout & Grid System](#5-layout--grid-system)
6. [Component Library](#6-component-library)
7. [Navigation](#7-navigation)
8. [Forms & Inputs](#8-forms--inputs)
9. [Data Display](#9-data-display)
10. [Interactive Elements](#10-interactive-elements)
11. [Responsive Design](#11-responsive-design)
12. [Accessibility](#12-accessibility)
13. [Animation & Motion](#13-animation--motion)
14. [Implementation Guidelines](#14-implementation-guidelines)
15. [Design Review Checklist](#15-design-review-checklist)

---

## 1. Design Philosophy

### Design Language
- **Modern Material 3** with **Glassmorphism** for primary surfaces
- **Professional, clean, and minimal** with bold accents in Brand Orange
- **Corporate and trustworthy** — avoiding clutter, focusing on readability and clear workflows

### Core Principles
- **Consistency**: Use design tokens and components consistently across all screens
- **Accessibility**: AA contrast compliance, keyboard navigation, screen reader support
- **Performance**: Optimize for smooth interactions and fast loading
- **Scalability**: Design system that grows with the application

---

## 2. Color System

### Brand Colors
```dart
// Primary Brand Colors
IMRTokens.brandOrange = Color(0xFFF57C00)  // Primary / CTAs / focus rings
IMRTokens.brandGrey = Color(0xFFA7A9AC)    // Secondary accents, icons, borders
IMRTokens.deepGrey = Color(0xFF4A4A4A)     // Primary text on dark backgrounds
IMRTokens.pureWhite = Color(0xFFFFFFFF)    // Text on primary, cards, content surfaces
```

### Glass Surfaces
```dart
// Glassmorphism Surfaces
IMRTokens.glassSurface = Colors.white.withOpacity(0.15)    // Primary glass surface
IMRTokens.glassBorder = Colors.white.withOpacity(0.30)     // Glass borders
IMRTokens.glassHover = Colors.white.withOpacity(0.22)      // Hover states
IMRTokens.shadowGrey = Color.fromRGBO(0, 0, 0, 0.25)      // Shadows
```

### Semantic Colors
```dart
// Status Colors
IMRTokens.success = Color(0xFF2E7D32)      // Success states
IMRTokens.warning = Color(0xFFF9A825)      // Warning states
IMRTokens.error = Color(0xFFD32F2F)        // Error states
IMRTokens.info = Color(0xFF0288D1)         // Info states
```

### Background Gradients
```dart
// Background System
IMRTokens.backgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF2F2F2F),  // Deep Grey
    Color(0xFF4A4A4A),  // Lighter Grey
  ],
)
```

---

## 3. Typography

### Font Families
- **Headers**: Poppins (600/700 weight)
- **Body/UI**: Roboto (400/500 weight)

### Type Scale
```dart
// Typography Tokens
IMRTokens.h1 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 32,        // 26px mobile
  fontWeight: FontWeight.w600,
  height: 1.2,
)

IMRTokens.h2 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 24,        // 22px mobile
  fontWeight: FontWeight.w600,
  height: 1.25,
)

IMRTokens.h3 = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,        // 18px mobile
  fontWeight: FontWeight.w600,
  height: 1.3,
)

IMRTokens.body = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
)

IMRTokens.caption = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.3,
)
```

### Typography Rules
- **Headings never use all caps**
- **Maintain at least 1.2em line height** for readability
- **Don't mix font families** outside defined headers/body
- **Use semantic sizing** (H1 for page titles, H2 for sections, etc.)

---

## 4. Glassmorphism

### Glass Surface Properties
```dart
// Glassmorphism Configuration
IMRTokens.glassmorphism = GlassmorphismConfig(
  surfaceOpacity: 0.15,
  borderOpacity: 0.30,
  blurRadius: 20.0,
  shadowColor: Color.fromRGBO(0, 0, 0, 0.25),
  shadowOffset: Offset(0, 8),
  shadowBlurRadius: 30,
)
```

### Glassmorphism Rules
- **Surface**: `rgba(255, 255, 255, 0.15)` with 20–30px backdrop blur
- **Border**: 1px solid `rgba(255, 255, 255, 0.30)`
- **Shadow**: `rgba(0, 0, 0, 0.25)` for lift
- **Contrast**: Ensure foreground text meets AA contrast
- **Usage**: Glass for navigation rails, app bars, cards, panels, filters, dashboards

---

## 5. Layout & Grid System

### Breakpoints
```dart
// Responsive Breakpoints
IMRTokens.breakpoints = Breakpoints(
  mobile: 600,
  tablet: 1024,
  desktop: 1024,
)
```

### Grid System
- **Desktop**: 12-column grid, 16–24px gutters
- **Tablet**: 6–8 column grid, 16px gutters
- **Mobile**: Single column, full-width cards with 16px padding

### Spacing Scale
```dart
// 8-pt Spacing System
IMRTokens.spacing = SpacingTokens(
  xs: 4,    // 4px
  sm: 8,    // 8px
  md: 12,   // 12px
  lg: 16,   // 16px
  xl: 24,   // 24px
  xxl: 32,  // 32px
)
```

---

## 6. Component Library

### Layout Components

#### GlassScaffold
```dart
GlassScaffold({
  required Widget child,
  PreferredSizeWidget? appBar,
  Widget? drawer,
  Widget? bottomNavigationBar,
  bool extendBody = false,
})
```
- Page scaffold with glass app bar/background gradient
- Handles responsive navigation automatically

#### GlassCard
```dart
GlassCard({
  String? title,
  String? subtitle,
  List<Widget>? actions,
  required Widget child,
  EdgeInsetsGeometry? padding,
  double? radius,
})
```
- Default container for panels and content sections
- Glass surface with consistent styling

#### SectionHeader
```dart
SectionHeader({
  IconData? icon,
  required String title,
  List<Widget>? actions,
  bool showDivider = true,
})
```
- Consistent section headers across the application

### Interactive Components

#### IMRButton
```dart
IMRButton.primary({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
  IconData? icon,
})

IMRButton.secondary({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
  IconData? icon,
})

IMRButton.text({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
})
```

#### IMRTextField
```dart
IMRTextField({
  String? label,
  String? hint,
  TextEditingController? controller,
  String? Function(String?)? validator,
  bool obscureText = false,
  TextInputType? keyboardType,
  Widget? prefix,
  Widget? suffix,
})
```
- Wrapped TextFormField with glass styles + validation

#### IMRSelect
```dart
IMRSelect<T>({
  String? label,
  String? hint,
  required List<T> options,
  required String Function(T) itemBuilder,
  T? value,
  ValueChanged<T?>? onChanged,
  String? Function(T?)? validator,
})
```
- Dropdown/searchable select with consistent menu surface

### Data Display Components

#### StatusBadge
```dart
StatusBadge({
  required String status,
  StatusType type = StatusType.neutral,
})
```
- Semantic chips for lead/quote/claim/policy statuses

#### KPIStatTile
```dart
KPIStatTile({
  required String label,
  required String value,
  String? trend,
  IconData? icon,
  VoidCallback? onTap,
})
```
- Dashboard tiles with consistent styling

#### DataTablePro
```dart
DataTablePro({
  required List<DataColumn> columns,
  required List<DataRow> rows,
  bool stickyHeader = true,
  bool showPagination = true,
  int rowsPerPage = 10,
})
```
- Enhanced data table with sticky header, pagination, density toggle

---

## 7. Navigation

### Desktop Navigation
- **Side Nav**: Vertical glass panel (64–72px wide collapsed / 200–240px expanded)
- **Active link**: Orange accent bar, subtle glass background highlight
- **Fixed position**: Scrollable if menu exceeds viewport height

### Mobile Navigation
- **Top App Bar**: Glass surface, logo left, menu/actions right
- **Hamburger menu**: Opens slide-in glass side panel
- **Bottom navigation**: Optional for key modules (Sales, Admin, Claims, Dashboard)

### Navigation Components
```dart
// Side Navigation
IMRSideNav({
  required List<NavigationItem> items,
  required String currentRoute,
  required ValueChanged<String> onItemSelected,
  bool isCollapsed = false,
})

// Top App Bar
IMRAppBar({
  String? title,
  List<Widget>? actions,
  Widget? leading,
  bool automaticallyImplyLeading = true,
})
```

---

## 8. Forms & Inputs

### Form Layout
- **Field spacing**: 12–16px vertical
- **Group related fields**: With section headers inside cards
- **Multi-step wizards**: Use glass stepper component

### Form Components
```dart
// Form Field Group
IMRFormFieldGroup({
  required String title,
  required List<Widget> children,
  bool showDivider = true,
})

// Stepper Wizard
IMRStepperWizard({
  required List<StepperStep> steps,
  required int currentStep,
  required ValueChanged<int> onStepChanged,
})
```

### Validation
- **Required fields**: Mark with `*`; inline error text
- **Disable submit**: Until form is valid
- **Input masks**: For ID, phone, dates, currency

---

## 9. Data Display

### Tables
- **Desktop**: Sticky glass header row (0.22 opacity)
- **Row hover**: Subtle glass highlight
- **Zebra stripes**: Extra 4–6% white overlay
- **Mobile**: Switch to card list view

### Lists
- **Card lists**: For mobile table alternatives
- **Infinite scroll**: With pagination
- **Search and filter**: Integrated into list headers

### Charts
- **Clean axes**: Minimal grid
- **Series color**: Brand orange
- **Comparatives**: Brand grey
- **Tooltips**: Glass surface

---

## 10. Interactive Elements

### Buttons
```dart
// Button Specifications
IMRButtonSpecs(
  primary: ButtonSpec(
    backgroundColor: IMRTokens.brandOrange,
    textColor: IMRTokens.pureWhite,
    hoverScale: 1.02,
    glowColor: IMRTokens.brandOrange.withOpacity(0.2),
  ),
  secondary: ButtonSpec(
    backgroundColor: Colors.transparent,
    borderColor: IMRTokens.brandOrange,
    textColor: IMRTokens.brandOrange,
    hoverBackgroundColor: IMRTokens.brandOrange.withOpacity(0.08),
  ),
)
```

### Dialogs & Drawers
- **Glass surfaces**: With consistent radius (20px)
- **Desktop**: Side drawers for filters, settings
- **Mobile**: Bottom sheets for quick actions

---

## 11. Responsive Design

### Breakpoint Strategy
- **Mobile**: < 600px
- **Tablet**: 600–1024px
- **Desktop**: > 1024px

### Responsive Patterns
- **Navigation collapses**: On mobile
- **Tables switch to lists**: On mobile
- **Multi-column forms**: Become stacked
- **Charts adapt**: Minimum 320px width

### Component Adjustments
```dart
// Responsive Helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1024;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
}
```

---

## 12. Accessibility

### Standards
- **Color contrast AA**: Maintain throughout the application
- **Scalable text**: Support for larger text sizes
- **Focus rings visible**: Brand orange focus indicators
- **Keyboard navigation**: Logical tab order

### Implementation
- **Semantic labels**: For all interactive elements
- **Screen reader support**: Proper ARIA labels
- **Alternative text**: For images and icons

### Accessibility Components
```dart
// Accessible Button
IMRAccessibleButton({
  required String label,
  required VoidCallback onPressed,
  String? semanticLabel,
  bool isExpanded = false,
})

// Accessible Text Field
IMRAccessibleTextField({
  required String label,
  String? hint,
  String? semanticLabel,
  TextEditingController? controller,
})
```

---

## 13. Animation & Motion

### Animation Principles
- **Purposeful motion**: Enhance user experience
- **Consistent timing**: 200-300ms for most interactions
- **Easing curves**: Material Design standard curves

### Animation Tokens
```dart
// Animation Configuration
IMRTokens.animations = AnimationTokens(
  short: Duration(milliseconds: 200),
  medium: Duration(milliseconds: 300),
  long: Duration(milliseconds: 500),
  curve: Curves.easeInOut,
)
```

### Common Animations
- **Button hover**: Scale 1.02 + glow
- **Card hover**: Subtle lift + shadow
- **Page transitions**: Slide transitions
- **Loading states**: Skeleton screens

---

## 14. Implementation Guidelines

### Theme Integration
```dart
// Theme Configuration
class IMRTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: IMRColorScheme.light,
    textTheme: IMRTextTheme.light,
    // ... other theme properties
  );
  
  static ThemeData get darkTheme => ThemeData(
    colorScheme: IMRColorScheme.dark,
    textTheme: IMRTextTheme.dark,
    // ... other theme properties
  );
}
```

### Component Usage
- **Use design tokens**: Never hardcode colors or sizes
- **Compose components**: Build complex UIs from simple components
- **Follow patterns**: Use established patterns for similar functionality

### Code Organization
```dart
// Component Structure
lib/
├── shared/
│   └── widgets/
│       ├── glass_card.dart
│       ├── imr_button.dart
│       ├── imr_text_field.dart
│       └── index.dart
└── theme/
    ├── tokens.dart
    ├── colors.dart
    ├── typography.dart
    └── theme.dart
```

---

## 15. Design Review Checklist

### Visual Design
- [ ] Uses `GlassCard` and theme tokens (no raw colors)
- [ ] Consistent spacing using 8-pt scale
- [ ] Typography follows defined hierarchy
- [ ] Glassmorphism applied correctly
- [ ] Brand colors used appropriately

### Responsive Design
- [ ] Responsive at 360px, 768px, 1280px widths
- [ ] Mobile-first approach implemented
- [ ] Navigation adapts to screen size
- [ ] Tables switch to lists on mobile

### Component Usage
- [ ] Uses `IMRButton` + `IMRTextField`; no duplicate components
- [ ] Consistent component patterns
- [ ] Proper semantic structure
- [ ] Accessibility features implemented

### User Experience
- [ ] Loading/empty/error states implemented
- [ ] Clear navigation paths
- [ ] Intuitive interactions
- [ ] Performance optimized

### Accessibility
- [ ] Keyboard + screen reader friendly
- [ ] Color contrast meets AA standards
- [ ] Focus indicators visible
- [ ] Semantic labels provided

### Technical Implementation
- [ ] Follows Flutter best practices
- [ ] Uses Riverpod for state management
- [ ] Implements proper error handling
- [ ] Code is well-documented

