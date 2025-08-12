-- =====================================================
-- COMPLETE AZURE TO SUPABASE MIGRATION SCRIPT
-- =====================================================
-- This script transforms and loads all Azure data into Supabase
-- Run this in your Supabase SQL editor or via Supabase CLI
-- =====================================================

-- BEGIN TRANSACTION;
-- Note: Uncomment the transaction if you want to rollback on errors

-- =====================================================
-- STEP 1: LOAD INSURERS (Reference Table)
-- =====================================================

-- Create temporary table for insurers
CREATE TEMP TABLE temp_azure_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Load insurers data (replace with your actual CSV import method)
-- COPY temp_azure_insurers FROM 'azure_export/azure_insurance_companies.csv' WITH (FORMAT csv, HEADER true);

-- Insert into insurers table
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    Insurar_Name as name,
    '{}'::jsonb as contact_info,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_insurers
WHERE Insurar_Name IS NOT NULL AND Insurar_Name != ''
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- STEP 2: LOAD POLICY TYPES (Reference Table)
-- =====================================================

-- Create temporary tables for policy types
CREATE TEMP TABLE temp_azure_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

CREATE TEMP TABLE temp_azure_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Load policy types data (replace with your actual CSV import method)
-- COPY temp_azure_commercial_types FROM 'azure_export/azure_commercial_insurance_types.csv' WITH (FORMAT csv, HEADER true);
-- COPY temp_azure_personal_types FROM 'azure_export/azure_personal_insurance_types.csv' WITH (FORMAT csv, HEADER true);

-- Insert commercial policy types
INSERT INTO policy_types (id, display_name, category, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    'commercial' as category,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_commercial_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Insert personal policy types
INSERT INTO policy_types (id, display_name, category, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    'personal' as category,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_personal_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- STEP 3: LOAD CLAIM TYPES (Reference Table)
-- =====================================================

-- Create temporary table for claim types
CREATE TEMP TABLE temp_azure_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

-- Load claim types data (replace with your actual CSV import method)
-- COPY temp_azure_claim_types FROM 'azure_export/azure_claim_types.csv' WITH (FORMAT csv, HEADER true);

-- Insert claim types
INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    ft_claim_type as name,
    'Migrated from Azure' as description,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_claim_types
WHERE ft_claim_type IS NOT NULL AND ft_claim_type != ''
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- STEP 4: LOAD CLIENTS (Core Table)
-- =====================================================

-- Create temporary table for clients
CREATE TEMP TABLE temp_azure_clients (
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

-- Load clients data (replace with your actual CSV import method)
-- COPY temp_azure_clients FROM 'azure_export/azure_clients.csv' WITH (FORMAT csv, HEADER true);

-- Insert clients
INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    CASE 
        WHEN LOWER(Client_Type) = 'personal' THEN 'personal'
        WHEN LOWER(Client_Type) = 'commercial' THEN 'commercial'
        ELSE 'personal'
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
        WHEN Insurance_Status IS NULL OR Insurance_Status = '' THEN 'active'
        ELSE LOWER(Insurance_Status)
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_clients
WHERE Client_ID IS NOT NULL
  AND (Client_Name IS NOT NULL OR Client_Surname IS NOT NULL)
  AND Client_ID_Nr IS NOT NULL
ON CONFLICT (id_number) DO NOTHING;

-- Create client contacts
INSERT INTO client_contacts (id, client_id, name, email, phone, role, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    c.id as client_id,
    COALESCE(temp.Trustee_Name, 'Primary Contact') as name,
    COALESCE(temp.Email, temp.Alt_Email) as email,
    COALESCE(temp.Cell_Number, temp.Alt_Number, temp.Trustee_Contact_Number) as phone,
    CASE 
        WHEN temp.Trustee_Name IS NOT NULL THEN 'trustee'
        ELSE 'primary'
    END as role,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_clients temp
JOIN clients c ON c.id_number = temp.Client_ID_Nr
WHERE (temp.Email IS NOT NULL OR temp.Cell_Number IS NOT NULL OR temp.Trustee_Name IS NOT NULL);

-- =====================================================
-- STEP 5: LOAD ADDRESSES (Core Table)
-- =====================================================

-- Create temporary table for addresses
CREATE TEMP TABLE temp_azure_addresses (
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

-- Load addresses data (replace with your actual CSV import method)
-- COPY temp_azure_addresses FROM 'azure_export/azure_addresses.csv' WITH (FORMAT csv, HEADER true);

-- Insert addresses
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
FROM temp_azure_addresses temp
JOIN clients c ON c.id = (
    SELECT id FROM clients 
    WHERE id_number = (
        SELECT Client_ID_Nr FROM temp_azure_clients 
        WHERE Client_ID = temp.Client_Id_Key
    )
)
WHERE temp.Client_Id_Key IS NOT NULL
  AND (temp.City IS NOT NULL OR temp.Province IS NOT NULL);

-- =====================================================
-- STEP 6: LOAD POLICIES (Transaction Table)
-- =====================================================

-- Create temporary table for policies
CREATE TEMP TABLE temp_azure_policies (
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

-- Load policies data (replace with your actual CSV import method)
-- COPY temp_azure_policies FROM 'azure_export/azure_policies.csv' WITH (FORMAT csv, HEADER true);

-- Insert policies
INSERT INTO policies (
    id, 
    client_id, 
    insurer_id, 
    policy_type_id,
    policy_number, 
    premium, 
    excess, 
    start_date, 
    end_date, 
    renewal_date,
    coverage_details,
    status,
    created_at, 
    updated_at
)
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
        WHEN temp.Ins_End_Date IS NULL OR temp.Ins_End_Date >= CURRENT_DATE THEN 'active'
        ELSE 'expired'
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_policies temp
JOIN clients c ON c.id = (
    SELECT id FROM clients 
    WHERE id_number = (
        SELECT Client_ID_Nr FROM temp_azure_clients 
        WHERE Client_ID = temp.Insurance_Client_Key
    )
)
JOIN insurers i ON i.name = temp.Insurar_Name
LEFT JOIN policy_types pt ON pt.display_name = temp.Insurance_Type
WHERE temp.Insurance_ID_Key IS NOT NULL
  AND temp.Policy_Number IS NOT NULL
  AND temp.Premium IS NOT NULL;

-- =====================================================
-- STEP 7: VALIDATION AND CLEANUP
-- =====================================================

-- Final validation report
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
SELECT 'client_contacts', COUNT(*) FROM client_contacts
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'policies', COUNT(*) FROM policies;

-- Sample data verification
SELECT 'Sample Clients:' as info;
SELECT client_type, first_name, last_name, entity_name, status 
FROM clients 
ORDER BY created_at DESC 
LIMIT 5;

SELECT 'Sample Policies:' as info;
SELECT p.policy_number, c.first_name || ' ' || c.last_name as client_name, 
       i.name as insurer, p.premium, p.status
FROM policies p
JOIN clients c ON p.client_id = c.id
JOIN insurers i ON p.insurer_id = i.id
ORDER BY p.created_at DESC
LIMIT 5;

-- Clean up temporary tables
DROP TABLE temp_azure_insurers;
DROP TABLE temp_azure_commercial_types;
DROP TABLE temp_azure_personal_types;
DROP TABLE temp_azure_claim_types;
DROP TABLE temp_azure_clients;
DROP TABLE temp_azure_addresses;
DROP TABLE temp_azure_policies;

-- COMMIT;
-- Note: Uncomment if using transaction
