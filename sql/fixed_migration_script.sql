-- =====================================================
-- FIXED MIGRATION SCRIPT - MATCHES ACTUAL SUPABASE SCHEMA
-- =====================================================
-- Use this script in Supabase SQL Editor
-- Upload your CSV files to Supabase Storage first
-- =====================================================

-- Step 1: Create storage bucket (run this first)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('migration-data', 'migration-data', false)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Load Insurance Companies
CREATE TEMP TABLE temp_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Upload dbo.insurance_company_dim.csv to storage first, then run:
-- COPY temp_insurers FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.insurance_company_dim.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    Insurar_Name as name,
    '{}'::jsonb as contact_info,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_insurers
WHERE Insurar_Name IS NOT NULL AND Insurar_Name != ''
ON CONFLICT (name) DO NOTHING;

-- Step 3: Load Policy Types (FIXED - removed category column)
CREATE TEMP TABLE temp_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

CREATE TEMP TABLE temp_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Upload both CSV files to storage first, then run:
-- COPY temp_commercial_types FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.commercial_insurance_type_dim.csv' WITH (FORMAT csv, HEADER true);
-- COPY temp_personal_types FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.personal_insurance_type_dim.csv' WITH (FORMAT csv, HEADER true);

-- Insert commercial types (FIXED - removed category from INSERT)
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_commercial_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Insert personal types (FIXED - removed category from INSERT)
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_personal_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Step 4: Load Claim Types
CREATE TEMP TABLE temp_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

-- Upload ft_claim_type.csv to storage first, then run:
-- COPY temp_claim_types FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/ft_claim_type.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    ft_claim_type as name,
    'Migrated from Azure' as description,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_claim_types
WHERE ft_claim_type IS NOT NULL AND ft_claim_type != ''
ON CONFLICT (name) DO NOTHING;

-- Step 5: Load Clients (FIXED - updated client_type enum)
CREATE TEMP TABLE temp_clients (
    Client_ID INTEGER,
    Client_Name TEXT,
    Client_Surname TEXT,
    Client_ID_Nr TEXT,
    Client_Type TEXT,
    Company_Name TEXT,
    Body_Corporate_Name TEXT,
    Insurance_Status TEXT,
    Comments TEXT,
    Email TEXT,
    Cell_Number TEXT,
    Alt_Email TEXT,
    Alt_Number TEXT,
    Trustee_Name TEXT,
    Trustee_Contact_Number TEXT,
    extraction_date TEXT
);

-- Upload dbo.client_dim.csv to storage first, then run:
-- COPY temp_clients FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.client_dim.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    CASE 
        WHEN LOWER(Client_Type) = 'personal' THEN 'personal'::client_type
        WHEN LOWER(Client_Type) = 'commercial' THEN 'business'::client_type
        ELSE 'personal'::client_type
    END as client_type,
    COALESCE(Client_Name, '') as first_name,
    COALESCE(Client_Surname, '') as last_name,
    Client_ID_Nr as id_number,
    CASE 
        WHEN LOWER(Client_Type) = 'commercial' THEN COALESCE(Company_Name, Body_Corporate_Name)
        ELSE NULL
    END as entity_name,
    COALESCE(Comments, '') as comments,
    CASE 
        WHEN Insurance_Status IS NULL OR Insurance_Status = '' THEN 'active'::client_status
        ELSE 'inactive'::client_status
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_clients
WHERE Client_ID IS NOT NULL
  AND (Client_Name IS NOT NULL OR Client_Surname IS NOT NULL)
  AND Client_ID_Nr IS NOT NULL
ON CONFLICT (id_number) DO NOTHING;

-- Step 6: Load Addresses
CREATE TEMP TABLE temp_addresses (
    Address_ID_Key INTEGER,
    Client_Id_Key INTEGER,
    Street TEXT,
    Suburb TEXT,
    City TEXT,
    Province TEXT,
    Postal_Code TEXT,
    Unit_Number TEXT,
    extraction_date TEXT
);

