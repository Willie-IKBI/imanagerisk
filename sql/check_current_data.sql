-- =====================================================
-- CHECK CURRENT DATA STATUS
-- =====================================================

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

-- Show sample data from each table
SELECT '=== SAMPLE DATA ===' as info;

SELECT 'Insurers:' as table_name, name FROM insurers ORDER BY name LIMIT 10;
SELECT 'Policy Types:' as table_name, display_name FROM policy_types ORDER BY display_name LIMIT 10;
SELECT 'Claim Types:' as table_name, name FROM claim_types ORDER BY name LIMIT 10;
SELECT 'Clients:' as table_name, COALESCE(first_name || ' ' || last_name, entity_name) as name, id_number FROM clients ORDER BY created_at DESC LIMIT 10;
SELECT 'Addresses:' as table_name, line1, city FROM addresses ORDER BY created_at DESC LIMIT 10;
SELECT 'Policies:' as table_name, policy_number FROM policies ORDER BY created_at DESC LIMIT 10;
