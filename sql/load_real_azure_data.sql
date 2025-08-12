-- =====================================================
-- LOAD REAL AZURE DATA SCRIPT
-- =====================================================
-- This script loads your actual Azure CSV data
-- =====================================================

-- Step 1: Clean up any existing test data
SELECT '=== CLEANING EXISTING DATA ===' as info;

-- Remove all existing data (in reverse dependency order)
DELETE FROM policies;
DELETE FROM addresses;
DELETE FROM clients;
DELETE FROM products;
DELETE FROM claim_types;
DELETE FROM policy_types;
DELETE FROM insurers;

-- Step 2: Load Real Insurance Companies
SELECT '=== LOADING INSURANCE COMPANIES ===' as info;

-- Create temporary table for insurance companies
CREATE TEMP TABLE temp_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- IMPORTANT: Replace this with your actual data from dbo.insurance_company_dim.csv
-- Copy the data from your CSV file and paste it here
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.insurance_company_dim.csv
    -- Example format:
    -- (1, 'Santam', '2024-01-15'),
    -- (2, 'Hollard', '2024-01-15'),
    -- (3, 'CIA', '2024-01-15')
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

-- Step 3: Load Real Policy Types
SELECT '=== LOADING POLICY TYPES ===' as info;

-- Create temporary table for commercial policy types
CREATE TEMP TABLE temp_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- IMPORTANT: Replace this with your actual data from dbo.commercial_insurance_type_dim.csv
INSERT INTO temp_commercial_types (insurance_type_key, insurance_type, category, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.commercial_insurance_type_dim.csv
    -- Example format:
    -- (1, 'Commercial Property', 'Commercial', '2024-01-15'),
    -- (2, 'Public Liability', 'Commercial', '2024-01-15')
    -- Add all your real commercial types here
;

-- Create temporary table for personal policy types
CREATE TEMP TABLE temp_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- IMPORTANT: Replace this with your actual data from dbo.personal_insurance_type_dim.csv
INSERT INTO temp_personal_types (insurance_type_key, insurance_type, category, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.personal_insurance_type_dim.csv
    -- Example format:
    -- (1, 'Motor Vehicle', 'Personal', '2024-01-15'),
    -- (2, 'Home Insurance', 'Personal', '2024-01-15')
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

-- Step 4: Load Real Claim Types
SELECT '=== LOADING CLAIM TYPES ===' as info;

-- Create temporary table for claim types
CREATE TEMP TABLE temp_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

-- IMPORTANT: Replace this with your actual data from ft_claim_type.csv
INSERT INTO temp_claim_types (ft_claim_type_id, ft_claim_type, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM ft_claim_type.csv
    -- Example format:
    -- (1, 'Accident', '2024-01-15'),
    -- (2, 'Theft', '2024-01-15')
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

-- Step 5: Create Products
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

-- Step 6: Load Real Clients
SELECT '=== LOADING CLIENTS ===' as info;

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

-- IMPORTANT: Replace this with your actual data from dbo.client_dim.csv
INSERT INTO temp_clients (
    Client_ID, Client_Name, Client_Surname, Client_ID_Nr, Client_Type,
    Company_Name, Body_Corporate_Name, Insurance_Status, Comments,
    Email, Cell_Number, Alt_Email, Alt_Number, Trustee_Name, Trustee_Contact_Number, extraction_date
)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.client_dim.csv
    -- Example format:
    -- (1, 'John', 'Doe', '8001015009087', 'Personal', NULL, NULL, 'Active', 'Client comment', 'john@email.com', '0123456789', NULL, NULL, NULL, NULL, '2024-01-15')
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

-- Step 7: Load Real Addresses
SELECT '=== LOADING ADDRESSES ===' as info;

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

-- IMPORTANT: Replace this with your actual data from dbo.address_dim.csv
INSERT INTO temp_addresses (Address_ID_Key, Client_Id_Key, Street, Suburb, City, Province, Postal_Code, Unit_Number, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.address_dim.csv
    -- Example format:
    -- (1, 1, '123 Main Street', 'Suburb', 'City', 'Province', '1234', NULL, '2024-01-15')
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

-- Step 8: Load Real Policies
SELECT '=== LOADING POLICIES ===' as info;

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

-- IMPORTANT: Replace this with your actual data from dbo.policy_dim.csv
INSERT INTO temp_policies (
    Insurance_ID_Key, Insurance_Client_Key, Insurar_ID, Insurance_Type_ID,
    Policy_Number, Premium, Excess, Ins_Start_Date, Ins_End_Date, Ins_Renewal_Date,
    Insurance_Type, Insurar_Name, extraction_date
)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.policy_dim.csv
    -- Example format:
    -- (1, 1, 1, 1, 'POL-001', 1000.00, 100.00, '2024-01-01', '2024-12-31', '2024-11-01', 'Motor Vehicle', 'Santam', '2024-01-15')
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

-- Step 9: Final Validation
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
