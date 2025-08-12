# Real Data Loading Guide

## Problem
The previous migration script only loaded sample placeholder data, not your actual Azure data. This guide will help you load your real business data.

## Step 1: Check Current Data
First, run the `sql/check_current_data.sql` script in your Supabase SQL Editor to see what's currently in your database.

## Step 2: Prepare Your CSV Files
Make sure you have these CSV files from your Azure export:
- `dbo.insurance_company_dim.csv` - Insurance companies
- `dbo.commercial_insurance_type_dim.csv` - Commercial policy types
- `dbo.personal_insurance_type_dim.csv` - Personal policy types
- `ft_claim_type.csv` - Claim types
- `dbo.client_dim.csv` - Clients
- `dbo.address_dim.csv` - Addresses
- `dbo.policy_dim.csv` - Policies

## Step 3: Open Your CSV Files
Open each CSV file in a text editor (like Notepad) or Excel to see the actual data.

## Step 4: Copy Your Real Data
For each CSV file, copy the actual data rows (not the header) and paste them into the corresponding section in `sql/load_real_azure_data.sql`.

### Example: Insurance Companies
If your `dbo.insurance_company_dim.csv` looks like this:
```csv
Insurar_ID_Key,Insurar_Name,extraction_date
1,Santam,2024-01-15
2,Hollard,2024-01-15
3,CIA,2024-01-15
```

Then in the script, replace this section:
```sql
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    -- PASTE YOUR REAL DATA HERE FROM dbo.insurance_company_dim.csv
    -- Example format:
    -- (1, 'Santam', '2024-01-15'),
    -- (2, 'Hollard', '2024-01-15'),
    -- (3, 'CIA', '2024-01-15')
    -- Add all your real insurers here
;
```

With your actual data:
```sql
INSERT INTO temp_insurers (Insurar_ID_Key, Insurar_Name, extraction_date)
VALUES 
    (1, 'Santam', '2024-01-15'),
    (2, 'Hollard', '2024-01-15'),
    (3, 'CIA', '2024-01-15')
;
```

## Step 5: Repeat for All Tables
Do the same for each table:
- **Policy Types**: Copy from commercial and personal CSV files
- **Claim Types**: Copy from ft_claim_type.csv
- **Clients**: Copy from dbo.client_dim.csv
- **Addresses**: Copy from dbo.address_dim.csv
- **Policies**: Copy from dbo.policy_dim.csv

## Step 6: Run the Migration
1. Copy the entire `sql/load_real_azure_data.sql` script
2. Paste it into your Supabase SQL Editor
3. Click "Run" to execute

## Step 7: Verify the Results
The script will show you:
- Progress through each step
- Final table counts
- Sample data verification

## Important Notes:
- **The script will DELETE ALL existing data** before loading your real data
- Make sure your CSV data matches the expected column structure
- If you have many records, you may need to split the migration into smaller chunks
- Always backup your data before running migrations

## Need Help?
If you need assistance with:
- Converting CSV data to SQL format
- Handling special characters or data types
- Splitting large datasets
- Troubleshooting errors

Let me know and I'll help you!

## Quick Start Option
If you want to start with just a few records to test:
1. Copy just 2-3 rows from each CSV file
2. Paste them into the script
3. Run the script
4. Verify it works
5. Then add the rest of your data
