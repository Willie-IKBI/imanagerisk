# ETL_IMR.md - Comprehensive Data Migration Guide

## 📊 Azure to Supabase Data Migration Strategy

This document provides a detailed step-by-step guide for migrating data from your Azure database to the IMR Supabase application.

## 🎯 Migration Overview

- **Source Database**: Azure SQL Database
- **Target Database**: Supabase PostgreSQL
- **Migration Type**: Manual ETL (Extract, Transform, Load)
- **Estimated Duration**: 2-3 days for complete migration

## 📋 Azure Source Tables Identified

### 1. Core Entity Tables
- `dbo.client_dim` - Client information
- `dbo.address_dim` - Address information
- Insurance Policy Table - Main policy records

### 2. Reference/Lookup Tables
- `dbo.insurance_company_dim` - Insurance companies
- `dbo.commercial_insurance_type_dim` - Commercial insurance types
- `_personal_insurance_type_dim` - Personal insurance types
- `dbo.ft_claim_type_dim` - Claim types

## 🚀 Migration Phases

### Phase 1: Reference Data Migration
**Priority**: High | **Estimated Time**: 4-6 hours
- Insurance companies
- Insurance types (personal & commercial)
- Claim types

### Phase 2: Core Entity Migration
**Priority**: High | **Estimated Time**: 6-8 hours
- Clients
- Addresses

### Phase 3: Business Data Migration
**Priority**: Medium | **Estimated Time**: 8-10 hours
- Policies
- Policy covers
- Client contacts

### Phase 4: Validation & Cleanup
**Priority**: High | **Estimated Time**: 4-6 hours
- Data validation
- Relationship verification
- Error correction

## 📊 Detailed Table Mapping & ETL Steps

### 1. INSURANCE COMPANIES MIGRATION

**Source Table**: `dbo.insurance_company_dim`

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| Insurar_ID_Key | int (PK) | id | uuid | Generate new UUID |
| Insurar_Name | varchar(50) | name | text | Direct mapping |

**Target Table**: `insurers`

#### Extraction Steps:
```sql
-- Export from Azure
SELECT 
    Insurar_ID_Key,
    Insurar_Name
FROM dbo.insurance_company_dim
WHERE Insurar_Name IS NOT NULL
ORDER BY Insurar_ID_Key;

-- Save as CSV: azure_insurance_companies.csv
```

#### Transformation Steps:
1. **Data Cleaning**:
   - Remove duplicates based on Insurar_Name
   - Trim whitespace from company names
   - Handle null/empty values

2. **Data Mapping**:
   - Generate UUID for each record
   - Map Insurar_Name → name
   - Set contact_info as empty JSON object `{}`
   - Set created_at and updated_at to current timestamp

3. **Data Validation**:
   - Ensure company names are not empty
   - Check for special characters that might cause issues
   - Validate data types

#### Loading Steps:
```sql
-- Prepare Supabase
-- Ensure insurers table exists and RLS policies are configured

-- Import Data (example for first few records)
INSERT INTO insurers (id, name, contact_info, created_at, updated_at) VALUES
(gen_random_uuid(), 'Santam', '{}', NOW(), NOW()),
(gen_random_uuid(), 'Old Mutual', '{}', NOW(), NOW()),
(gen_random_uuid(), 'Discovery', '{}', NOW(), NOW());

-- Post-Import Validation
SELECT COUNT(*) FROM insurers;
SELECT name, COUNT(*) FROM insurers GROUP BY name HAVING COUNT(*) > 1;
```

### 2. INSURANCE TYPES MIGRATION

**Source Tables**:
- `dbo.commercial_insurance_type_dim`
- `_personal_insurance_type_dim`

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| insurance_type_key | int (PK) | id | uuid | Generate new UUID |
| insurance_type | varchar(50) | display_name | text | Direct mapping |
| N/A | N/A | category | text | 'commercial' or 'personal' |
| N/A | N/A | slug | text | Generate from display_name |

**Target Table**: `policy_types`

#### Extraction Steps:
```sql
-- Commercial Types
SELECT 
    insurance_type_key,
    insurance_type
FROM dbo.commercial_insurance_type_dim
WHERE insurance_type IS NOT NULL;

-- Personal Types
SELECT 
    insurance_type_key,
    insurance_type
FROM _personal_insurance_type_dim
WHERE insurance_type IS NOT NULL;

-- Save as CSV files:
-- azure_commercial_insurance_types.csv
-- azure_personal_insurance_types.csv
```

