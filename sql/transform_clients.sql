-- =====================================================
-- CLIENTS TRANSFORMATION SCRIPT
-- =====================================================
-- Transform azure_clients.csv to Supabase clients table
-- =====================================================

-- Step 1: Create temporary table for CSV import
CREATE TEMP TABLE temp_azure_clients (
    Client_ID INTEGER,
    Client_Name TEXT,
    Client_Surname TEXT,
    Client_ID_Nr TEXT,
    Client_Type TEXT,
    Company_Name TEXT,
    Body_Corporate_Name TEXT,
    Insurance_Status TEXT,
    Comments TEXT,
    Email TEXT,
    Cell_Number TEXT,
    Alt_Email TEXT,
    Alt_Number TEXT,
    Trustee_Name TEXT,
    Trustee_Contact_Number TEXT,
    extraction_date TEXT
);

-- Step 2: Import CSV data (you'll need to use your database's CSV import function)
-- Example for PostgreSQL:
-- COPY temp_azure_clients FROM 'azure_export/azure_clients.csv' WITH (FORMAT csv, HEADER true);

-- Step 3: Transform and insert into Supabase clients table
INSERT INTO clients (
    id, 
    client_type, 
    first_name, 
    last_name, 
    id_number,
    entity_name, 
    comments, 
    status, 
    created_at, 
    updated_at
)
SELECT 
    gen_random_uuid() as id,
    CASE 
        WHEN LOWER(Client_Type) = 'personal' THEN 'personal'
        WHEN LOWER(Client_Type) = 'commercial' THEN 'commercial'
        ELSE 'personal'  -- Default to personal if unknown
    END as client_type,
    COALESCE(Client_Name, '') as first_name,
    COALESCE(Client_Surname, '') as last_name,
    Client_ID_Nr as id_number,
    CASE 
        WHEN LOWER(Client_Type) = 'commercial' THEN COALESCE(Company_Name, Body_Corporate_Name)
        ELSE NULL
    END as entity_name,
    COALESCE(Comments, '') as comments,
    CASE 
        WHEN Insurance_Status IS NULL OR Insurance_Status = '' THEN 'active'
        ELSE LOWER(Insurance_Status)
    END as status,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_clients
WHERE Client_ID IS NOT NULL
  AND (Client_Name IS NOT NULL OR Client_Surname IS NOT NULL)
  AND Client_ID_Nr IS NOT NULL
ON CONFLICT (id_number) DO NOTHING;

-- Step 4: Create client contacts for additional contact information
INSERT INTO client_contacts (
    id,
    client_id,
    name,
    email,
    phone,
    role,
    created_at,
    updated_at
)
SELECT 
    gen_random_uuid() as id,
    c.id as client_id,
    COALESCE(temp.Trustee_Name, 'Primary Contact') as name,
    COALESCE(temp.Email, temp.Alt_Email) as email,
    COALESCE(temp.Cell_Number, temp.Alt_Number, temp.Trustee_Contact_Number) as phone,
    CASE 
        WHEN temp.Trustee_Name IS NOT NULL THEN 'trustee'
        ELSE 'primary'
    END as role,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_azure_clients temp
JOIN clients c ON c.id_number = temp.Client_ID_Nr
WHERE (temp.Email IS NOT NULL OR temp.Cell_Number IS NOT NULL OR temp.Trustee_Name IS NOT NULL);

-- Step 5: Validation query
SELECT 
    'Clients loaded successfully' as status,
    COUNT(*) as total_clients,
    COUNT(CASE WHEN client_type = 'personal' THEN 1 END) as personal_clients,
    COUNT(CASE WHEN client_type = 'commercial' THEN 1 END) as commercial_clients,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_clients
FROM clients;

-- Step 6: Sample data check
SELECT 
    client_type,
    first_name,
    last_name,
    entity_name,
    status
FROM clients
ORDER BY created_at DESC
LIMIT 10;

-- Step 7: Clean up
DROP TABLE temp_azure_clients;
