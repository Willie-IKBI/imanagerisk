-- =====================================================
-- REAL DATA MIGRATION SCRIPT
-- =====================================================
-- This script removes test data and loads real Azure data
-- =====================================================

-- Step 1: Check current data status
SELECT '=== CURRENT DATA STATUS ===' as info;

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

-- Step 2: Clean up test data (in reverse dependency order)
SELECT '=== CLEANING TEST DATA ===' as info;

-- Remove test policies first (they reference other tables)
DELETE FROM policies WHERE policy_number LIKE 'POL-MIG-%' OR policy_number LIKE 'POL-001%' OR policy_number LIKE 'POL-002%';

-- Remove test addresses
DELETE FROM addresses WHERE line1 IN ('123 Main Street', '456 Oak Avenue');

-- Remove test clients
DELETE FROM clients WHERE id_number IN (
    '8001015009087', '8502155009088', '1234567890123', '9876543210987',
    '9001015009089', '9203155009090', '1111111111111', '2222222222222'
);

-- Remove test products
DELETE FROM products WHERE name LIKE 'Product: %';

-- Remove test claim types
DELETE FROM claim_types WHERE name IN (
    'Accident', 'Theft', 'Natural Disaster', 'Medical', 'Property Damage',
    'Fire', 'Flood', 'Storm', 'Vandalism', 'Liability'
);

-- Remove test policy types
DELETE FROM policy_types WHERE slug IN (
    'motor-vehicle-insurance', 'home-insurance', 'life-insurance', 'business-insurance',
    'medical-insurance', 'commercial-property', 'public-liability', 'professional-indemnity',
    'workers-compensation', 'directors-officers'
);

-- Remove test insurers
DELETE FROM insurers WHERE name IN (
    'Santam', 'Hollard', 'CIA', 'Old Mutual', 'Discovery', 'OUTsurance',
    'MiWay', 'Budget', 'Dial Direct', 'King Price'
);

-- Step 3: Load Real Insurance Companies from Azure CSV
SELECT '=== LOADING REAL INSURANCE COMPANIES ===' as info;

