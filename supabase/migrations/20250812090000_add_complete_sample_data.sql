-- =====================================================
-- ADD COMPLETE SAMPLE DATA MIGRATION
-- =====================================================
-- This migration adds all sample data with proper relationships
-- =====================================================

-- Step 1: Temporarily disable the trigger
DROP TRIGGER IF EXISTS update_renewal_flag ON public.policies;

-- Step 2: Insert Insurance Companies (Sample Data)
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Santam', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Hollard', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'CIA', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Old Mutual', '{}'::jsonb, NOW(), NOW()),
    (gen_random_uuid(), 'Discovery', '{}'::jsonb, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 3: Insert Policy Types (Sample Data)
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Motor Vehicle Insurance', 'motor-vehicle-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Home Insurance', 'home-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Life Insurance', 'life-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Business Insurance', 'business-insurance', NOW(), NOW()),
    (gen_random_uuid(), 'Medical Insurance', 'medical-insurance', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 4: Insert Products (Sample Data) - Links insurers to policy types
INSERT INTO products (id, insurer_id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    i.id,
    pt.display_name,
    'Sample product for ' || pt.display_name,
    NOW(),
    NOW()
FROM insurers i
CROSS JOIN policy_types pt
WHERE i.name IN ('Santam', 'Hollard', 'CIA')
  AND pt.display_name IN ('Motor Vehicle Insurance', 'Home Insurance', 'Life Insurance')
ON CONFLICT DO NOTHING;

-- Step 5: Insert Claim Types (Sample Data)
INSERT INTO claim_types (id, name, description, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'Accident', 'Vehicle accident claims', NOW(), NOW()),
    (gen_random_uuid(), 'Theft', 'Theft and burglary claims', NOW(), NOW()),
    (gen_random_uuid(), 'Natural Disaster', 'Natural disaster claims', NOW(), NOW()),
    (gen_random_uuid(), 'Medical', 'Medical insurance claims', NOW(), NOW()),
    (gen_random_uuid(), 'Property Damage', 'Property damage claims', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Step 6: Insert Sample Clients
INSERT INTO clients (id, client_type, first_name, last_name, id_number, entity_name, comments, status, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'personal'::client_type, 'John', 'Doe', '8001015009087', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Jane', 'Smith', '8502155009088', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '1234567890123', 'ABC Company Ltd', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'business'::client_type, NULL, NULL, '9876543210987', 'XYZ Corporation', 'Sample business client', 'active'::client_status, NOW(), NOW()),
    (gen_random_uuid(), 'personal'::client_type, 'Mike', 'Johnson', '9001015009089', NULL, 'Sample personal client', 'active'::client_status, NOW(), NOW());

-- Step 7: Insert Sample Addresses
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

-- Step 8: Insert Sample Policies (with proper product_id)
INSERT INTO policies (id, client_id, insurer_id, product_id, policy_number, start_date, end_date, status, renewal_flag, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    c.id,
    i.id,
    p.id,
    'POL-001-2024',
    '2024-01-01'::date,
    '2024-12-31'::date,
    'active'::policy_status,
    false, -- Set renewal_flag manually
    NOW(),
    NOW()
FROM clients c
CROSS JOIN insurers i
CROSS JOIN products p
WHERE c.first_name = 'John' AND c.last_name = 'Doe'
  AND i.name = 'Santam'
  AND p.name = 'Motor Vehicle Insurance'
LIMIT 1;

-- Step 9: Fix the function and recreate the trigger
DROP FUNCTION IF EXISTS public.check_renewal_flag() CASCADE;

CREATE OR REPLACE FUNCTION public.check_renewal_flag()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.end_date IS NOT NULL THEN
        -- Fix: Use proper date arithmetic (days as integer)
        NEW.renewal_flag := (NEW.end_date - CURRENT_DATE) <= 60;
    END IF;
    RETURN NEW;
END;
$$;

ALTER FUNCTION public.check_renewal_flag() OWNER TO postgres;

-- Recreate the trigger
CREATE TRIGGER update_renewal_flag
    BEFORE INSERT OR UPDATE ON public.policies
    FOR EACH ROW
    EXECUTE FUNCTION public.check_renewal_flag();
