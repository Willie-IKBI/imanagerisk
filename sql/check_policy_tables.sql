-- =====================================================
-- POLICY TABLE ANALYSIS SCRIPT
-- =====================================================
-- Run this to determine which policy table to use for migration
-- =====================================================

-- 1. Compare record counts
SELECT '=== POLICY TABLE COMPARISON ===' as info;
SELECT 'policy_dim' as table_name, COUNT(*) as record_count
FROM dbo.policy_dim
UNION ALL
SELECT 'policy_dim_new', COUNT(*)
FROM dbo.policy_dim_new;

-- 2. Check for recent data (if there are date columns)
-- Note: Adjust column names based on your actual schema
SELECT '=== RECENT DATA CHECK ===' as info;

-- Check if policy_dim has recent data
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policy_dim' AND COLUMN_NAME LIKE '%date%')
BEGIN
    SELECT 'policy_dim recent records:' as info;
    SELECT TOP 5 * FROM dbo.policy_dim 
    ORDER BY (SELECT MAX(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policy_dim' AND COLUMN_NAME LIKE '%date%') DESC;
END

-- Check if policy_dim_new has recent data
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policy_dim_new' AND COLUMN_NAME LIKE '%date%')
BEGIN
    SELECT 'policy_dim_new recent records:' as info;
    SELECT TOP 5 * FROM dbo.policy_dim_new 
    ORDER BY (SELECT MAX(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'policy_dim_new' AND COLUMN_NAME LIKE '%date%') DESC;
END

-- 3. Sample data from both tables
SELECT '=== SAMPLE DATA FROM policy_dim ===' as info;
SELECT TOP 3 * FROM dbo.policy_dim;

SELECT '=== SAMPLE DATA FROM policy_dim_new ===' as info;
SELECT TOP 3 * FROM dbo.policy_dim_new;

-- 4. Column comparison
SELECT '=== COLUMN COMPARISON ===' as info;
SELECT 'policy_dim columns:' as info;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'policy_dim' 
ORDER BY ORDINAL_POSITION;

SELECT 'policy_dim_new columns:' as info;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'policy_dim_new' 
ORDER BY ORDINAL_POSITION;
