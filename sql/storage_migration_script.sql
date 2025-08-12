-- =====================================================
-- STORAGE-BASED MIGRATION SCRIPT
-- =====================================================
-- This script uses Supabase storage functions instead of COPY
-- =====================================================

-- Step 1: Create storage bucket (if not exists)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('migration-data', 'migration-data', false)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Load Insurance Companies
-- First, let's check what's in the CSV file
SELECT '=== CHECKING INSURANCE COMPANIES CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'dbo.insurance_company_dim.csv') as file_url;

-- Step 3: Load Policy Types
SELECT '=== CHECKING POLICY TYPES CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'dbo.commercial_insurance_type_dim.csv') as commercial_url;
SELECT storage.get_object_url('migration-data', 'dbo.personal_insurance_type_dim.csv') as personal_url;

-- Step 4: Load Claim Types
SELECT '=== CHECKING CLAIM TYPES CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'ft_claim_type.csv') as claim_types_url;

-- Step 5: Load Clients
SELECT '=== CHECKING CLIENTS CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'dbo.client_dim.csv') as clients_url;

-- Step 6: Load Addresses
SELECT '=== CHECKING ADDRESSES CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'dbo.address_dim.csv') as addresses_url;

-- Step 7: Load Policies
SELECT '=== CHECKING POLICIES CSV ===' as info;
SELECT storage.get_object_url('migration-data', 'dbo.policy_dim.csv') as policies_url;

-- Check current table counts
SELECT '=== CURRENT TABLE COUNTS ===' as info;
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