-- Create temporary table for insurance companies
CREATE TEMP TABLE temp_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Load data from your CSV (you'll need to replace this with actual data)
-- For now, I'll show the structure - you'll need to add your real data here
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    -- Replace these with your actual data from dbo.insurance_company_dim.csv
    (1, 'Your Real Insurer 1', '2024-01-01'),
    (2, 'Your Real Insurer 2', '2024-01-01')
    -- Add all your real insurers here
;

-- Insert real insurers
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(Insurar_Name) as name,
    '{}'::jsonb as contact_info,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_insurers
WHERE Insurar_Name IS NOT NULL AND TRIM(Insurar_Name) != '';

-- Step 4: Load Real Policy Types from Azure CSVs
SELECT '=== LOADING REAL POLICY TYPES ===' as info;

-- Create temporary table for commercial policy types
CREATE TEMP TABLE temp_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Load commercial policy types (replace with your real data)
INSERT INTO temp_commercial_types (insurance_type_key, insurance_type, category, extraction_date)
VALUES 
    -- Replace with your actual data from dbo.commercial_insurance_type_dim.csv
    (1, 'Your Commercial Type 1', 'Commercial', '2024-01-01'),
    (2, 'Your Commercial Type 2', 'Commercial', '2024-01-01')
    -- Add all your real commercial types here
;

-- Create temporary table for personal policy types
CREATE TEMP TABLE temp_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Load personal policy types (replace with your real data)
INSERT INTO temp_personal_types (insurance_type_key, insurance_type, category, extraction_date)
VALUES 
    -- Replace with your actual data from dbo.personal_insurance_type_dim.csv
    (1, 'Your Personal Type 1', 'Personal', '2024-01-01'),
    (2, 'Your Personal Type 2', 'Personal', '2024-01-01')
    -- Add all your real personal types here
;

-- Insert all policy types
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(insurance_type) as display_name,
    LOWER(REPLACE(REPLACE(TRIM(insurance_type), ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM (
    SELECT insurance_type FROM temp_commercial_types
    UNION
    SELECT insurance_type FROM temp_personal_types
) combined_types
WHERE insurance_type IS NOT NULL AND TRIM(insurance_type) != '';

-- Step 5: Load Real Claim Types from Azure CSV
SELECT '=== LOADING REAL CLAIM TYPES ===' as info;

-- Create temporary table for claim types
CREATE TEMP TABLE temp_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

-- Load claim types (replace with your real data)
INSERT INTO temp_claim_types (ft_claim_type_id, ft_claim_type, extraction_date)
VALUES 
    -- Replace with your actual data from ft_claim_type.csv
    (1, 'Your Real Claim Type 1', '2024-01-01'),
    (2, 'Your Real Claim Type 2', '2024-01-01')
    -- Add all your real claim types here
;

-- Insert real claim types
INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT
    gen_random_uuid() as id,
    TRIM(ft_claim_type) as name,
    'Migrated from Azure' as description,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_claim_types
WHERE ft_claim_type IS NOT NULL AND TRIM(ft_claim_type) != '';

-- Step 6: Create Products (link insurers to policy types)
SELECT '=== CREATING PRODUCTS ===' as info;

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
WHERE i.name IN (SELECT DISTINCT Insurar_Name FROM temp_insurers WHERE Insurar_Name IS NOT NULL);

-- Step 7: Load Real Clients from Azure CSV
SELECT '=== LOADING REAL CLIENTS ===' as info;

-- Create temporary table for clients
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

-- Load clients (replace with your real data)
INSERT INTO temp_clients (
    Client_ID, Client_Name, Client_Surname, Client_ID_Nr, Client_Type,
    Company_Name, Body_Corporate_Name, Insurance_Status, Comments,
    Email, Cell_Number, Alt_Email, Alt_Number, Trustee_Name, Trustee_Contact_Number, extraction_date
)
VALUES 
    -- Replace with your actual data from dbo.client_dim.csv
    (1, 'Real Client First', 'Real Client Last', '1234567890123', 'Personal', 
     NULL, NULL, 'Active', 'Real client comment', 'client@email.com', '0123456789',
     NULL, NULL, NULL, NULL, '2024-01-01')
    -- Add all your real clients here
;

-- Insert real clients
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

-- Step 8: Load Real Addresses from Azure CSV
SELECT '=== LOADING REAL ADDRESSES ===' as info;

-- Create temporary table for addresses
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

-- Load addresses (replace with your real data)
INSERT INTO temp_addresses (Address_ID_Key, Client_Id_Key, Street, Suburb, City, Province, Postal_Code, Unit_Number, extraction_date)
VALUES 
    -- Replace with your actual data from dbo.address_dim.csv
    (1, 1, 'Real Street Address', 'Real Suburb', 'Real City', 'Real Province', '1234', NULL, '2024-01-01')
    -- Add all your real addresses here
;

-- Insert real addresses
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

-- Step 9: Load Real Policies from Azure CSV
SELECT '=== LOADING REAL POLICIES ===' as info;

-- Create temporary table for policies
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

-- Load policies (replace with your real data)
INSERT INTO temp_policies (
    Insurance_ID_Key, Insurance_Client_Key, Insurar_ID, Insurance_Type_ID,
    Policy_Number, Premium, Excess, Ins_Start_Date, Ins_End_Date, Ins_Renewal_Date,
    Insurance_Type, Insurar_Name, extraction_date
)
VALUES 
    -- Replace with your actual data from dbo.policy_dim.csv
    (1, 1, 1, 1, 'REAL-POL-001', 1000.00, 100.00, '2024-01-01', '2024-12-31', '2024-11-01',
     'Your Insurance Type', 'Your Real Insurer', '2024-01-01')
    -- Add all your real policies here
;

-- Insert real policies
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

-- Step 10: Final Validation
SELECT '=== REAL DATA MIGRATION COMPLETE ===' as info;

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
SELECT 'Insurers:' as table_name, name FROM insurers ORDER BY name LIMIT 5;
SELECT 'Policy Types:' as table_name, display_name FROM policy_types ORDER BY display_name LIMIT 5;
SELECT 'Clients:' as table_name, COALESCE(first_name || ' ' || last_name, entity_name) as name FROM clients ORDER BY created_at DESC LIMIT 5;
SELECT 'Policies:' as table_name, policy_number FROM policies ORDER BY created_at DESC LIMIT 5;

-- Clean up temporary tables
DROP TABLE temp_insurers;
DROP TABLE temp_commercial_types;
DROP TABLE temp_personal_types;
DROP TABLE temp_claim_types;
DROP TABLE temp_clients;
DROP TABLE temp_addresses;
DROP TABLE temp_policies;
