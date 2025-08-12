-- =====================================================
-- SIMPLE MANUAL MIGRATION SCRIPT
-- =====================================================
-- Run this script in Supabase SQL Editor
-- This will add your Azure data manually
-- =====================================================

-- Step 1: Check current data
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

-- Step 2: Add Insurance Companies (from your CSV)
-- Replace the VALUES with actual data from your dbo.insurance_company_dim.csv
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Santam', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Hollard', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'CIA', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Old Mutual', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Discovery', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'OUTsurance', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'MiWay', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Budget', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Dial Direct', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'King Price', '{}'::jsonb, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 3: Add Policy Types (from your CSV files)
-- Replace with actual data from your commercial and personal insurance type CSVs
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Motor Vehicle Insurance', 'motor-vehicle-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Home Insurance', 'home-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Life Insurance', 'life-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Business Insurance', 'business-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Medical Insurance', 'medical-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Commercial Property', 'commercial-property', NOW(), NOW()),
    (gen_random_uuid(), 'Public Liability', 'public-liability', NOW(), NOW()),
    (gen_random_uuid(), 'Professional Indemnity', 'professional-indemnity', NOW(), NOW()),
    (gen_random_uuid(), 'Workers Compensation', 'workers-compensation', NOW(), NOW()),
    (gen_random_uuid(), 'Directors & Officers', 'directors-officers', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 4: Add Claim Types (from your CSV)
-- Replace with actual data from your ft_claim_type.csv
INSERT INTO claim_types (id, name, description, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Accident', 'Vehicle accident claims', NOW(), NOW()),
    (gen_random_uuid(), 'Theft', 'Theft and burglary claims', NOW(), NOW()),
    (gen_random_uuid(), 'Natural Disaster', 'Natural disaster claims', NOW(), NOW()),
    (gen_random_uuid(), 'Medical', 'Medical insurance claims', NOW(), NOW()),
    (gen_random_uuid(), 'Property Damage', 'Property damage claims', NOW(), NOW()),
    (gen_random_uuid(), 'Fire', 'Fire damage claims', NOW(), NOW()),
    (gen_random_uuid(), 'Flood', 'Flood damage claims', NOW(), NOW()),
    (gen_random_uuid(), 'Storm', 'Storm damage claims', NOW(), NOW()),
    (gen_random_uuid(), 'Vandalism', 'Vandalism claims', NOW(), NOW()),
    (gen_random_uuid(), 'Liability', 'Liability claims', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 5: Create Products (link insurers to policy types)
INSERT INTO products (id, insurer_id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    i.id,
    pt.display_name,
    'Product: ' || pt.display_name || ' by ' || i.name,
    NOW(),
    NOW()
FROM insurers i
CROSS JOIN policy_types pt
WHERE i.name IN ('Santam', 'Hollard', 'CIA', 'Old Mutual', 'Discovery')
  AND pt.display_name IN ('Motor Vehicle Insurance', 'Home Insurance', 'Life Insurance', 'Business Insurance', 'Medical Insurance')
ON CONFLICT DO NOTHING;

-- Step 6: Add Sample Clients (from your CSV)
-- Replace with actual data from your dbo.client_dim.csv
INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'personal'::client_type, 'John', 'Doe', '8001015009087', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Jane', 'Smith', '8502155009088', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '1234567890123', 'ABC Company Ltd', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '9876543210987', 'XYZ Corporation', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Mike', 'Johnson', '9001015009089', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Sarah', 'Wilson', '9203155009090', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '1111111111111', 'Tech Solutions Inc', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '2222222222222', 'Global Enterprises', 'Sample business client', 'active'::client_status, NOW(), NOW());

-- Step 7: Add Sample Addresses (from your CSV)
-- Replace with actual data from your dbo.address_dim.csv
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

INSERT INTO addresses (id, client_id, line1, line2, city, province, postal_code, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    '456 Oak Avenue',
    'Suite 10',
    'Cape Town',
    'Western Cape',
    '8000',
    NOW(),
    NOW()
FROM clients c
WHERE c.first_name = 'Jane' AND c.last_name = 'Smith'
LIMIT 1;

-- Step 8: Add Sample Policies (from your CSV)
-- Replace with actual data from your dbo.policy_dim.csv
INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    p.id,
    'POL-001-2024',
    '2024-01-01'::date,
    '2024-12-31'::date,
    'active'::policy_status,
    NOW(),
    NOW()
FROM clients c
CROSS JOIN insurers i
CROSS JOIN products p
WHERE c.first_name = 'John' AND c.last_name = 'Doe'
  AND i.name = 'Santam'
  AND p.name = 'Motor Vehicle Insurance'
LIMIT 1;

INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    p.id,
    'POL-002-2024',
    '2024-02-01'::date,
    '2025-01-31'::date,
    'active'::policy_status,
    NOW(),
    NOW()
FROM clients c
CROSS JOIN insurers i
CROSS JOIN products p
WHERE c.first_name = 'Jane' AND c.last_name = 'Smith'
  AND i.name = 'Hollard'
  AND p.name = 'Home Insurance'
LIMIT 1;

-- Step 9: Final Validation
SELECT '=== MIGRATION COMPLETE ===' as info;

SELECT 'Final Table Counts:' as info;
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
SELECT 'Sample Data Verification:' as info;
SELECT 'Insurers:' as table_name, name FROM insurers ORDER BY name LIMIT 5;
SELECT 'Policy Types:' as table_name, display_name FROM policy_types ORDER BY display_name LIMIT 5;
SELECT 'Clients:' as table_name, COALESCE(first_name || ' ' || last_name, entity_name) as name FROM clients ORDER BY created_at DESC LIMIT 5;
SELECT 'Policies:' as table_name, policy_number FROM policies ORDER BY created_at DESC LIMIT 5;
