-- Check current data in key tables
SELECT 'insurers' as table_name, COUNT(*) as count FROM insurers 
UNION ALL 
SELECT 'policy_types', COUNT(*) FROM policy_types 
UNION ALL 
SELECT 'clients', COUNT(*) FROM clients 
UNION ALL 
SELECT 'addresses', COUNT(*) FROM addresses;
