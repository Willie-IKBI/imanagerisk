-- =====================================================
-- VERIFY SAMPLE DATA
-- =====================================================
-- This migration verifies that sample data was added correctly
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

SELECT '=== SAMPLE CLIENTS ===' as info;
SELECT 
    client_type,
    COALESCE(first_name || ' ' || last_name, entity_name) as name,
    status
FROM clients
ORDER BY created_at DESC
LIMIT 5;
