# IMR – Functional Requirements (Detailed)

## Table of Contents
1. [Global Concepts](#0-global-concepts)
2. [Sales (CRM & Funnel)](#1-sales-crm--funnel)
3. [Administration (Clients, Policies, Renewals)](#2-administration-clients-policies-renewals)
4. [Claims](#3-claims)
5. [Commission](#4-commission)
6. [Dashboards & Reporting](#5-dashboards--reporting)
7. [Communications & Templates](#6-communications--templates)
8. [Settings & Master Data](#7-settings--master-data)
9. [Roles & Access (RBAC + RLS)](#8-roles--access-rbac--rls)
10. [Security, POPIA & Compliance](#9-security-popia--compliance)
11. [Non-Functional Requirements](#10-non-functional-requirements)
12. [Theme & Design System](#theme--design-system)
13. [Acceptance Criteria](#acceptance-criteria-per-module)
14. [Build Notes](#build-notes-flutterriverpodsupabase)

---

## 0. Global Concepts

### Entities
- clients, contacts, policies, quotes, claims, commission_statements, commission_lines, documents, interactions, tasks, renewal_reviews, users, roles, insurers, products, policy_types

### Global UX
- **Universal search**: client name, policy #, claim #, quote #, insurer
- **List views**: server-side pagination, filters, saved views, CSV export (role-gated)
- **Inline quick actions**: view, edit, assign, add interaction, upload doc
- **Activity bar/right drawer**: recent interactions, tasks, docs for the open record

### Documents & Files
- **Supabase Storage buckets** per domain: `clients/`, `policies/`, `claims/`, `quotes/`, `compliance/`
- **Standard naming**: `entityType_entityId_docType_yyyymmdd_vX.ext`
- **Signed URLs**: short-lived, metadata (uploader, time, related entity, retention tag)

### Auditability
- **Immutable event log** per record: who, when, what_changed, before/after (for sensitive fields)
- View logs by role

### Tasks/Reminders
- Any record can have tasks with assignee, due date, priority, status, and reminders
- **Recurrence**: weekly, monthly for recurring admin chores (e.g., bordereaux import)

---

## 1. Sales (CRM & Funnel)

### 1.1 Leads

**Fields:**
- `lead_id` (seq), owner (sales broker), source, client_type (Personal/Business/Body Corporate)
- prospect name, company reg/ID (optional at lead), contact methods, region/province
- product interest, created_at

**Status Pipeline** (configurable):
```
New → Contacted → Qualifying → Quoting → Awaiting Client Docs → Decision → Won/Lost
```

**Validation:**
- No duplicate by email+phone
- Show merge tool if suspected dupes

**Interactions Timeline:**
- note, call, meeting, email
- next action + due date

#### Broker Authorization (Consent)
- Record consent method (signed PDF, email consent, call note), timestamp, user
- Generate Broker Authorization PDF from template
- Send via email, store in Storage

### 1.2 Quotes (Multi-Insurer)

**Structure:**
- Per lead: 1..N quotes
- Each quote can have 1..N insurer options

**Option fields:**
- insurer_id, product, cover summary, premium, excess, key exclusions
- attachments (insurer proposal), validity date

**Compare Matrix:**
- Table comparing options (premium, excess, cover highlights)

**Decision:**
- Client selects option → mark quote Accepted, others Declined with reason
- Convert to Client: wizard to create client + prefill from lead
- Keep linkage for reporting

**Handover:**
- Accepted quote triggers Admin task to onboard & capture policy
- Auto-create renewal schedule skeleton

**KPIs:**
- lead aging, conversion %, time-to-first-contact, quote win rate by broker/insurer/product

---

## 2. Administration (Clients, Policies, Renewals)

### 2.1 Client Onboarding

**Client Types:**
- Personal, Business, Body Corporate (drives required fields)

**Fields:**

*Personal:*
- full name, SA ID/passport, DOB, address, email, phones

*Business:*
- legal name, trading name, reg no, VAT no, directors, addresses, contact person

*Body Corporate:*
- scheme name, CSOS no (if any), trustees list, managing agent

**KYC/Compliance Docs:**
- ID/Reg docs, proof of address, FATCA/PEP (if applicable), Broker Appointment Letter

**Completeness Meter:**
- % based on required fields + documents present

### 2.2 Policy Capture

**Policy fields:**
- policy_no, insurer_id, product, policy_type, start_date, end_date
- billing_freq, premium (gross/net), broker fee (if any), commission %
- status (active/pending/cancelled/suspended), notes

**Cover Items** (1..N):
- item type (vehicle/building/contents/BI/etc.), sums insured, excess, endorsements
- risk address, drivers (for motor), serials (for assets)

**Documents:**
- policy schedule, endorsements, SoA, KYC

**Change Log:**
- endorsements with effective date and who changed what

### 2.3 Renewals & Reviews

**Auto Schedule:**
- create renewal record at policy capture (e.g., 60/90 days before end)

**Renewal Review:**
- check premium change, claims history, upsell/cross-sell prompts
- client confirmation log

**Workflow:**
```
Pending → In Progress → Client Notified → Awaiting Response → Finalized
```

**Reminders:**
- auto tasks for each stage
- overdue escalation to Manager

**Outcome:**
- renew as is / adjust cover / move insurer / cancel
- record reasons

**KPIs:**
- retention rate, premium drift, % renewals completed on time, data completeness

---

## 3. Claims

### 3.1 Intake

**Fields:**
- claim_no (seq), policy_id, claim_type, incident_date/time, incident description
- location, third-party details, police case # (if required), photo/docs, notifier name

**Validation:**
- policy must be active at incident date
- highlight coverage exclusions

### 3.2 Workflow

**Stages:**
```
Lodged → Insurer Registered → Assessing → Additional Info → Approved/Declined → Settled → Closed
```
- Allow Reopen with reason

**SLA timers:**
- time in stage, breach flags, manager visibility

**Financials:**
- reserve amount, paid amount, excess paid by client, recoveries
- attachments (assessor report, invoices)

**Communications:**
- email/phone logs, templated status updates
- consent for sharing info with third parties if needed

**KPIs:**
- frequency, severity (avg cost), cycle time, open claims, SLA breaches

---

## 4. Commission

### 4.1 Ingestion

**Commission Statements:**
- upload CSV/XLSX (bordereaux) with insurer mapping profile per insurer

**Mapping Rules:**
- column mapping, normalization (policy no formatting), duplicates handling

### 4.2 Allocation & Reconciliation

**Match lines to policies:**
- show unmatched to queue for manual link

**Calculations:**
- commission %, broker split %, clawbacks (reversals), adjustments (manual notes)

**Period close & lock:**
- e.g., month-end

### 4.3 Reporting

**Summary by:**
- period, insurer, broker, product

**Exception views:**
- negative commission, missing policies, variance from expected commission

**KPIs:**
- total commission, growth vs prior periods, top brokers, clawback rate

---

## 5. Dashboards & Reporting

### Home Dashboard
**Tiles for:**
- New Leads, Quotes Awaiting Decision, Renewals Due (30/60/90)
- Open Claims by Stage, Commission This Month, task list

**Drill-downs:**
- each KPI links to filtered list view

**Charts:**
- area/line for trends, bar for distribution, donut for composition
- Export PNG/PDF

**Saved Reports:**
- per user role, schedule email export (later)

---

## 6. Communications & Templates

### PDF Templates
- Broker Authorization, Broker Appointment Letter, Quotation (with comparison table)
- Renewal Review, Claim Status Letter, Statement of Advice (later)

### Template Variables
- `{{client_name}}`, `{{policy_no}}`, `{{premium}}`, `{{insurer}}`, `{{date}}`

### Delivery
- email (SMTP/provider) + saved to Storage
- WhatsApp (future)

### Consent & Unsubscribe
- internal comms only
- store explicit consents where needed

---

## 7. Settings & Master Data

**Master Data:**
- Insurers (name, contact, API keys if any), Products, Policy Types, Claim Types
- Reasons (loss, cancellation, decline), Lead Sources, Task Types
- Numbering (prefixes for leads/quotes/claims)

**Teams & Roles:**
- assign users to roles
- per-feature toggles (view/edit/export)

**Branding:**
- IMR logo, PDF headers/footers, email signatures

---

## 8. Roles & Access (RBAC + RLS)

### Role Hierarchy
- **Super Admin**: full CRUD + settings
- **Manager**: full across modules except system settings
- **Sales Broker**: own leads/quotes/clients pre-handover; read-only policy post-handover; no commission
- **Admin/Renewals**: clients/policies/renewals full; read sales; no commission edit
- **Claims Handler**: claims full; read client/policy; no sales/commission
- **Finance**: commission full; read client/policy; no claims/sales edit

### RLS Principles (Supabase)
- Each table has `created_by`, `assigned_to`, and `team_role` relations

**Policy examples:**
- Sales broker: leads, quotes where `owner_id = auth.uid()` OR team rule
- Admin: clients, policies, renewals unrestricted within tenant
- Claims handler: claims only; join read on clients/policies
- Finance: commission_* only; join read on policies

**File security:**
- All file paths include entity IDs
- Signed URL checks + row policy on documents

---

## 9. Security, POPIA & Compliance

### PII Minimization
- collect only necessary data
- segregate highly sensitive docs in `compliance/` bucket with stricter policies

### Encryption
- Postgres at rest, Storage encryption, HTTPS everywhere

### Access Logs
- who viewed PII docs
- immutable append-only for sensitive access

### Retention
- configurable per doc type (e.g., 5–7 years)
- purge workflow and legal hold flags

### Backups/DR
- daily backups, monthly restore test
- documented RTO/RPO

### Session
- email-verified accounts, optional MFA later
- short JWT lifetimes, refresh handling

---

## 10. Non-Functional Requirements

### Performance
- list views under 300ms server time
- index on `client_name`, `policy_no`, `status`, `insurer_id`, `owner_id`, `created_at`

### Scalability
- designed for 400→10k clients (pagination, composite indexes)

### Reliability
- 99.5% target
- graceful error states
- retry for file uploads

### Observability
- error/reporting hooks (Sentry later)
- request tracing IDs in logs

### Accessibility
- color contrast AA
- keyboard navigation
- focus states visible

### Testing
- Riverpod unit tests for controllers
- repository mocks
- golden tests for key widgets

### CI/CD
- GitHub Actions (analyze, test, build web)
- Supabase migrations in repo

---

## Theme & Design System (IMR)

Based on your logo (Brand Orange & Light Grey) with a modern glassmorphism look that still respects readability and enterprise tone.

### Color Palette
- **Brand Orange**: #F57C00 (Primary / CTA)
- **Brand Grey**: #A7A9AC (Secondary / icons / borders)
- **Deep Grey**: #4A4A4A (Primary text on dark bg)
- **Off White**: #F5F6F8 (Light surfaces)
- **Pure White**: #FFFFFF (Text on orange / cards)
- **Glass Surface**: rgba(255,255,255,0.15) (cards/nav)
- **Glass Border**: rgba(255,255,255,0.30)
- **Backdrop**: gradient #2F2F2F → #4A4A4A with subtle orange blobs at 10–15% opacity

### State Colors
- **Success**: #2E7D32
- **Warning**: #F9A825
- **Error**: #D32F2F
- **Info**: #0288D1

Create semantic tokens in code: `brand.primary`, `brand.secondary`, `text.primary`, `surface.glass`, `border.glass`, `state.success|warning|error|info`.

### Typography
- **Headers**: Poppins (600/700)
- **Body/UI**: Roboto (400/500)

**Sizes:**
- H1: 32/38 (desktop), 26/32 (mobile)
- H2: 24/30, 22/28
- H3: 20/26
- Body: 16/24
- Caption/Meta: 13–14/18

**Usage:**
- H1 for page titles (dashboard/module heads)
- H2 for section titles
- H3 for card titles/dialog heads
- Body for forms/tables; Caption for meta, helper text

### Spacing & Radii
- **8-pt spacing**: 4 / 8 / 12 / 16 / 24 / 32
- **Corners**: 16–20px on glass cards; 12–14px inputs/buttons

### Elevation/Shadow
- **Card**: 0 8px 30px rgba(0,0,0,0.25)
- **Hover**: add soft glow 0 0 0 1px #F57C00 at 20% opacity

### Glassmorphism Guidelines
- **Surface**: translucent white 10–15%, backdrop blur 20–30px
- **Borders**: 1px glass border + subtle inner highlight (optional gradient stroke)
- **Contrast**: on glass, use white text for headings and near-white for body; put inputs in slightly more opaque surfaces to aid readability

### Components
- **Top App Bar**: glass; left logo; right user menu; thin orange underline for active tab
- **Side Nav (desktop)**: glass rail with icons + labels; active item pill with orange left bar
- **Cards**: glass with icon circle (brand grey) + title; CTA buttons in orange

**Buttons:**
- **Primary**: brand orange, white text; hover = slight scale + glow
- **Secondary**: outlined orange; hover = orange bg 8%
- **Tertiary**: text button (deep grey/white depending bg)

**Inputs**: filled glass fields; focus ring brand orange; clear inline validation

**Tables**: dense header with subtle glass; zebra rows at 4–6% white overlay; sticky header; compact mode toggle

**Chips/Badges**: statuses (lead, quote, claim) with semantic colors; rounded, small caps

**Steppers**: for wizards (lead→quote→convert; renewal review; claim stages)

**Charts**: clean axes; minimal grid; series color = brand orange; comparatives = brand grey; tooltips glass

### Responsiveness
**Breakpoints:**
- Mobile < 600, Tablet 600–1024, Desktop > 1024

**Layouts:**
- **Mobile**: top app bar + bottom nav (optional), single column, off-canvas drawers
- **Tablet**: 2-column where possible; collapsible side nav
- **Desktop**: side nav + content, 12-column grid; persistent activity drawer on wide screens

### PDF Styling
- **Header**: IMR logo left, company details right; brand orange line under header
- **Body**: Poppins headers, Roboto body; grey table headers; orange accent cells
- **Footer**: page number, contact details, confidentiality note

---

## Acceptance Criteria (per module)

### Sales
- [ ] Can create/edit/assign leads with unique contact
- [ ] Can log interactions; next action required when status advances
- [ ] Can create multi-insurer quote options; compare; select one; generate PDF
- [ ] Convert to client wizard preserves history and attaches Broker Authorization

### Administration
- [ ] Completeness meter updates live as fields/docs added
- [ ] Renewal records auto-created per policy; reminders fire in correct windows
- [ ] Appointment Letter PDF generated and stored; email logged

### Claims
- [ ] Intake validates policy coverage date; stage changes require reason notes
- [ ] SLA breach flags visible on lists; financial fields roll up to claim total

### Commission
- [ ] Statement upload supports at least CSV/XLSX; mapping saved per insurer
- [ ] Unmatched lines queue with tools to search/link; period close locks edits

### Dashboards
- [ ] Tiles show counts with correct filters; clicking a tile opens filtered list
- [ ] Users can save a filtered view as "My View"; persists per user

### Security
- [ ] RLS prevents cross-role data leakage (tested with row fixtures)
- [ ] Access logs record PII document views; non-admins can't export sensitive lists

---

## Build Notes (Flutter/Riverpod/Supabase)

### Feature Modules
- sales, admin, claims, commission, dashboard, shared

### State Management
- Riverpod StateNotifier/AsyncNotifier per feature
- repository pattern for DB

### Routing
- GoRouter with nested routes
- guards by role
- 404 friendly

### Migrations
- `.migrations` folder, SQL checked in
- enums for statuses
- composite indexes

### Edge Functions
- **Renewal cron** (daily): create tasks at 90/60/30 days; send reminder emails
- **Commission import post-process**: normalization and pre-matching