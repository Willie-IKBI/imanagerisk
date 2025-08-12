-- Migration Status Report
-- Check current state of all tables

-- 1. Table Record Counts
SELECT '=== TABLE RECORD COUNTS ===' as info;
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
SELECT 'client_contacts', COUNT(*) FROM client_contacts
UNION ALL
SELECT 'policies', COUNT(*) FROM policies
UNION ALL
SELECT 'products', COUNT(*) FROM products;

-- 2. Sample Data from Key Tables
SELECT '=== INSURERS ===' as info;
SELECT name, contact_info FROM insurers ORDER BY name LIMIT 10;

SELECT '=== POLICY TYPES ===' as info;
SELECT display_name, slug FROM policy_types ORDER BY display_name LIMIT 10;

SELECT '=== CLAIM TYPES ===' as info;
SELECT name, description FROM claim_types ORDER BY name LIMIT 10;

SELECT '=== CLIENTS ===' as info;
SELECT client_type, first_name, last_name, entity_name, status FROM clients ORDER BY created_at DESC LIMIT 10;

SELECT '=== ADDRESSES ===' as info;
SELECT c.first_name || ' ' || c.last_name as client_name, a.line1, a.city, a.province FROM addresses a 
JOIN clients c ON a.client_id = c.id ORDER BY a.created_at DESC LIMIT 10;

SELECT '=== CLIENT CONTACTS ===' as info;
SELECT c.first_name || ' ' || c.last_name as client_name, cc.name, cc.email, cc.phone, cc.role 
FROM client_contacts cc 
JOIN clients c ON cc.client_id = c.id ORDER BY cc.created_at DESC LIMIT 10;

-- 3. Migration Readiness Check
SELECT '=== MIGRATION READINESS ===' as info;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM insurers) > 0 THEN '✅ Insurance companies table has data'
        ELSE '❌ Insurance companies table is empty'
    END as status
UNION ALL
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM policy_types) > 0 THEN '✅ Policy types table has data'
        ELSE '❌ Policy types table is empty'
    END
UNION ALL
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM claim_types) > 0 THEN '✅ Claim types table has data'
        ELSE '❌ Claim types table is empty'
    END
UNION ALL
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM clients) > 0 THEN '✅ Clients table has data'
        ELSE '❌ Clients table is empty'
    END;
