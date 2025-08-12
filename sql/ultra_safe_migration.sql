-- =====================================================
-- ULTRA SAFE MIGRATION SCRIPT
-- =====================================================
-- This script works regardless of schema constraints
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

-- Step 2: Add Insurance Companies (safe insert)
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    name,
    '{}'::jsonb,
    NOW(),
    NOW()
FROM (VALUES 
    ('Santam'),
    ('Hollard'),
    ('CIA'),
    ('Old Mutual'),
    ('Discovery'),
    ('OUTsurance'),
    ('MiWay'),
    ('Budget'),
    ('Dial Direct'),
    ('King Price')
) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM insurers i WHERE i.name = v.name);

-- Step 3: Add Policy Types (safe insert)
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    display_name,
    slug,
    NOW(),
    NOW()
FROM (VALUES 
    ('Motor Vehicle Insurance', 'motor-vehicle-insurance'),
    ('Home Insurance', 'home-insurance'),
    ('Life Insurance', 'life-insurance'),
    ('Business Insurance', 'business-insurance'),
    ('Medical Insurance', 'medical-insurance'),
    ('Commercial Property', 'commercial-property'),
    ('Public Liability', 'public-liability'),
    ('Professional Indemnity', 'professional-indemnity'),
    ('Workers Compensation', 'workers-compensation'),
    ('Directors & Officers', 'directors-officers')
) AS v(display_name, slug)
WHERE NOT EXISTS (SELECT 1 FROM policy_types pt WHERE pt.slug = v.slug);

-- Step 4: Add Claim Types (safe insert)
INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    name,
    description,
    NOW(),
    NOW()
FROM (VALUES 
    ('Accident', 'Vehicle accident claims'),
    ('Theft', 'Theft and burglary claims'),
    ('Natural Disaster', 'Natural disaster claims'),
    ('Medical', 'Medical insurance claims'),
    ('Property Damage', 'Property damage claims'),
    ('Fire', 'Fire damage claims'),
    ('Flood', 'Flood damage claims'),
    ('Storm', 'Storm damage claims'),
    ('Vandalism', 'Vandalism claims'),
    ('Liability', 'Liability claims')
) AS v(name, description)
WHERE NOT EXISTS (SELECT 1 FROM claim_types ct WHERE ct.name = v.name);

-- Step 5: Create Products (safe insert)
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
  AND NOT EXISTS (
    SELECT 1 FROM products p 
    WHERE p.insurer_id = i.id AND p.name = pt.display_name
  );

-- Step 6: Add Sample Clients (safe insert)
INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    client_type,
    first_name,
    last_name,
    id_number,
    entity_name,
    comments,
    status,
    NOW(),
    NOW()
FROM (VALUES 
    ('personal'::client_type, 'John', 'Doe', '8001015009087', NULL, 'Sample personal client', 'active'::client_status),
    ('personal'::client_type, 'Jane', 'Smith', '8502155009088', NULL, 'Sample personal client', 'active'::client_status),
    ('business'::client_type, NULL, NULL, '1234567890123', 'ABC Company Ltd', 'Sample business client', 'active'::client_status),
    ('business'::client_type, NULL, NULL, '9876543210987', 'XYZ Corporation', 'Sample business client', 'active'::client_status),
    ('personal'::client_type, 'Mike', 'Johnson', '9001015009089', NULL, 'Sample personal client', 'active'::client_status),
    ('personal'::client_type, 'Sarah', 'Wilson', '9203155009090', NULL, 'Sample personal client', 'active'::client_status),
    ('business'::client_type, NULL, NULL, '1111111111111', 'Tech Solutions Inc', 'Sample business client', 'active'::client_status),
    ('business'::client_type, NULL, NULL, '2222222222222', 'Global Enterprises', 'Sample business client', 'active'::client_status)
) AS v(client_type, first_name, last_name, id_number, entity_name, comments, status)
WHERE NOT EXISTS (SELECT 1 FROM clients c WHERE c.id_number = v.id_number);

-- Step 7: Add Sample Addresses (safe insert)
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
  AND NOT EXISTS (SELECT 1 FROM addresses a WHERE a.client_id = c.id)
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
  AND NOT EXISTS (SELECT 1 FROM addresses a WHERE a.client_id = c.id)
LIMIT 1;

-- Step 8: Add Sample Policies (safe insert with unique numbers)
INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    p.id,
    'POL-MIG-001-2024',
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
  AND NOT EXISTS (SELECT 1 FROM policies pol WHERE pol.policy_number = 'POL-MIG-001-2024')
LIMIT 1;

INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    p.id,
    'POL-MIG-002-2024',
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
  AND NOT EXISTS (SELECT 1 FROM policies pol WHERE pol.policy_number = 'POL-MIG-002-2024')
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
