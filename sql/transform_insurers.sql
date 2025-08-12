-- =====================================================
-- INSURERS TRANSFORMATION SCRIPT
-- =====================================================
-- Transform azure_insurance_companies.csv to Supabase insurers table
-- =====================================================

-- Step 1: Create temporary table for CSV import
CREATE TEMP TABLE temp_azure_insurers (
    Insurar_ID_Key INTEGER,
    Insurar_Name TEXT,
    extraction_date TEXT
);

-- Step 2: Import CSV data (you'll need to use your database's CSV import function)
-- Example for PostgreSQL:
-- COPY temp_azure_insurers FROM 'azure_export/azure_insurance_companies.csv' WITH (FORMAT csv, HEADER true);

-- Step 3: Transform and insert into Supabase insurers table
INSERT INTO insurers (id, name, contact_info, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,
    Insurar_Name as name,
    '{}'::jsonb as contact_info,  -- Empty JSON object for now
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_insurers
WHERE Insurar_Name IS NOT NULL
  AND Insurar_Name != ''
ON CONFLICT (name) DO NOTHING;

-- Step 4: Validation query
SELECT 
    'Insurers loaded successfully' as status,
    COUNT(*) as total_insurers,
    STRING_AGG(name, ', ') as insurer_names
FROM insurers;

-- Step 5: Clean up
DROP TABLE temp_azure_insurers;
