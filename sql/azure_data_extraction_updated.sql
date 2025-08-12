-- =====================================================
-- UPDATED AZURE DATA EXTRACTION SCRIPT FOR IMR MIGRATION
-- =====================================================
-- Based on actual table names found in your Azure database
-- =====================================================

-- 1. INSURANCE COMPANIES EXTRACTION
-- =====================================================
PRINT '=== EXTRACTING INSURANCE COMPANIES ===';
SELECT 
    Insurar_ID_Key,
    Insurar_Name,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.insurance_company_dim
WHERE Insurar_Name IS NOT NULL
ORDER BY Insurar_ID_Key;

-- 2. COMMERCIAL INSURANCE TYPES EXTRACTION
-- =====================================================
PRINT '=== EXTRACTING COMMERCIAL INSURANCE TYPES ===';
SELECT 
    insurance_type_key,
    insurance_type,
    'commercial' as category,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.commercial_insurance_type_dim
WHERE insurance_type IS NOT NULL
ORDER BY insurance_type_key;

-- 3. PERSONAL INSURANCE TYPES EXTRACTION (UPDATED TABLE NAME)
-- =====================================================
PRINT '=== EXTRACTING PERSONAL INSURANCE TYPES ===';
SELECT 
    insurance_type_key,
    insurance_type,
    'personal' as category,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.personal_insurance_type_dim  -- Updated from _personal_insurance_type_dim
WHERE insurance_type IS NOT NULL
ORDER BY insurance_type_key;

-- 4. CLAIM TYPES EXTRACTION
-- =====================================================
PRINT '=== EXTRACTING CLAIM TYPES ===';
SELECT 
    ft_claim_type_id,
    ft_claim_type,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.ft_claim_type_dim
WHERE ft_claim_type IS NOT NULL
ORDER BY ft_claim_type_id;

-- 5. CLIENTS EXTRACTION
-- =====================================================
PRINT '=== EXTRACTING CLIENTS ===';
SELECT 
    Client_ID,
    Client_Name,
    Client_Surname,
    Client_ID_Nr,
    Client_Type,
    Company_Name,
    Body_Corporate_Name,
    Insurance_Status,
    Comments,
    Email,
    Cell_Number,
    Alt_Email,
    Alt_Number,
    Trustee_Name,
    Trustee_Contact_Number,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.client_dim
WHERE Client_ID IS NOT NULL
ORDER BY Client_ID;

-- 6. ADDRESSES EXTRACTION
-- =====================================================
PRINT '=== EXTRACTING ADDRESSES ===';
SELECT 
    Address_ID_Key,
    Client_Id_Key,
    Street,
    Suburb,
    City,
    Province,
    Postal_Code,
    Unit_Number,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.address_dim
WHERE Client_Id_Key IS NOT NULL
ORDER BY Client_Id_Key, Address_ID_Key;

-- 7. INSURANCE POLICIES EXTRACTION (UPDATED TABLE NAME)
-- =====================================================
PRINT '=== EXTRACTING INSURANCE POLICIES ===';
-- Using policy_dim (you also have policy_dim_new - check which one has current data)
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
    Ins_Renewal_Date,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.policy_dim  -- Updated from [Insurance_Policy_Table]
WHERE Insurance_ID_Key IS NOT NULL
ORDER BY Insurance_ID_Key;

-- 8. ALTERNATIVE POLICY TABLE (policy_dim_new)
-- =====================================================
PRINT '=== CHECKING policy_dim_new ===';
SELECT 
    'policy_dim_new' as table_name,
    COUNT(*) as record_count,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.policy_dim_new;

-- =====================================================
-- DATA QUALITY CHECKS
-- =====================================================
PRINT '=== DATA QUALITY SUMMARY ===';

-- Count records in each table
SELECT 'insurance_company_dim' as table_name, COUNT(*) as record_count
FROM dbo.insurance_company_dim
UNION ALL
SELECT 'commercial_insurance_type_dim', COUNT(*)
FROM dbo.commercial_insurance_type_dim
UNION ALL
SELECT 'personal_insurance_type_dim', COUNT(*)
FROM dbo.personal_insurance_type_dim
UNION ALL
SELECT 'ft_claim_type_dim', COUNT(*)
FROM dbo.ft_claim_type_dim
UNION ALL
SELECT 'client_dim', COUNT(*)
FROM dbo.client_dim
UNION ALL
SELECT 'address_dim', COUNT(*)
FROM dbo.address_dim
UNION ALL
SELECT 'policy_dim', COUNT(*)
FROM dbo.policy_dim
UNION ALL
SELECT 'policy_dim_new', COUNT(*)
FROM dbo.policy_dim_new;

-- Check for null values in key fields
PRINT '=== NULL VALUE CHECKS ===';
SELECT 'clients_without_id' as issue, COUNT(*) as count
FROM dbo.client_dim
WHERE Client_ID IS NULL
UNION ALL
SELECT 'clients_without_name', COUNT(*)
FROM dbo.client_dim
WHERE Client_Name IS NULL OR Client_Surname IS NULL
UNION ALL
SELECT 'addresses_without_client', COUNT(*)
FROM dbo.address_dim
WHERE Client_Id_Key IS NULL
UNION ALL
SELECT 'policies_without_client', COUNT(*)
FROM dbo.policy_dim
WHERE Insurance_Client_Key IS NULL;

-- Check for duplicate ID numbers
PRINT '=== DUPLICATE CHECKS ===';
SELECT 'duplicate_client_ids', COUNT(*) as count
FROM (
    SELECT Client_ID_Nr, COUNT(*) as cnt
    FROM dbo.client_dim
    WHERE Client_ID_Nr IS NOT NULL
    GROUP BY Client_ID_Nr
    HAVING COUNT(*) > 1
) duplicates;

-- =====================================================
-- EXPORT INSTRUCTIONS
-- =====================================================
PRINT '=== EXPORT INSTRUCTIONS ===';
PRINT '1. Run each SELECT statement separately';
PRINT '2. Export results to CSV files with these names:';
PRINT '   - azure_insurance_companies.csv';
PRINT '   - azure_commercial_insurance_types.csv';
PRINT '   - azure_personal_insurance_types.csv';
PRINT '   - azure_claim_types.csv';
PRINT '   - azure_clients.csv';
PRINT '   - azure_addresses.csv';
PRINT '   - azure_policies.csv';
PRINT '3. Save all CSV files in a folder named "azure_export"';
PRINT '4. Ensure UTF-8 encoding for proper character handling';
PRINT '5. Check the data quality summary above before proceeding';
PRINT '';
PRINT 'NOTE: You have both policy_dim and policy_dim_new tables.';
PRINT 'Check which one contains the current/active policy data.';
