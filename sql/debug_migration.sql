-- =====================================================
-- DEBUG MIGRATION - CHECK WHAT HAPPENED
-- =====================================================

-- Check if storage bucket exists
SELECT '=== STORAGE BUCKET CHECK ===' as info;
SELECT * FROM storage.buckets WHERE id = 'migration-data';

-- Check if any data exists in tables
SELECT '=== CURRENT TABLE COUNTS ===' as info;
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
SELECT 'policies', COUNT(*) FROM policies;

-- Check if any temporary tables still exist (they shouldn't)
SELECT '=== TEMP TABLES CHECK ===' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'pg_temp' 
  AND table_name LIKE 'temp_%';

-- Check storage objects (if any)
SELECT '=== STORAGE OBJECTS ===' as info;
SELECT * FROM storage.objects WHERE bucket_id = 'migration-data';
