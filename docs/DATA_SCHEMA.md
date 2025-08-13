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
| id                 | uuid (PK)          | Default `gen_random_uuid()` |
| client_type        | enum: `personal`, `business`, `body_corporate` | Required |
| entity_name        | text               | For business/body corporate only |
| first_name         | text               | For personal only |
| last_name          | text               | For personal only |
| id_number          | text               | SA ID number (personal), unique if not null |
| company_reg_number | text               | Business registration number, unique if not null |
| vat_number         | text               | Optional, unique if not null |
| email              | text               | Contact email |
| phone              | text               | Contact phone |
| status             | enum: `active`, `inactive`, `prospect` | Default `active` |
| created_by         | uuid (FK → auth.users) | Owner |
| created_at         | timestamptz         | Default `now()` |
| updated_at         | timestamptz         | Default `now()` |

**Constraints:**
- Personal clients must have `first_name` and `last_name`, `entity_name` must be null
- Business/body corporate clients must have `entity_name`, `first_name` and `last_name` must be null
- ID number must be 13 digits if provided

---

### 2.2 Client Contacts
Holds multiple contact records linked to a client.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| client_id    | uuid (FK → clients.id) | Required |
| name         | text               | Full name, required |
| email        | text               | Optional |
| phone        | text               | Optional |
| position     | text               | E.g., Director, Broker Contact |
| is_primary   | boolean            | Default `false` |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.3 Addresses
Stores addresses per client.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| client_id    | uuid (FK → clients.id) | Required |
| type         | text               | Default `'physical'` |
| line_1       | text               | Required |
| line_2       | text               | Optional |
| city         | text               | Required |
| province     | text               | Required |
| postal_code  | text               | Required |
| country      | text               | Default `'South Africa'` |
| is_primary   | boolean            | Default `false` |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.4 Insurers
Holds registered insurers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| name         | text               | Required, unique |
| code         | text               | Optional insurer code |
| website      | text               | Optional |
| phone        | text               | Optional |
| email        | text               | Optional |
| status       | text               | Default `'active'` |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.5 Products
Links products to insurers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| insurer_id   | uuid (FK → insurers.id) | Required |
| name         | text               | Required |
| description  | text               | Optional |
| category     | text               | Required |
| status       | text               | Default `'active'` |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.6 Policy Types
Defines possible covers.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| name         | text               | Required |
| slug         | text               | Required, unique |
| description  | text               | Optional |
| category     | text               | Required |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

### 2.7 Policies
Main policy table.

| Column         | Type               | Constraints / Notes |
|----------------|--------------------|---------------------|
| id             | uuid (PK)          | Default `gen_random_uuid()` |
| policy_number  | text               | Required |
| client_id      | uuid (FK → clients.id) | Required |
| insurer_id     | uuid (FK → insurers.id) | Required |
| product_id     | uuid (FK → products.id) | Required |
| start_date     | date               | Required |
| end_date       | date               | Required, used for annual renewal tracking |
| premium_amount | decimal(10,2)      | Required |
| excess_amount  | decimal(10,2)      | Optional |
| status         | enum: `active`, `expired`, `cancelled`, `pending` | Default `active` |
| renewal_flag   | boolean            | Default `false`, true if within 2 months of `end_date` |
| created_by     | uuid (FK → auth.users) | |
| created_at     | timestamptz         | Default `now()` |
| updated_at     | timestamptz         | Default `now()` |

---

### 2.8 Policy Covers (Sections)
Normalized covers linked to policies.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| policy_id    | uuid (FK → policies.id) | PK part |
| type_id      | uuid (FK → policy_types.id) | PK part |
| sum_insured  | decimal(12,2)      | Required |
| premium      | decimal(10,2)      | Required |
| excess       | decimal(10,2)      | Optional |
| created_at   | timestamptz         | Default `now()` |

---

### 2.9 Policy Endorsements
Tracks changes to policies.

| Column         | Type               | Constraints / Notes |
|----------------|--------------------|---------------------|
| id             | uuid (PK)          | Default `gen_random_uuid()` |
| policy_id      | uuid (FK → policies.id) | Required |
| endorsement_number | text          | Required |
| description    | text               | Required |
| effective_date | date               | Required |
| premium_adjustment | decimal(10,2)  | Default `0` |
| created_by     | uuid (FK → auth.users) | |
| created_at     | timestamptz         | Default `now()` |
| updated_at     | timestamptz         | Default `now()` |

---

### 2.10 Claims
Main claims table.

| Column        | Type               | Constraints / Notes |
|---------------|--------------------|---------------------|
| id            | uuid (PK)          | Default `gen_random_uuid()` |
| claim_number  | text               | Required, unique |
| policy_id     | uuid (FK → policies.id) | Required |
| claim_type    | enum: `theft`, `accident`, `fire`, `flood`, `other` | Required |
| date_reported | date               | Required |
| date_incident | date               | Optional |
| description   | text               | Required |
| estimated_value | decimal(12,2)    | Optional |
| status        | enum: `open`, `in_progress`, `closed`, `rejected` | Default `open` |
| created_by    | uuid (FK → auth.users) | |
| created_at    | timestamptz         | Default `now()` |
| updated_at    | timestamptz         | Default `now()` |

---

### 2.11 Claim Items
Line items for claims.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| claim_id     | uuid (FK → claims.id) | Required |
| description  | text               | Required |
| quantity     | integer            | Default `1` |
| unit_price   | decimal(10,2)      | Required |
| total_amount | decimal(10,2)      | Required |
| created_at   | timestamptz         | Default `now()` |

