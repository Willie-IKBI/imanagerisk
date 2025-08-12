-- =====================================================
-- HTTP-BASED DATA MIGRATION SCRIPT
-- =====================================================
-- This script uses HTTP functions to read CSV files from storage
-- =====================================================

-- Step 1: Enable HTTP extension if not already enabled
CREATE EXTENSION IF NOT EXISTS http;

-- Step 2: Load Insurance Companies
CREATE TEMP TABLE temp_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Read CSV from storage using HTTP
INSERT INTO temp_insurers
SELECT 
    (data->>'Insurar_ID_Key')::INTEGER as Insurar_ID_Key,
    data->>'Insurar_Name' as Insurar_Name,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.insurance_company_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(Insurar_Name) as name,
    '{}'::jsonb as contact_info,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_insurers
WHERE Insurar_Name IS NOT NULL AND TRIM(Insurar_Name) != ''
ON CONFLICT (name) DO NOTHING;

-- Step 3: Load Policy Types (Commercial)
CREATE TEMP TABLE temp_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

INSERT INTO temp_commercial_types
SELECT 
    (data->>'insurance_type_key')::INTEGER as insurance_type_key,
    data->>'insurance_type' as insurance_type,
    data->>'category' as category,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.commercial_insurance_type_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(insurance_type) as display_name,
    LOWER(REPLACE(REPLACE(TRIM(insurance_type), ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_commercial_types
WHERE insurance_type IS NOT NULL AND TRIM(insurance_type) != ''
ON CONFLICT (slug) DO NOTHING;

-- Step 4: Load Policy Types (Personal)
CREATE TEMP TABLE temp_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

INSERT INTO temp_personal_types
SELECT 
    (data->>'insurance_type_key')::INTEGER as insurance_type_key,
    data->>'insurance_type' as insurance_type,
    data->>'category' as category,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.personal_insurance_type_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(insurance_type) as display_name,
    LOWER(REPLACE(REPLACE(TRIM(insurance_type), ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_personal_types
WHERE insurance_type IS NOT NULL AND TRIM(insurance_type) != ''
ON CONFLICT (slug) DO NOTHING;

-- Step 5: Load Claim Types
CREATE TEMP TABLE temp_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

INSERT INTO temp_claim_types
SELECT 
    (data->>'ft_claim_type_id')::INTEGER as ft_claim_type_id,
    data->>'ft_claim_type' as ft_claim_type,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/ft_claim_type.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(ft_claim_type) as name,
    'Migrated from Azure' as description,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_claim_types
WHERE ft_claim_type IS NOT NULL AND TRIM(ft_claim_type) != ''
ON CONFLICT (name) DO NOTHING;

-- Step 6: Create Products (link insurers to policy types)
INSERT INTO products (id, insurer_id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    i.id,
    pt.display_name,
    'Product: ' || pt.display_name || ' by ' || i.name,
    NOW(),
    NOW()
FROM insurers i
CROSS JOIN policy_types pt
WHERE i.name IN (SELECT DISTINCT Insurar_Name FROM temp_insurers WHERE Insurar_Name IS NOT NULL)
ON CONFLICT DO NOTHING;

-- Step 7: Load Clients
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

INSERT INTO temp_clients
SELECT 
    (data->>'Client_ID')::INTEGER as Client_ID,
    data->>'Client_Name' as Client_Name,
    data->>'Client_Surname' as Client_Surname,
    data->>'Client_ID_Nr' as Client_ID_Nr,
    data->>'Client_Type' as Client_Type,
    data->>'Company_Name' as Company_Name,
    data->>'Body_Corporate_Name' as Body_Corporate_Name,
    data->>'Insurance_Status' as Insurance_Status,
    data->>'Comments' as Comments,
    data->>'Email' as Email,
    data->>'Cell_Number' as Cell_Number,
    data->>'Alt_Email' as Alt_Email,
    data->>'Alt_Number' as Alt_Number,
    data->>'Trustee_Name' as Trustee_Name,
    data->>'Trustee_Contact_Number' as Trustee_Contact_Number,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.client_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    CASE
        WHEN LOWER(TRIM(Client_Type)) = 'personal' THEN 'personal'::client_type
        WHEN LOWER(TRIM(Client_Type)) = 'commercial' THEN 'business'::client_type
        ELSE 'personal'::client_type
    END as client_type,
    TRIM(COALESCE(Client_Name, '')) as first_name,
    TRIM(COALESCE(Client_Surname, '')) as last_name,
    TRIM(Client_ID_Nr) as id_number,
    CASE
        WHEN LOWER(TRIM(Client_Type)) = 'commercial' THEN TRIM(COALESCE(Company_Name, Body_Corporate_Name))
        ELSE NULL
    END as entity_name,
    TRIM(COALESCE(Comments, '')) as comments,
    CASE
        WHEN Insurance_Status IS NULL OR TRIM(Insurance_Status) = '' THEN 'active'::client_status
        ELSE 'inactive'::client_status
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_clients
WHERE Client_ID IS NOT NULL
  AND (Client_Name IS NOT NULL OR Client_Surname IS NOT NULL OR Company_Name IS NOT NULL OR Body_Corporate_Name IS NOT NULL)
  AND Client_ID_Nr IS NOT NULL;

-- Step 8: Load Addresses
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

INSERT INTO temp_addresses
SELECT 
    (data->>'Address_ID_Key')::INTEGER as Address_ID_Key,
    (data->>'Client_Id_Key')::INTEGER as Client_Id_Key,
    data->>'Street' as Street,
    data->>'Suburb' as Suburb,
    data->>'City' as City,
    data->>'Province' as Province,
    data->>'Postal_Code' as Postal_Code,
    data->>'Unit_Number' as Unit_Number,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.address_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO addresses (id, client_id, line1, line2, city, province, postal_code, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    c.id as client_id,
    CASE
        WHEN temp.Unit_Number IS NOT NULL AND TRIM(temp.Unit_Number) != ''
        THEN CONCAT(TRIM(temp.Street), ' Unit ', TRIM(temp.Unit_Number))
        ELSE TRIM(temp.Street)
    END as line1,
    TRIM(temp.Suburb) as line2,
    TRIM(temp.City) as city,
    TRIM(temp.Province) as province,
    TRIM(temp.Postal_Code) as postal_code,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_addresses temp
JOIN clients c ON c.id_number = (
    SELECT Client_ID_Nr FROM temp_clients
    WHERE Client_ID = temp.Client_Id_Key
)
WHERE temp.Client_Id_Key IS NOT NULL
  AND (temp.City IS NOT NULL OR temp.Province IS NOT NULL);

-- Step 9: Load Policies
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

INSERT INTO temp_policies
SELECT 
    (data->>'Insurance_ID_Key')::INTEGER as Insurance_ID_Key,
    (data->>'Insurance_Client_Key')::INTEGER as Insurance_Client_Key,
    (data->>'Insurar_ID')::INTEGER as Insurar_ID,
    (data->>'Insurance_Type_ID')::INTEGER as Insurance_Type_ID,
    data->>'Policy_Number' as Policy_Number,
    (data->>'Premium')::DECIMAL(10,2) as Premium,
    (data->>'Excess')::DECIMAL(10,2) as Excess,
    (data->>'Ins_Start_Date')::DATE as Ins_Start_Date,
    (data->>'Ins_End_Date')::DATE as Ins_End_Date,
    (data->>'Ins_Renewal_Date')::DATE as Ins_Renewal_Date,
    data->>'Insurance_Type' as Insurance_Type,
    data->>'Insurar_Name' as Insurar_Name,
    data->>'extraction_date' as extraction_date
FROM (
    SELECT jsonb_array_elements(
        (http((
            'GET',
            'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.policy_dim.csv',
            ARRAY[http_header('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzI5NzQsImV4cCI6MjA1MDU0ODk3NH0.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8')],
            NULL,
            NULL
        )).content::jsonb
    ) as data
) as csv_data;

INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    c.id as client_id,
    i.id as insurer_id,
    p.id as product_id,
    TRIM(temp.Policy_Number) as policy_number,
    temp.Ins_Start_Date as start_date,
    temp.Ins_End_Date as end_date,
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
JOIN insurers i ON i.name = TRIM(temp.Insurar_Name)
LEFT JOIN products p ON p.name = TRIM(temp.Insurance_Type) AND p.insurer_id = i.id
WHERE temp.Insurance_ID_Key IS NOT NULL
  AND temp.Policy_Number IS NOT NULL;

-- Step 10: Validation and Cleanup
SELECT '=== MIGRATION COMPLETE ===' as info;

SELECT 'Final Table Counts:' as info;
SELECT 'insurers' as table_name, COUNT(*) as count FROM insurers
UNION ALL
SELECT 'policy_types', COUNT(*) FROM policy_types
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'claim_types', COUNT(*) FROM claim_types
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'policies', COUNT(*) FROM policies;

-- Sample data verification
SELECT 'Sample Data Verification:' as info;
SELECT 'Insurers:' as table_name, name FROM insurers ORDER BY name LIMIT 3;
SELECT 'Policy Types:' as table_name, display_name FROM policy_types ORDER BY display_name LIMIT 3;
SELECT 'Clients:' as table_name, COALESCE(first_name || ' ' || last_name, entity_name) as name FROM clients ORDER BY created_at DESC LIMIT 3;
SELECT 'Policies:' as table_name, policy_number FROM policies ORDER BY created_at DESC LIMIT 3;

-- Clean up temporary tables
DROP TABLE temp_insurers;
DROP TABLE temp_commercial_types;
DROP TABLE temp_personal_types;
DROP TABLE temp_claim_types;
DROP TABLE temp_clients;
DROP TABLE temp_addresses;
DROP TABLE temp_policies;
