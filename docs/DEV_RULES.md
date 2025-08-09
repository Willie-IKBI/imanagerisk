# Development Rules – Flutter + Riverpod + Supabase (IMR)

## Table of Contents
1. [Golden Rules](#0-golden-rules)
2. [Project Structure & Naming](#1-project-structure--naming)
3. [State Management (Riverpod)](#2-state-management-riverpod)
4. [Theming & Design Tokens](#3-theming--design-tokens)
5. [Reusable Widgets](#4-reusable-widgets)
6. [Responsiveness & Layout](#5-responsiveness--layout)
7. [Forms & Validation](#6-forms--validation)
8. [Routing & Access Control](#7-routing--access-control)
9. [Supabase Standards](#8-supabase-standards)
10. [Security & POPIA](#9-security--popia)
11. [Performance](#10-performance)
12. [Error Handling & UX States](#11-error-handling--ux-states)
13. [Code Quality & Tooling](#12-code-quality--tooling)
14. [Testing](#13-testing)
15. [Accessibility](#14-accessibility)
16. [Build & Release](#15-build--release)
17. [Design Review Checklist](#16-design-review-checklist)
18. [Performance Review Checklist](#17-performance-review-checklist)

---

## 0. Golden Rules

- **Single source of truth**: Business state lives in Riverpod providers; UI reads state via `ref.watch`
- **Theme-first UI**: No hard-coded colors/sizes anywhere. Use tokens from `theme/theme.dart`
- **Reuse before rebuild**: If a pattern appears twice, extract it into `shared/widgets/`
- **RLS everywhere**: No table without RLS; policies must be written before app code relies on the table
- **Docs & migrations in repo**: Every schema change is a migration; never modify prod directly

---

## 1. Project Structure & Naming

### Directory Structure
```
lib/
├── core/
│   ├── env/               // Env loading, secrets
│   └── services/          // Supabase, logging, storage, email
├── routing/               // GoRouter config & guards
├── theme/                 // theme.dart, tokens, component themes
├── shared/
│   ├── widgets/           // reusable UI (GlassCard, IMRButton, etc.)
│   └── utils/             // formatters, validators, mappers
└── features/
    ├── sales/             // ui/, controllers/, repo/, models/
    ├── admin/
    ├── claims/
    ├── commission/
    ├── dashboard/
    └── shell/             // AppScaffold, navigation
```

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `lowerCamelCase`
- **One widget per file** unless trivially small
- **Export barrels** in each feature for public API

---

## 2. State Management (Riverpod)

### Provider Types
- `*_repoProvider` – repositories (DB access)
- `*_controllerProvider` – feature controllers (UI orchestration)
- `*_streamProvider` – realtime streams (sparingly)

### Patterns
- **Fetch** → map to domain models → expose as `AsyncValue<T>`
- **Mutations** return `Result<T, Failure>` or throw controlled exceptions handled by controller
- **No direct Supabase calls** in UI. UI only talks to controllers

### Provider Guidelines
- Prefer `AsyncNotifier`/`AsyncValue` for I/O-bound state
- Use `StateNotifier` for complex local state
- Keep providers focused and single-purpose

---

## 3. Theming & Design Tokens

### Theme Entry Point
`theme/theme.dart` exports `imrTheme` + `IMRTokens` class

### Color Tokens (use everywhere)
```dart
IMRTokens.brandOrange = Color(0xFFF57C00)
IMRTokens.brandGrey = Color(0xFFA7A9AC)
IMRTokens.deepGrey = Color(0xFF4A4A4A)
IMRTokens.glassSurface = Colors.white.withOpacity(0.15)
IMRTokens.glassBorder = Colors.white.withOpacity(0.30)
```

### State Colors
- **Success**: #2E7D32
- **Warning**: #F9A825
- **Error**: #D32F2F
- **Info**: #0288D1

### Typography
- **Headers**: Poppins (600/700)
- **Body/UI**: Roboto (400/500)
- **Sizes**: H1 32/38, H2 24/30, H3 20/26, Body 16/24, Caption 13–14

### Radii/Spacing
- **Radius**: 20 (cards), 14 (inputs/buttons)
- **8-pt spacing scale**: 4, 8, 12, 16, 24, 32

### Glassmorphism Rules
- Cards/rails/app bar use `glassSurface` with 20–30px backdrop blur and `glassBorder`
- Ensure contrast: white/near-white text on glass
- Never place dense text on 10% opacity over busy background
- **Absolutely no hard-coded hex** in widgets. Use `Theme.of(context)` + `IMRTokens`

---

## 4. Reusable Widgets

### Must-Use Inventory (place in `shared/widgets/`)

#### Layout & Structure
- `GlassScaffold` – page scaffold with glass app bar/background gradient
- `GlassCard({title, subtitle, actions, child})` – default container for panels
- `SectionHeader({icon, title, actions})` – consistent section heads

#### Interactive Elements
- `IMRButton.primary/secondary/text` – themed buttons
- `IMRTextField` – wrapped TextFormField with glass styles + validation
- `IMRSelect<T>` – dropdown/searchable select with consistent menu surface
- `StatusBadge(status)` – semantic chips (lead/quote/claim/policy statuses)

#### Data Display
- `KPIStatTile({label, value, trend})` – dashboard tiles
- `DataTablePro` – sticky header, pagination controls, density toggle
- `EmptyState({title, message, cta})` / `ErrorState` / `LoadingState`

#### Dialogs & Forms
- `ConfirmDialog` / `PromptDialog`
- `DateRangePickerField` – consistent date picking
- `FileUploadButton({accept, onPick})` – standard upload control with size/type checks
- `StepperWizard` – for multi-step flows (sales conversion, renewals)
- `SearchBar` – universal search input with debounce & clear

**Rule**: If a view needs two or more of the above, you're building it wrong—compose these components.

---

## 5. Responsiveness & Layout

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600–1024px
- **Desktop**: > 1024px

### Grid System
- **Desktop**: 12-column grid
- **Mobile/Tablet**: 1–2 columns

### Navigation
- **Desktop**: side glass rail + top app bar
- **Mobile**: top app bar + optional bottom nav; drawers for filters

### Component Guidelines
- **Tables**: never full-width on mobile; switch to cards list with key fields
- **Charts**: minimum 320px width; use responsive containers; tooltips use glass surface

---

## 6. Forms & Validation

### Validation Layers
1. **Synchronous UI validation** (required, format, ranges)
2. **Server rules** (uniqueness, referential integrity) handled by repository; surface friendly errors

### Form Guidelines
- **Required fields**: mark with `*`; inline error text; disable submit until valid
- **Input masks**: for ID, phone, dates, currency; formatters in `shared/utils/formatters.dart`
- **Use reactive patterns** (e.g., form controllers in controller/provider)

---

## 7. Routing & Access Control

### GoRouter Configuration
- Routes organized by feature; deep-linkable; 404 and "no permission" pages
- Route guards that read `sessionProvider` + `roleProvider`

### Access Control
- UI must hide/disable actions the user cannot perform (defense in depth with RLS)
- Implement role-based route guards

---

## 8. Supabase Standards

### Migrations
- In `/supabase/.migrations` with clear IDs and comments
- Every schema change is a migration

### Table Standards
- Every table has: `id`, `created_at`, `created_by`, `updated_at`, `updated_by`
- **Tenancy/Access**: `owner_id`/`assigned_to` where appropriate

### RLS Templates
```sql
-- Select: allow role-specific reads; limit by ownership where needed
-- Insert/Update/Delete: allow only if auth.uid() has the right role & ownership
```

### Storage
- **Buckets**: `clients/`, `policies/`, `claims/`, `quotes/`, `compliance/`
- **Folder structure**: per entity (`clients/{clientId}/...`)
- **Signed URLs**: ≤ 10 min expiry
- **Content-type validation**

### Edge Functions
- `renewal-cron` (daily): create tasks at 90/60/30 days
- `commission-import` (post-upload): normalize & pre-match lines

### Indexes
Add for: `status`, `insurer_id`, `policy_no`, `client_name`, `owner_id`, `created_at`

---

## 9. Security & POPIA

### Least Privilege
- No "catch-all" admin tokens in client
- Least privilege at UI and DB levels

### Secrets Management
- `.env` via secure runtime; never commit keys

### PII Handling
- Mask on UI where not needed (e.g., show last 4)
- Redact in logs

### Audit & Compliance
- Write append-only logs for sensitive updates (policy premiums, client PII)
- File retention: tag doc types with retention; implement purge jobs later

### Sessions
- Email verification required
- Short JWT; idle timeout
- Lockout on repeated failures

---

## 10. Performance

### Query Optimization
- **Pagination** on every list (no unbounded queries)
- **Debounce search** (300–500 ms)
- **Memoize/cache** expensive queries with Riverpod `keepAlive` where useful; invalidate on mutations

### Data Loading
- **N+1**: avoid chatty screens; repositories should batch or select minimal columns
- **Image/doc uploads**: compress images; chunk uploads for large files

---

## 11. Error Handling & UX States

### AsyncValue Pattern
- All async UI uses `AsyncValue` pattern with `when(loading/error/data)`
- Show friendly messages and recovery actions (retry, go back)

### Error Management
- **Global error hook** (e.g., Sentry later) in `core/services/logging_service.dart`
- **Never expose raw SQL or stack traces** to users

---

## 12. Code Quality & Tooling

### Linting & Formatting
- **Linting**: `flutter_lints` + rules for import order, no print, prefer const, exhaustive switches
- **Formatting**: `dart format` pre-commit

### Version Control
- **Commits**: Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`)
- **PR checks**: analyze, test, build web; block merge on fail

### Documentation
- Each feature has a short `README.md` with routes, providers, and known caveats

---

## 13. Testing

### Test Types
- **Unit**: repositories with mocked Supabase
- **State**: Riverpod controllers using `ProviderContainer`
- **Widget**: golden tests for key screens (dashboard, lead list, policy detail)
- **RLS tests**: SQL test fixtures to validate policy coverage by role

---

## 14. Accessibility

### Standards
- **Color contrast AA**
- **Scalable text**
- **Focus rings visible**
- **Keyboard navigation** (tab order)

### Implementation
- Provide semantic labels for icons and buttons
- Test with screen readers

---

## 15. Build & Release

### Environments
- **Envs**: dev, staging, prod with separate Supabase projects or schemas

### CI/CD
- **GitHub Actions/Codemagic** build web; upload artifacts; run migrations gated by approval

### Feature Flags
- Simple remote config for risky features (in `core/services/config_service.dart`)

---

## 16. Design Review Checklist

**Enforce on every PR:**

- [ ] Uses `GlassCard` and theme tokens (no raw colors)
- [ ] Responsive at 360px, 768px, 1280px
- [ ] Uses `IMRButton` + `IMRTextField`; no duplicate components
- [ ] Keyboard + screen reader friendly
- [ ] Loading/empty/error states implemented
- [ ] Lists paginated; search debounced; filters persist in URL query (web)

---

## 17. Performance Review Checklist

**Enforce on every PR:**

- [ ] Queries indexed; selects only needed columns
- [ ] No unbounded streams; dispose listeners
- [ ] Heavy lists virtualized where possible
- [ ] Images compressed; PDFs generated server-side when heavy (future)