-- Check current data in key tables
SELECT 'insurers' as table_name, COUNT(*) as count FROM insurers 
UNION ALL 
SELECT 'policy_types', COUNT(*) FROM policy_types 
UNION ALL 
SELECT 'clients', COUNT(*) FROM clients 
UNION ALL 
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'client_contacts', COUNT(*) FROM client_contacts;

-- Show sample data
SELECT 'INSURERS:' as info;
SELECT name, contact_info FROM insurers LIMIT 5;

SELECT 'POLICY TYPES:' as info;
SELECT display_name, slug FROM policy_types LIMIT 5;

SELECT 'CLIENTS:' as info;
SELECT client_type, first_name, last_name, entity_name FROM clients LIMIT 5;
