# FULL DATA MIGRATION EXECUTION GUIDE

## 🚀 Complete Azure to Supabase Data Migration

This guide will walk you through migrating all your Azure data to Supabase.

## 📋 Prerequisites

✅ Azure CSV files ready in Downloads folder  
✅ Supabase project connected  
✅ Sample data already loaded (for testing)  

## 📊 CSV Files Required

- `dbo.insurance_company_dim.csv`
- `dbo.commercial_insurance_type_dim.csv`
- `dbo.personal_insurance_type_dim.csv`
- `ft_claim_type.csv`
- `dbo.client_dim.csv`
- `dbo.address_dim.csv`
- `dbo.policy_dim.csv`

## 🎯 Migration Steps

### Step 1: Upload CSV Files to Supabase Storage

1. **Go to Supabase Dashboard**
   - Navigate to your project: https://supabase.com/dashboard/project/gqwonqnhdcqksafucbmo

2. **Create Storage Bucket**
   - Go to Storage → Create bucket
   - Name: `migration-data`
   - Public: `false`
   - Click "Create bucket"

3. **Upload CSV Files**
   - Click on the `migration-data` bucket
   - Upload each CSV file from your Downloads folder:
     - `dbo.insurance_company_dim.csv`
     - `dbo.commercial_insurance_type_dim.csv`
     - `dbo.personal_insurance_type_dim.csv`
     - `ft_claim_type.csv`
     - `dbo.client_dim.csv`
     - `dbo.address_dim.csv`
     - `dbo.policy_dim.csv`

### Step 2: Get Storage URLs

After uploading, get the public URLs for each file:

1. **Right-click each file** in the storage bucket
2. **Copy the URL** (format: `https://gqwonqnhdcqksafucbmo.supabase.co/storage/v1/object/public/migration-data/filename.csv`)

### Step 3: Prepare Migration Script

1. **Open the migration script**: `sql/full_data_migration_script.sql`
2. **Replace the placeholder URLs** with your actual storage URLs
3. **Uncomment the COPY commands** by removing the `--` at the beginning

### Step 4: Execute Migration

#### Option A: Using Supabase Dashboard (Recommended)

1. **Go to SQL Editor** in Supabase Dashboard
2. **Copy the entire migration script**
3. **Paste and run** the script
4. **Monitor the results** for any errors

#### Option B: Using Supabase CLI

```bash
# Run the migration script
supabase db remote commit --sql "$(Get-Content sql/full_data_migration_script.sql -Raw)" --password "uAFy4pbdtuM4Dd12"
```

### Step 5: Verify Migration

After running the script, you should see:

```
=== MIGRATION COMPLETE ===

Final Table Counts:
insurers: [count]
policy_types: [count]
products: [count]
claim_types: [count]
clients: [count]
addresses: [count]
policies: [count]
```

## 🔧 Troubleshooting

### Common Issues:

1. **COPY command fails**
   - Ensure CSV files are uploaded to storage
   - Check storage URLs are correct
   - Verify bucket permissions

2. **Foreign key constraint errors**
   - Check that insurers exist before creating products
   - Verify client relationships

3. **Data type errors**
   - Check CSV column formats
   - Verify date formats in policy data

### Error Recovery:

If the migration fails partway through:

1. **Check which step failed**
2. **Fix the issue** (usually data format)
3. **Re-run from the failed step** or start over

## 📈 Expected Results

After successful migration, you should have:

- **Insurers**: All your Azure insurance companies
- **Policy Types**: All commercial and personal insurance types
- **Products**: Links between insurers and policy types
- **Claim Types**: All claim categories
- **Clients**: All personal and business clients
- **Addresses**: All client addresses
- **Policies**: All insurance policies with proper relationships

## 🎉 Success Criteria

✅ All tables have data  
✅ No foreign key constraint errors  
✅ Policy relationships are correct  
✅ Client addresses are linked  
✅ Products link insurers to policy types  

## 🚀 Next Steps

After successful migration:

1. **Test the Flutter app** with real data
2. **Verify all features work** with migrated data
3. **Update any hardcoded references** to use real data
4. **Deploy the updated app**

## 📞 Support

If you encounter issues:

1. **Check the error messages** in Supabase SQL Editor
2. **Verify CSV file formats** match expected schema
3. **Test with smaller data sets** first
4. **Contact support** if needed

---

**Ready to start the migration? Let's go! 🚀**