---

### 2.12 Claim Updates
Tracks updates in the claim lifecycle.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| claim_id     | uuid (FK → claims.id) | Required |
| status       | enum: `open`, `in_progress`, `closed`, `rejected` | Required |
| notes        | text               | Required |
| created_by   | uuid (FK → auth.users) | |
| created_at   | timestamptz         | Default `now()` |

---

### 2.13 Attachments (Polymorphic)
Stores files linked to any entity.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | Default `gen_random_uuid()` |
| parent_type  | text               | E.g., 'policy', 'claim', 'endorsement' |
| parent_id    | uuid               | Required |
| file_name    | text               | Required |
| file_path    | text               | Required |
| file_size    | integer            | Required |
| mime_type    | text               | Required |
| uploaded_at  | timestamptz         | Default `now()` |
| uploaded_by  | uuid (FK → auth.users) | |

---

### 2.14 Employees (Profiles)
Maps auth users to business profiles.

| Column       | Type               | Constraints / Notes |
|--------------|--------------------|---------------------|
| id           | uuid (PK)          | FK → auth.users.id |
| employee_number | text            | Required, unique |
| first_name   | text               | Required |
| last_name    | text               | Required |
| email        | text               | Required, unique |
| phone        | text               | Optional |
| role         | enum: `admin`, `manager`, `sales`, `claims`, `support` | Required |
| department   | text               | Optional |
| hire_date    | date               | Required |
| status       | text               | Default `'active'` |
| created_at   | timestamptz         | Default `now()` |
| updated_at   | timestamptz         | Default `now()` |

---

## 3. Enums

- `client_type`: `personal`, `business`, `body_corporate`
- `client_status`: `active`, `inactive`, `prospect`
- `policy_status`: `active`, `expired`, `cancelled`, `pending`
- `claim_status`: `open`, `in_progress`, `closed`, `rejected`
- `claim_type`: `theft`, `accident`, `fire`, `flood`, `other`
- `employee_role`: `admin`, `manager`, `sales`, `claims`, `support`
- `task_status`: `pending`, `in_progress`, `completed`, `cancelled`
- `task_priority`: `low`, `medium`, `high`, `urgent`

---

## 4. Indexes

### Performance Indexes
- `idx_clients_client_type` - On clients.client_type
- `idx_clients_status` - On clients.status
- `idx_clients_created_by` - On clients.created_by
- `idx_policies_client_id` - On policies.client_id
- `idx_policies_insurer_id` - On policies.insurer_id
- `idx_policies_status` - On policies.status
- `idx_policies_end_date` - On policies.end_date
- `idx_policies_renewal_flag` - On policies.renewal_flag
- `idx_claims_policy_id` - On claims.policy_id
- `idx_claims_status` - On claims.status
- `idx_claims_date_reported` - On claims.date_reported
- `idx_addresses_client_id` - On addresses.client_id
- `idx_addresses_primary` - On addresses(client_id, is_primary) WHERE is_primary = true
- `idx_client_contacts_client_id` - On client_contacts.client_id
- `idx_client_contacts_primary` - On client_contacts(client_id, is_primary) WHERE is_primary = true
- `idx_attachments_parent` - On attachments(parent_type, parent_id)

### Unique Indexes
- `clients_id_number_unique` - On clients.id_number WHERE id_number IS NOT NULL
- `clients_company_reg_number_unique` - On clients.company_reg_number WHERE company_reg_number IS NOT NULL
- `clients_vat_number_unique` - On clients.vat_number WHERE vat_number IS NOT NULL

---

## 5. RLS Policies

### Helper Functions
- `has_role(role_name)` - Checks if user has specific role
- `is_admin_or_manager()` - Checks if user is admin or manager
- `is_sales_role()` - Checks if user has sales role
- `can_access_client(client_id)` - Checks if user can access client data

### Access Rules
- **Admin/Manager**: Full access to all data
- **Sales**: Access to clients they created or are assigned to
- **Claims**: Access to claims they created or are assigned to
- **Support**: Limited access based on role
- **Employees**: Can only see their own profile

### Table Policies
- **Clients**: Role-based access with ownership tracking
- **Policies**: Access based on client ownership
- **Claims**: Access based on policy ownership
- **Employees**: Self-access + admin/manager access
- **Reference Data**: Read-only for authenticated users, admin-only for modifications

---

## 6. Triggers

### Automatic Timestamps
- `update_updated_at_column()` function updates `updated_at` timestamp on all tables
- Triggers applied to all tables with `updated_at` columns

---

## 7. Migration Files

The database schema is managed through the following migration files:

1. **`20250812062117_initial_schema.sql`** - Base schema with tables, enums, and RLS
2. **`20250812062118_foreign_keys.sql`** - Foreign key relationships
3. **`20250812062119_constraints_indexes.sql`** - Constraints, indexes, and triggers
4. **`20250812062120_rls_policies.sql`** - Row Level Security policies

---

## 8. Current Status

✅ **Database Schema**: Complete and implemented  
✅ **Migrations**: All 4 migrations applied successfully  
✅ **Type Generation**: Working correctly  
✅ **API Access**: Tables exposed through REST API  
✅ **RLS Policies**: Security policies in place  
✅ **Indexes**: Performance indexes created  
✅ **Constraints**: Data integrity constraints applied  

---

## 9. Future Considerations

- Commission CSV ingestion module (Phase 2)
- Audit logging for key policy & claim events
- Optional client interaction logs (if required later)
- Additional business logic functions
- Dashboard views for analytics
