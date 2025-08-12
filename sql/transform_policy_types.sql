-- =====================================================
-- POLICY TYPES TRANSFORMATION SCRIPT
-- =====================================================
-- Transform commercial and personal insurance types to Supabase policy_types table
-- =====================================================

-- Step 1: Create temporary tables for CSV import
CREATE TEMP TABLE temp_azure_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

CREATE TEMP TABLE temp_azure_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Step 2: Import CSV data (you'll need to use your database's CSV import function)
-- Example for PostgreSQL:
-- COPY temp_azure_commercial_types FROM 'azure_export/azure_commercial_insurance_types.csv' WITH (FORMAT csv, HEADER true);
-- COPY temp_azure_personal_types FROM 'azure_export/azure_personal_insurance_types.csv' WITH (FORMAT csv, HEADER true);

-- Step 3: Transform and insert commercial insurance types
INSERT INTO policy_types (id, display_name, category, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    'commercial' as category,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_commercial_types
WHERE insurance_type IS NOT NULL
  AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Step 4: Transform and insert personal insurance types
INSERT INTO policy_types (id, display_name, category, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    'personal' as category,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_personal_types
WHERE insurance_type IS NOT NULL
  AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Step 5: Validation query
SELECT 
    'Policy types loaded successfully' as status,
    COUNT(*) as total_policy_types,
    COUNT(CASE WHEN category = 'commercial' THEN 1 END) as commercial_types,
    COUNT(CASE WHEN category = 'personal' THEN 1 END) as personal_types
FROM policy_types;

-- Step 6: Sample data check
SELECT 
    category,
    display_name,
    slug
FROM policy_types
ORDER BY category, display_name
LIMIT 10;

-- Step 7: Clean up
DROP TABLE temp_azure_commercial_types;
DROP TABLE temp_azure_personal_types;