#### Transformation Steps:
1. **Data Consolidation**:
   - Combine both CSV files
   - Add category column: 'commercial' or 'personal'
   - Remove duplicates across categories

2. **Data Cleaning**:
   - Trim whitespace from type names
   - Handle null/empty values
   - Standardize naming conventions

3. **Slug Generation**:
   - Convert display_name to URL-friendly slug
   - Example: "Motor Insurance" → "motor-insurance"
   - Ensure uniqueness across all types

#### Loading Steps:
```sql
-- Import to Supabase
INSERT INTO policy_types (id, display_name, category, slug, created_at, updated_at) VALUES
(gen_random_uuid(), 'Motor Insurance', 'commercial', 'motor-insurance', NOW(), NOW()),
(gen_random_uuid(), 'Home Insurance', 'personal', 'home-insurance', NOW(), NOW()),
(gen_random_uuid(), 'Business Liability', 'commercial', 'business-liability', NOW(), NOW());

-- Validation
SELECT COUNT(*) FROM policy_types;
SELECT category, COUNT(*) FROM policy_types GROUP BY category;
```

### 3. CLAIM TYPES MIGRATION

**Source Table**: `dbo.ft_claim_type_dim`

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| ft_claim_type_id | int (PK) | id | uuid | Generate new UUID |
| ft_claim_type | varchar(50) | name | text | Direct mapping |

**Target Table**: `claim_types` (needs to be created)

#### Extraction Steps:
```sql
-- Export from Azure
SELECT 
    ft_claim_type_id,
    ft_claim_type
FROM dbo.ft_claim_type_dim
WHERE ft_claim_type IS NOT NULL;

-- Save as CSV: azure_claim_types.csv
```

#### Loading Steps:
```sql
-- Create Table (if not exists)
CREATE TABLE IF NOT EXISTS claim_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Import Data
INSERT INTO claim_types (id, name) VALUES
(gen_random_uuid(), 'Motor Accident'),
(gen_random_uuid(), 'Theft'),
(gen_random_uuid(), 'Fire Damage'),
(gen_random_uuid(), 'Natural Disaster');
```

### 4. CLIENTS MIGRATION

**Source Table**: `dbo.client_dim`

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| Client_ID | int (PK) | id | uuid | Generate new UUID |
| Client_Name | varchar(50) | first_name | text | Direct mapping |
| Client_Surname | varchar(50) | last_name | text | Direct mapping |
| Client_ID_Nr | nvarchar(13) | id_number | varchar(13) | Direct mapping |
| Client_Type | varchar(50) | client_type | enum | Map to enum values |
| Company_Name | varchar(80) | entity_name | text | Business clients only |
| Body_Corporate_Name | nvarchar(50) | entity_name | text | Body corporate only |
| Insurance_Status | varchar(50) | status | enum | Map to enum values |
| Comments | nvarchar(max) | comments | text | Direct mapping |

**Target Table**: `clients`

#### Extraction Steps:
```sql
-- Export from Azure
SELECT 
    Client_ID,
    Client_Name,
    Client_Surname,
    Client_ID_Nr,
    Client_Type,
    Company_Name,
    Body_Corporate_Name,
    Insurance_Status,
    Comments
FROM dbo.client_dim
WHERE Client_ID IS NOT NULL;

-- Save as CSV: azure_clients.csv
```

#### Transformation Steps:
1. **Data Cleaning**:
   - Remove records with null Client_ID
   - Trim whitespace from all text fields
   - Handle null values appropriately

2. **Client Type Mapping**:
   - 'Personal' → 'personal'
   - 'Business' → 'business'
   - 'Body Corporate' → 'body_corporate'
   - Default to 'personal' for unknown values

3. **Status Mapping**:
   - 'Active' → 'active'
   - 'Inactive' → 'inactive'
   - Default to 'active' for unknown values

4. **Entity Name Logic**:
   - For Client_Type = 'Business': Use Company_Name
   - For Client_Type = 'Body Corporate': Use Body_Corporate_Name
   - For Client_Type = 'Personal': Leave as NULL

