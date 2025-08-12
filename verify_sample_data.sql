-- =====================================================
-- VERIFY SAMPLE DATA
-- =====================================================
-- This script verifies that sample data was added correctly
-- =====================================================

-- Check table counts
SELECT '=== TABLE COUNTS ===' as info;

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
SELECT '=== SAMPLE INSURERS ===' as info;
SELECT name FROM insurers ORDER BY name LIMIT 5;

SELECT '=== SAMPLE POLICY TYPES ===' as info;
SELECT display_name, slug FROM policy_types ORDER BY display_name LIMIT 5;

SELECT '=== SAMPLE PRODUCTS ===' as info;
SELECT p.name as product_name, i.name as insurer_name 
FROM products p 
JOIN insurers i ON p.insurer_id = i.id 
ORDER BY p.name LIMIT 5;

SELECT '=== SAMPLE CLIENTS ===' as info;
SELECT 
    client_type,
    COALESCE(first_name || ' ' || last_name, entity_name) as name,
    status
FROM clients
ORDER BY created_at DESC
LIMIT 5;

SELECT '=== SAMPLE POLICIES ===' as info;
SELECT 
    p.policy_number,
    COALESCE(c.first_name || ' ' || c.last_name, c.entity_name) as client_name,
    i.name as insurer,
    pr.name as product,
    p.status,
    p.renewal_flag
FROM policies p
JOIN clients c ON p.client_id = c.id
JOIN insurers i ON p.insurer_id = i.id
JOIN products pr ON p.product_id = pr.id
ORDER BY p.created_at DESC
LIMIT 5;
