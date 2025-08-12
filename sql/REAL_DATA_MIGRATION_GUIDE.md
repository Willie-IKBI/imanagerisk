# Real Data Migration Guide

## Overview
This guide will help you replace the test data with your real Azure data.

## Step 1: Prepare Your CSV Files
Make sure you have these CSV files from your Azure export:
- `dbo.insurance_company_dim.csv` - Insurance companies
- `dbo.commercial_insurance_type_dim.csv` - Commercial policy types
- `dbo.personal_insurance_type_dim.csv` - Personal policy types
- `ft_claim_type.csv` - Claim types
- `dbo.client_dim.csv` - Clients
- `dbo.address_dim.csv` - Addresses
- `dbo.policy_dim.csv` - Policies

## Step 2: Open Your CSV Files
Open each CSV file in a text editor or Excel to see the actual data structure.

## Step 3: Replace Sample Data in the Script
In the `sql/real_data_migration.sql` file, you need to replace the sample data with your real data.

### For Insurance Companies (Step 3):
Replace this section:
```sql
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    -- Replace these with your actual data from dbo.insurance_company_dim.csv
    (1, 'Your Real Insurer 1', '2024-01-01'),
    (2, 'Your Real Insurer 2', '2024-01-01')
    -- Add all your real insurers here
;
```

With your actual data like:
```sql
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    (1, 'Santam', '2024-01-15'),
    (2, 'Hollard', '2024-01-15'),
    (3, 'CIA', '2024-01-15'),
    -- Add all your real insurers here
;
```

### For Policy Types (Step 4):
Replace the commercial and personal policy type sections with your real data.

### For Claim Types (Step 5):
Replace with your real claim types.

### For Clients (Step 7):
Replace with your real client data.

### For Addresses (Step 8):
Replace with your real address data.

### For Policies (Step 9):
Replace with your real policy data.

## Step 4: Run the Migration
1. Copy the entire `sql/real_data_migration.sql` script
2. Paste it into your Supabase SQL Editor
3. Click "Run" to execute

## Step 5: Verify the Results
The script will show you:
- Current data status before migration
- Progress through each step
- Final table counts
- Sample data verification

## Important Notes:
- The script will **delete all test data** first
- Make sure your CSV data matches the expected column structure
- If you have many records, you may need to split the migration into smaller chunks
- Always backup your data before running migrations

## Need Help?
If you need assistance with the data transformation or encounter any issues, let me know!
