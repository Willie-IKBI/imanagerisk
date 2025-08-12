-- =====================================================
-- CHECK CURRENT MIGRATION STATUS
-- =====================================================
-- This script checks the current state of data in Supabase
-- =====================================================

-- Check current table counts
SELECT '=== CURRENT TABLE COUNTS ===' as info;

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

-- Check sample data
SELECT '=== SAMPLE DATA CHECK ===' as info;

SELECT 'Sample Insurers:' as info;
SELECT name FROM insurers ORDER BY name LIMIT 5;

SELECT 'Sample Policy Types:' as info;
SELECT display_name, slug FROM policy_types ORDER BY display_name LIMIT 5;

SELECT 'Sample Products:' as info;
SELECT p.name as product_name, i.name as insurer_name 
FROM products p 
JOIN insurers i ON p.insurer_id = i.id 
ORDER BY p.name LIMIT 5;

SELECT 'Sample Clients:' as info;
SELECT 
    client_type,
    COALESCE(first_name || ' ' || last_name, entity_name) as name,
    status
FROM clients
ORDER BY created_at DESC
LIMIT 5;

SELECT 'Sample Policies:' as info;
SELECT 
    p.policy_number,
    COALESCE(c.first_name || ' ' || c.last_name, c.entity_name) as client_name,
    i.name as insurer,
    p.status
FROM policies p
JOIN clients c ON p.client_id = c.id
JOIN insurers i ON p.insurer_id = i.id
ORDER BY p.created_at DESC
LIMIT 5;

-- Check for any data issues
SELECT '=== DATA QUALITY CHECK ===' as info;

SELECT 'Clients without addresses:' as info;
SELECT COUNT(*) as count
FROM clients c
LEFT JOIN addresses a ON c.id = a.client_id
WHERE a.id IS NULL;

SELECT 'Policies without products:' as info;
SELECT COUNT(*) as count
FROM policies p
LEFT JOIN products pr ON p.product_id = pr.id
WHERE pr.id IS NULL;

SELECT 'Products without insurers:' as info;
SELECT COUNT(*) as count
FROM products p
LEFT JOIN insurers i ON p.insurer_id = i.id
WHERE i.id IS NULL;