#### Loading Steps:
```sql
-- Import to Supabase (example)
INSERT INTO clients (
    id, client_type, first_name, last_name, id_number, 
    entity_name, comments, status, created_at, updated_at
) VALUES
(gen_random_uuid(), 'personal', 'John', 'Doe', '8001015009087', 
 NULL, 'Test client', 'active', NOW(), NOW()),
(gen_random_uuid(), 'business', 'Jane', 'Smith', '9002026009088', 
 'Smith Enterprises', 'Business client', 'active', NOW(), NOW());

-- Validation
SELECT COUNT(*) FROM clients;
SELECT client_type, COUNT(*) FROM clients GROUP BY client_type;
SELECT status, COUNT(*) FROM clients GROUP BY status;
```

### 5. ADDRESSES MIGRATION

**Source Table**: `dbo.address_dim`

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| Address_ID_Key | int (PK) | id | uuid | Generate new UUID |
| Client_Id_Key | int (FK) | client_id | uuid | Map to clients.id |
| Street | nvarchar(50) | line1 | text | Direct mapping |
| Suburb | nvarchar(50) | line2 | text | Direct mapping |
| City | nvarchar(50) | city | text | Direct mapping |
| Province | char(50) | province | text | Direct mapping |
| Postal_Code | nchar(10) | postal_code | varchar(10) | Direct mapping |
| Unit_Number | nchar(10) | line1 | text | Prepend to line1 |

**Target Table**: `addresses`

#### Extraction Steps:
```sql
-- Export from Azure
SELECT 
    Address_ID_Key,
    Client_Id_Key,
    Street,
    Suburb,
    City,
    Province,
    Postal_Code,
    Unit_Number
FROM dbo.address_dim
WHERE Client_Id_Key IS NOT NULL;

-- Save as CSV: azure_addresses.csv
```

#### Transformation Steps:
1. **Client ID Mapping**:
   - Create mapping table: Azure Client_Id_Key → Supabase clients.id
   - This requires the clients migration to be completed first

2. **Address Line Construction**:
   - Combine Unit_Number + Street for line1
   - Use Suburb for line2

3. **Primary Address Logic**:
   - Set is_primary = true for first address per client
   - Set is_primary = false for additional addresses

#### Loading Steps:
```sql
-- Prerequisites: Ensure clients migration is complete
-- Create client ID mapping table

-- Import to Supabase (example)
INSERT INTO addresses (
    id, client_id, line1, line2, city, province, 
    postal_code, country, is_primary, created_at, updated_at
) VALUES
(gen_random_uuid(), 'client-uuid-here', '123 Main Street', 'Suburb', 
 'Johannesburg', 'Gauteng', '2000', 'South Africa', true, NOW(), NOW());

-- Validation
SELECT COUNT(*) FROM addresses;
SELECT COUNT(*) FROM addresses WHERE is_primary = true;
```

### 6. POLICIES MIGRATION

**Source Table**: Insurance Policy Table

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| Insurance_ID_Key | int (PK) | id | uuid | Generate new UUID |
| Insurance_Client_Key | int (FK) | client_id | uuid | Map to clients.id |
| Insurar_ID | int (FK) | insurer_id | uuid | Map to insurers.id |
| Insurance_Type_ID | int (FK) | product_id | uuid | Map to products.id |
| Policy_Number | varchar(50) | policy_number | text | Direct mapping |
| Premium | numeric(18,2) | N/A | N/A | Move to policy_covers |
| Excess | numeric(18,2) | N/A | N/A | Move to policy_covers |
| Ins_Start_Date | date | start_date | date | Direct mapping |
| Ins_End_Date | date | end_date | date | Direct mapping |
| Ins_Renewal_Date | date | N/A | N/A | Store in interactions |

**Target Table**: `policies`

#### Extraction Steps:
```sql
-- Export from Azure (adjust table name as needed)
SELECT 
    Insurance_ID_Key,
    Insurance_Client_Key,
    Insurar_ID,
    Insurance_Type_ID,
    Policy_Number,
    Premium,
    Excess,
    Ins_Start_Date,
    Ins_End_Date,
    Ins_Renewal_Date
FROM [Insurance_Policy_Table]
WHERE Insurance_ID_Key IS NOT NULL;

-- Save as CSV: azure_policies.csv
```

#### Transformation Steps:
1. **ID Mapping**:
   - Map Insurance_Client_Key to Supabase client_id
   - Map Insurar_ID to Supabase insurer_id
   - Map Insurance_Type_ID to Supabase product_id

2. **Status Logic**:
   - Set status = 'active' for current policies
   - Set status = 'cancelled' for expired policies
   - Set renewal_flag = true if renewal date is within 30 days