-- Upload dbo.address_dim.csv to storage first, then run:
-- COPY temp_addresses FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.address_dim.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO addresses (id, client_id, line1, line2, city, province, postal_code, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    c.id as client_id,
    CASE 
        WHEN temp.Unit_Number IS NOT NULL AND temp.Unit_Number != '' 
        THEN CONCAT(temp.Street, ' Unit ', temp.Unit_Number)
        ELSE temp.Street
    END as line1,
    temp.Suburb as line2,
    temp.City as city,
    temp.Province as province,
    temp.Postal_Code as postal_code,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_addresses temp
JOIN clients c ON c.id_number = (
    SELECT Client_ID_Nr FROM temp_clients 
    WHERE Client_ID = temp.Client_Id_Key
)
WHERE temp.Client_Id_Key IS NOT NULL
  AND (temp.City IS NOT NULL OR temp.Province IS NOT NULL);

-- Step 7: Load Policies (FIXED - updated policy_status enum)
CREATE TEMP TABLE temp_policies (
    Insurance_ID_Key INTEGER,
    Insurance_Client_Key INTEGER,
    Insurar_ID INTEGER,
    Insurance_Type_ID INTEGER,
    Policy_Number TEXT,
    Premium DECIMAL(10,2),
    Excess DECIMAL(10,2),
    Ins_Start_Date DATE,
    Ins_End_Date DATE,
    Ins_Renewal_Date DATE,
    Insurance_Type TEXT,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Upload dbo.policy_dim.csv to storage first, then run:
-- COPY temp_policies FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/dbo.policy_dim.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO policies (id, client_id, insurer_id, policy_type_id, policy_number, premium, excess, start_date, end_date, renewal_date, coverage_details, status, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    c.id as client_id,
    i.id as insurer_id,
    pt.id as policy_type_id,
    temp.Policy_Number as policy_number,
    temp.Premium as premium,
    temp.Excess as excess,
    temp.Ins_Start_Date as start_date,
    temp.Ins_End_Date as end_date,
    temp.Ins_Renewal_Date as renewal_date,
    temp.Insurance_Type as coverage_details,
    CASE 
        WHEN temp.Ins_End_Date IS NULL OR temp.Ins_End_Date >= CURRENT_DATE THEN 'active'::policy_status
        ELSE 'cancelled'::policy_status
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_policies temp
JOIN clients c ON c.id_number = (
    SELECT Client_ID_Nr FROM temp_clients 
    WHERE Client_ID = temp.Insurance_Client_Key
)
JOIN insurers i ON i.name = temp.Insurar_Name
LEFT JOIN policy_types pt ON pt.display_name = temp.Insurance_Type
WHERE temp.Insurance_ID_Key IS NOT NULL
  AND temp.Policy_Number IS NOT NULL
  AND temp.Premium IS NOT NULL;

-- Step 8: Validation
SELECT '=== MIGRATION COMPLETE ===' as info;

SELECT 'Table Counts:' as info;
SELECT 'insurers' as table_name, COUNT(*) as count FROM insurers
UNION ALL
SELECT 'policy_types', COUNT(*) FROM policy_types
UNION ALL
SELECT 'claim_types', COUNT(*) FROM claim_types
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'policies', COUNT(*) FROM policies;

-- Sample data verification
SELECT 'Sample Policy Types:' as info;
SELECT display_name, slug FROM policy_types ORDER BY display_name LIMIT 5;

SELECT 'Sample Clients:' as info;
SELECT client_type, first_name, last_name, entity_name, status 
FROM clients 
ORDER BY created_at DESC 
LIMIT 5;

-- Clean up
DROP TABLE temp_insurers;
DROP TABLE temp_commercial_types;
DROP TABLE temp_personal_types;
DROP TABLE temp_claim_types;
DROP TABLE temp_clients;
DROP TABLE temp_addresses;
DROP TABLE temp_policies;
