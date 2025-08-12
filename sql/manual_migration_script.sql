-- =====================================================
-- MANUAL MIGRATION SCRIPT
-- =====================================================
-- This script manually inserts sample data
-- You can expand it with your actual CSV data
-- =====================================================

-- Step 1: Insert Insurance Companies (Sample Data)
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Santam', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Hollard', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'CIA', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Old Mutual', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Discovery', '{}'::jsonb, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 2: Insert Policy Types (Sample Data)
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Motor Vehicle Insurance', 'motor-vehicle-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Home Insurance', 'home-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Life Insurance', 'life-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Business Insurance', 'business-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Medical Insurance', 'medical-insurance', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 3: Insert Claim Types (Sample Data)
INSERT INTO claim_types (id, name, description, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Accident', 'Vehicle accident claims', NOW(), NOW()),
    (gen_random_uuid(), 'Theft', 'Theft and burglary claims', NOW(), NOW()),
    (gen_random_uuid(), 'Natural Disaster', 'Natural disaster claims', NOW(), NOW()),
    (gen_random_uuid(), 'Medical', 'Medical insurance claims', NOW(), NOW()),
    (gen_random_uuid(), 'Property Damage', 'Property damage claims', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 4: Insert Sample Clients
INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'personal'::client_type, 'John', 'Doe', '8001015009087', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Jane', 'Smith', '8502155009088', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '1234567890123', 'ABC Company Ltd', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '9876543210987', 'XYZ Corporation', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Mike', 'Johnson', '9001015009089', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW());

-- Step 5: Insert Sample Addresses
INSERT INTO addresses (id, client_id, line1, line2, city, province, postal_code, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    '123 Main Street',
    'Apt 4B',
    'Johannesburg',
    'Gauteng',
    '2000',
    NOW(),
    NOW()
FROM clients c
WHERE c.first_name = 'John' AND c.last_name = 'Doe'
LIMIT 1;

-- Step 6: Insert Sample Policies
INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    pt.id,
    'POL-001-2024',
    '2024-01-01'::date,
    '2024-12-31'::date,
    'active'::policy_status,
    NOW(),
    NOW()
FROM clients c
CROSS JOIN insurers i
CROSS JOIN policy_types pt
WHERE c.first_name = 'John' AND c.last_name = 'Doe'
  AND i.name = 'Santam'
  AND pt.display_name = 'Motor Vehicle Insurance'
LIMIT 1;

-- Check results
SELECT '=== MIGRATION COMPLETE ===' as info;

SELECT 'Final Table Counts:' as info;
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

-- Sample data verification
SELECT 'Sample Data:' as info;
SELECT 'Insurers:' as table_name, name FROM insurers LIMIT 3;
SELECT 'Policy Types:' as table_name, display_name FROM policy_types LIMIT 3;
SELECT 'Clients:' as table_name, COALESCE(first_name || ' ' || last_name, entity_name) as name FROM clients LIMIT 3;
