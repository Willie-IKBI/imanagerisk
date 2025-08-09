# IMR Database Schema – Detailed Reference

This document defines the **logical database schema** for the **I Manage Risk (IMR)** application.  
It is based on the project requirements and the reference schema provided, adapted for strict role-based access, South African-specific fields, and normalized data structures.

---

## 1. Core Principles

- **Single `clients` table** for all entity types (Personal, Business, Body Corporate).
- Flexible but strict data requirements:
  - Certain fields required depending on `client_type`.
  - Validation handled in application layer and/or via DB constraints.
- **Role-based access** enforced via Supabase Row Level Security (RLS).
- **Normalized** design for policies, covers, endorsements, and related entities.
- **Shared contacts** for a single client.
- **One primary address** per client, with ability to store additional addresses if needed.
- **SA-specific fields** (ID Number, Company Reg Number, VAT Number).
- All timestamps in UTC, created/updated tracking.
- Use of `uuid` as primary keys across all tables.

---

## 2. Tables

### 2.1 Clients
Holds all client entities.

| Column             | Type               | Constraints / Notes |
|--------------------|--------------------|---------------------|
| id                 | uuid (PK)          | Default `uuid_generate_v4()` |
| client_type        | enum: `personal`, `business`, `body_corporate` | Required |
| entity_name        | text               | For business/body corporate only |
| first_name         | text               | For personal only |
| last_name          | text               | For personal only |
| id_number          | varchar            | SA ID number (personal) |
| company_reg_number | varchar            | Business registration number |
| vat_number         | varchar            | Optional |
| comments           | text               | Notes on client |
| status             | enum: `active`, `inactive` | Default `active` |
| created_by         | uuid (FK → auth.users) | Owner |
| created_at         | timestamptz         | Default `now()` |
| updated_at         | timestamptz         | Default `now()` |

---

### 2.2 Client Contacts
Holds multiple contact records linked to a client.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| client_id    | uuid (FK → clients.id) | Required |
| is_primary   | boolean            | Default `false` |
| role         | text                | E.g., Director, Broker Contact |
| name         | text               | Full name |
| phone        | varchar            | |
| email        | text               | |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.3 Addresses
Stores addresses per client.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| client_id    | uuid (FK → clients.id) | Required |
| is_primary   | boolean            | Only one `true` per client |
| line1        | text               | Required |
| line2        | text               | Optional |
| city         | text               | |
| province     | text               | |
| postal_code  | varchar            | |
| country      | text               | Default `South Africa` |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.4 Insurers
Holds registered insurers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| name         | text               | Required, unique |
| contact_info | jsonb              | Flexible storage for emails, phones |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.5 Products
Links products to insurers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| insurer_id   | uuid (FK → insurers.id) | Required |
| name         | text               | Required |
| description  | text               | Optional |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.6 Policies
Main policy table.

| Column         | Type               | Constraints / Notes |
|----------------|--------------------|---------------------|
| id             | uuid (PK)          | Default `uuid_generate_v4()` |
| client_id      | uuid (FK → clients.id) | Required |
| insurer_id     | uuid (FK → insurers.id) | Required |
| product_id     | uuid (FK → products.id) | Required |
| policy_number  | text               | Required |
| start_date     | date               | |
| end_date       | date               | Used for annual renewal tracking |
| status         | enum: `active`, `cancelled`, `pending` | Default `active` |
| renewal_flag   | boolean            | True if within 2 months of `end_date` |
| created_by     | uuid (FK → auth.users) | |
| created_at     | timestamptz         | Default `now()` |
| updated_at     | timestamptz         | Default `now()` |

---

### 2.7 Policy Covers (Sections)
Normalized covers linked to policies.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| policy_id    | uuid (FK → policies.id) | PK part |
| type_id      | uuid (FK → policy_types.id) | PK part |
| sum_insured  | numeric            | Optional |
| premium      | numeric            | Optional |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.8 Policy Types
Defines possible covers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| slug         | text               | Required, unique |
| display_name | text               | Required |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.9 Policy Endorsements
Tracks changes to policies.

| Column         | Type               | Constraints / Notes |
|----------------|--------------------|---------------------|
| id             | uuid (PK)          | Default `uuid_generate_v4()` |
| policy_id      | uuid (FK → policies.id) | Required |
| endorsement_type | text             | E.g., Cover Change, Address Change |
| description    | text               | Required |
| effective_date | date               | |
| created_by     | uuid (FK → auth.users) | |
| created_at     | timestamptz         | Default `now()` |
| updated_at     | timestamptz         | Default `now()` |

---

### 2.10 Claims
Main claims table.

| Column        | Type               | Constraints / Notes |
|---------------|--------------------|---------------------|
| id            | uuid (PK)          | Default `uuid_generate_v4()` |
| policy_id     | uuid (FK → policies.id) | Required |
| claim_number  | text               | Required, unique |
| date_reported | date               | Required |
| status        | enum: `reported`, `in_review`, `approved`, `declined`, `settled` | Default `reported` |
| created_by    | uuid (FK → auth.users) | |
| created_at    | timestamptz         | Default `now()` |
| updated_at    | timestamptz         | Default `now()` |

---

### 2.11 Claim Items
Line items for claims.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| claim_id     | uuid (FK → claims.id) | Required |
| description  | text               | Required |
| amount       | numeric            | Optional |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.12 Claim Updates
Tracks updates in the claim lifecycle.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| claim_id     | uuid (FK → claims.id) | Required |
| update_text  | text               | Required |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.13 Attachments (Polymorphic)
Stores files linked to any entity.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `uuid_generate_v4()` |
| parent_type  | text               | E.g., 'policy', 'claim', 'endorsement' |
| parent_id    | uuid               | |
| url          | text               | Public or signed URL |
| uploaded_by  | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.14 Employees (Profiles)
Maps auth users to business profiles.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | FK → auth.users.id |
| full_name    | text               | Required |
| contact_number | varchar          | Optional |
| display_image | text              | Optional |
| role         | text               | Enum in RLS |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

## 3. Enums

- `client_type`: `personal`, `business`, `body_corporate`
- `insurance_status_enum`: `active`, `inactive`
- `claim_status_enum`: `reported`, `in_review`, `approved`, `declined`, `settled`
- `policy_status_enum`: `active`, `cancelled`, `pending`

---

## 4. RLS Plan (High-Level)

- **Default Deny** on all tables.
- **Read/Write Access** only where:
  - `created_by = auth.uid()` OR user has `manager` / `admin` role in `employees`.
  - For `employees`, only super_admin can manage roles.
- **Attachments**:
  - Signed URLs for private documents.
- **Renewals**:
  - Viewable only by admin, manager, sales roles.

---

## 5. Future Considerations

- Commission CSV ingestion module (Phase 2).
- Audit logging for key policy & claim events.
- Optional client interaction logs (if required later).

---