#### Loading Steps:
```sql
-- Prerequisites: Ensure clients, insurers, and products migrations are complete
-- Create all necessary ID mapping tables

-- Import to Supabase (example)
INSERT INTO policies (
    id, client_id, insurer_id, product_id, policy_number,
    start_date, end_date, status, renewal_flag, created_at, updated_at
) VALUES
(gen_random_uuid(), 'client-uuid', 'insurer-uuid', 'product-uuid',
 'POL001', '2024-01-01', '2024-12-31', 'active', false, NOW(), NOW());

-- Validation
SELECT COUNT(*) FROM policies;
SELECT status, COUNT(*) FROM policies GROUP BY status;
```

### 7. CLIENT CONTACTS MIGRATION

**Source Table**: `dbo.client_dim` (derived)

| Azure Column | Type | Supabase Column | Type | Transformation |
|--------------|------|-----------------|------|----------------|
| Email | nvarchar(50) | email | text | Primary contact |
| Cell_Number | nvarchar(15) | phone | text | Primary contact |
| Alt_Email | nvarchar(50) | email | text | Secondary contact |
| Alt_Number | nvarchar(15) | phone | text | Secondary contact |
| Trustee_Name | nvarchar(50) | name | text | Trustee contact |
| Trustee_Contact_Number | nvarchar(15) | phone | text | Trustee contact |

**Target Table**: `client_contacts`

#### Extraction Steps:
```sql
-- Export from Azure
SELECT 
    Client_ID,
    Email,
    Cell_Number,
    Alt_Email,
    Alt_Number,
    Trustee_Name,
    Trustee_Contact_Number
FROM dbo.client_dim
WHERE Client_ID IS NOT NULL;

-- Save as CSV: azure_client_contacts.csv
```

#### Transformation Steps:
1. **Contact Record Generation**:
   - Create separate records for each contact type
   - Primary contact: Email + Cell_Number
   - Secondary contact: Alt_Email + Alt_Number
   - Trustee contact: Trustee_Name + Trustee_Contact_Number

2. **Role Assignment**:
   - Primary contact: role = 'primary', is_primary = true
   - Secondary contact: role = 'secondary', is_primary = false
   - Trustee contact: role = 'trustee', is_primary = false

#### Loading Steps:
```sql
-- Prerequisites: Ensure clients migration is complete
-- Create client ID mapping table

-- Import to Supabase (example for primary contact)
INSERT INTO client_contacts (
    id, client_id, name, email, phone, role, is_primary, created_at, updated_at
) VALUES
(gen_random_uuid(), 'client-uuid', 'John Doe', 'john@email.com', 
 '0821234567', 'primary', true, NOW(), NOW());

-- Validation
SELECT COUNT(*) FROM client_contacts;
SELECT role, COUNT(*) FROM client_contacts GROUP BY role;
```

## 🔧 Migration Tools & Scripts

### Required Tools:
- Azure Data Studio or SQL Server Management Studio for data extraction
- Excel or Google Sheets for data transformation
- Supabase Dashboard for data loading
- PostgreSQL client for validation queries

### Data Export Scripts:
```sql
-- Complete export script for all tables
-- Run this in Azure to get all data at once

-- 1. Insurance Companies
SELECT 'insurance_companies' as table_name, COUNT(*) as record_count
FROM dbo.insurance_company_dim
UNION ALL

-- 2. Insurance Types
SELECT 'commercial_insurance_types' as table_name, COUNT(*) as record_count
FROM dbo.commercial_insurance_type_dim
UNION ALL
SELECT 'personal_insurance_types' as table_name, COUNT(*) as record_count
FROM _personal_insurance_type_dim
UNION ALL

-- 3. Claim Types
SELECT 'claim_types' as table_name, COUNT(*) as record_count
FROM dbo.ft_claim_type_dim
UNION ALL

-- 4. Clients
SELECT 'clients' as table_name, COUNT(*) as record_count
FROM dbo.client_dim
UNION ALL

-- 5. Addresses
SELECT 'addresses' as table_name, COUNT(*) as record_count
FROM dbo.address_dim
UNION ALL

-- 6. Policies (adjust table name)
SELECT 'policies' as table_name, COUNT(*) as record_count
FROM [Insurance_Policy_Table];
```

