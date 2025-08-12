-- =====================================================
-- AZURE TABLE VERIFICATION SCRIPT
-- =====================================================
-- Run this first to verify table names in your Azure database
-- =====================================================

-- 1. List all tables in the database
SELECT '=== ALL TABLES IN DATABASE ===' as info;
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    'dbo.' + TABLE_NAME as full_name
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 2. Check for specific tables we need
SELECT '=== CHECKING REQUIRED TABLES ===' as info;

-- Insurance companies
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'insurance_company_dim') 
        THEN '✅ insurance_company_dim found'
        ELSE '❌ insurance_company_dim NOT found'
    END as status
UNION ALL
-- Commercial insurance types
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'commercial_insurance_type_dim') 
        THEN '✅ commercial_insurance_type_dim found'
        ELSE '❌ commercial_insurance_type_dim NOT found'
    END
UNION ALL
-- Personal insurance types (note: might not have dbo prefix)
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '_personal_insurance_type_dim') 
        THEN '✅ _personal_insurance_type_dim found'
        ELSE '❌ _personal_insurance_type_dim NOT found'
    END
UNION ALL
-- Claim types
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ft_claim_type_dim') 
        THEN '✅ ft_claim_type_dim found'
        ELSE '❌ ft_claim_type_dim NOT found'
    END
UNION ALL
-- Clients
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'client_dim') 
        THEN '✅ client_dim found'
        ELSE '❌ client_dim NOT found'
    END
UNION ALL
-- Addresses
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'address_dim') 
        THEN '✅ address_dim found'
        ELSE '❌ address_dim NOT found'
    END;

-- 3. Look for policy-related tables
SELECT '=== LOOKING FOR POLICY TABLES ===' as info;
SELECT TABLE_NAME, TABLE_SCHEMA
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
AND (
    TABLE_NAME LIKE '%policy%' OR 
    TABLE_NAME LIKE '%insurance%' OR
    TABLE_NAME LIKE '%cover%'
)
ORDER BY TABLE_NAME;

-- 4. Check table row counts (if tables exist)
SELECT '=== TABLE ROW COUNTS ===' as info;
SELECT 'insurance_company_dim' as table_name, 
       CASE 
           WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'insurance_company_dim')
           THEN (SELECT COUNT(*) FROM dbo.insurance_company_dim)
           ELSE 0
       END as row_count
UNION ALL
SELECT 'commercial_insurance_type_dim', 
       CASE 
           WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'commercial_insurance_type_dim')
           THEN (SELECT COUNT(*) FROM dbo.commercial_insurance_type_dim)
           ELSE 0
       END
UNION ALL
SELECT 'client_dim', 
       CASE 
           WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'client_dim')
           THEN (SELECT COUNT(*) FROM dbo.client_dim)
           ELSE 0
       END
UNION ALL
SELECT 'address_dim', 
       CASE 
           WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'address_dim')
           THEN (SELECT COUNT(*) FROM dbo.address_dim)
           ELSE 0
       END;

-- 5. Sample data from key tables (if they exist)
SELECT '=== SAMPLE DATA CHECK ===' as info;

-- Sample from insurance companies
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'insurance_company_dim')
BEGIN
    SELECT 'insurance_company_dim sample:' as info;
    SELECT TOP 3 Insurar_ID_Key, Insurar_Name FROM dbo.insurance_company_dim;
END

-- Sample from clients
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'client_dim')
BEGIN
    SELECT 'client_dim sample:' as info;
    SELECT TOP 3 Client_ID, Client_Name, Client_Surname, Client_Type FROM dbo.client_dim;
END
