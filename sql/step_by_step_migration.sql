-- =====================================================
-- STEP-BY-STEP MIGRATION SCRIPT
-- =====================================================
-- Run each section separately in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: CREATE STORAGE BUCKET
-- =====================================================
INSERT INTO storage.buckets (id, name, public) 
VALUES ('migration-data', 'migration-data', false)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- STEP 2: LOAD INSURANCE COMPANIES
-- =====================================================
-- First, create the temp table
CREATE TEMP TABLE temp_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Then, copy the data (replace with your actual URL)
-- COPY temp_insurers FROM 'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.insurance_company_dim.csv' WITH (FORMAT csv, HEADER true);

-- Finally, insert into insurers table
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    Insurar_Name as name,
    '{}'::jsonb as contact_info,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_insurers
WHERE Insurar_Name IS NOT NULL AND Insurar_Name != ''
ON CONFLICT (name) DO NOTHING;

-- Check results
SELECT 'Insurers loaded:' as info, COUNT(*) as count FROM insurers;

-- =====================================================
-- STEP 3: LOAD POLICY TYPES
-- =====================================================
-- Create temp tables
CREATE TEMP TABLE temp_commercial_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

CREATE TEMP TABLE temp_personal_types (
    insurance_type_key INTEGER,
    insurance_type TEXT,
    category TEXT,
    extraction_date TEXT
);

-- Copy data (replace with your actual URLs)
-- COPY temp_commercial_types FROM 'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.commercial_insurance_type_dim.csv' WITH (FORMAT csv, HEADER true);
-- COPY temp_personal_types FROM 'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/dbo.personal_insurance_type_dim.csv' WITH (FORMAT csv, HEADER true);

-- Insert commercial types
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_commercial_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Insert personal types
INSERT INTO policy_types (id, display_name, slug, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    insurance_type as display_name,
    LOWER(REPLACE(REPLACE(insurance_type, ' ', '-'), ',', '')) as slug,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_personal_types
WHERE insurance_type IS NOT NULL AND insurance_type != ''
ON CONFLICT (slug) DO NOTHING;

-- Check results
SELECT 'Policy types loaded:' as info, COUNT(*) as count FROM policy_types;

-- =====================================================
-- STEP 4: LOAD CLAIM TYPES
-- =====================================================
CREATE TEMP TABLE temp_claim_types (
    ft_claim_type_id INTEGER,
    ft_claim_type TEXT,
    extraction_date TEXT
);

-- Copy data (replace with your actual URL)
-- COPY temp_claim_types FROM 'https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/ft_claim_type.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO claim_types (id, name, description, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    ft_claim_type as name,
    'Migrated from Azure' as description,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_claim_types
WHERE ft_claim_type IS NOT NULL AND ft_claim_type != ''
ON CONFLICT (name) DO NOTHING;

-- Check results
SELECT 'Claim types loaded:' as info, COUNT(*) as count FROM claim_types;