### Data Validation Scripts:
```sql
-- Post-migration validation queries

-- 1. Check record counts
SELECT 'insurers' as table_name, COUNT(*) as record_count FROM insurers
UNION ALL
SELECT 'policy_types' as table_name, COUNT(*) as record_count FROM policy_types
UNION ALL
SELECT 'claim_types' as table_name, COUNT(*) as record_count FROM claim_types
UNION ALL
SELECT 'clients' as table_name, COUNT(*) as record_count FROM clients
UNION ALL
SELECT 'addresses' as table_name, COUNT(*) as record_count FROM addresses
UNION ALL
SELECT 'policies' as table_name, COUNT(*) as record_count FROM policies
UNION ALL
SELECT 'client_contacts' as table_name, COUNT(*) as record_count FROM client_contacts;

-- 2. Check for orphaned records
SELECT 'addresses_without_clients' as issue, COUNT(*) as count
FROM addresses a
LEFT JOIN clients c ON a.client_id = c.id
WHERE c.id IS NULL;

SELECT 'policies_without_clients' as issue, COUNT(*) as count
FROM policies p
LEFT JOIN clients c ON p.client_id = c.id
WHERE c.id IS NULL;

-- 3. Check data quality
SELECT 'clients_without_id_number' as issue, COUNT(*) as count
FROM clients
WHERE id_number IS NULL OR id_number = '';

SELECT 'addresses_without_city' as issue, COUNT(*) as count
FROM addresses
WHERE city IS NULL OR city = '';
```

## ⚠️ Migration Risks & Mitigation

### High-Risk Scenarios:
- **Data Loss**: Export data multiple times, keep backups
- **Relationship Breakage**: Validate all foreign keys after migration
- **Data Corruption**: Test with small datasets first
- **Performance Issues**: Migrate in batches for large tables

### Mitigation Strategies:
- **Backup Strategy**: Create full backups before migration
- **Testing**: Test migration process with sample data
- **Validation**: Implement comprehensive data validation
- **Rollback Plan**: Keep original data accessible during migration

## 📋 Migration Checklist

### Pre-Migration:
- [ ] Backup Azure database
- [ ] Verify Supabase schema is complete
- [ ] Test migration process with sample data
- [ ] Prepare all mapping tables
- [ ] Set up validation queries

### During Migration:
- [ ] Migrate reference data first (insurers, types)
- [ ] Migrate core entities (clients, addresses)
- [ ] Migrate business data (policies, contacts)
- [ ] Validate each phase before proceeding
- [ ] Document any issues or data quality problems

### Post-Migration:
- [ ] Run comprehensive validation queries
- [ ] Verify all relationships are intact
- [ ] Test application functionality
- [ ] Update any hardcoded references
- [ ] Document migration results

## 🎯 Success Criteria

### Data Integrity:
- All records migrated successfully
- No data loss or corruption
- All relationships maintained
- Data types correctly mapped

### Application Functionality:
- All features work with migrated data
- Performance is acceptable
- No errors in application logs
- User authentication and authorization work correctly

### Business Continuity:
- No downtime during migration
- Users can access all functionality
- Data is consistent and accurate
- Backup and recovery procedures tested

## 📞 Support & Troubleshooting

### Common Issues:
- **UUID Generation**: Ensure proper UUID generation for all records
- **Date Formatting**: Handle different date formats between Azure and PostgreSQL
- **Character Encoding**: Ensure proper UTF-8 encoding for text fields
- **Null Values**: Handle null values appropriately in target schema

### Validation Queries:
```sql
-- Quick health check after migration
WITH validation_results AS (
    SELECT 'Total Clients' as metric, COUNT(*) as value FROM clients
    UNION ALL
    SELECT 'Active Clients', COUNT(*) FROM clients WHERE status = 'active'
    UNION ALL
    SELECT 'Total Policies', COUNT(*) FROM policies
    UNION ALL
    SELECT 'Active Policies', COUNT(*) FROM policies WHERE status = 'active'
    UNION ALL
    SELECT 'Total Addresses', COUNT(*) FROM addresses
    UNION ALL
    SELECT 'Primary Addresses', COUNT(*) FROM addresses WHERE is_primary = true
    UNION ALL
    SELECT 'Total Contacts', COUNT(*) FROM client_contacts
    UNION ALL
    SELECT 'Primary Contacts', COUNT(*) FROM client_contacts WHERE is_primary = true
)
SELECT * FROM validation_results ORDER BY metric;
```

---

**This comprehensive ETL guide provides all the necessary steps, mappings, and validation procedures to successfully migrate your Azure data to the IMR Supabase application. Follow the phases in order and validate each step before proceeding to the next.**