# 🚀 Migration Execution Guide

## 🎯 **Phase 2: Data Transformation & Loading**

You've successfully exported all your Azure data! Now let's load it into Supabase.

## 📋 **What You Need**
- ✅ All 7 CSV files in `azure_export/` folder
- ✅ Supabase project access
- ✅ The `complete_migration_script.sql` file

## 🛠️ **Execution Options**

### **Option 1: Supabase Dashboard (Recommended)**
1. **Open Supabase Dashboard**
   - Go to your project dashboard
   - Navigate to **SQL Editor**

2. **Upload CSV Files**
   - Go to **Storage** → **Create a new bucket** called `migration-data`
   - Upload all 7 CSV files to this bucket

3. **Run Migration Script**
   - Open **SQL Editor**
   - Copy the contents of `complete_migration_script.sql`
   - **Replace the COPY commands** with Supabase storage paths
   - Execute the script

### **Option 2: Supabase CLI**
1. **Install Supabase CLI** (if not already installed)
2. **Link your project** (already done)
3. **Run the migration script**

## 🔧 **Step-by-Step Process**

### **Step 1: Prepare Your Environment**
```bash
# Verify your Supabase connection
supabase status
```

### **Step 2: Upload CSV Files to Supabase Storage**
1. **Create Storage Bucket**:
   ```sql
   -- Run this in Supabase SQL Editor
   INSERT INTO storage.buckets (id, name, public) 
   VALUES ('migration-data', 'migration-data', false);
   ```

2. **Upload Files** (via Dashboard or CLI):
   - `azure_insurance_companies.csv`
   - `azure_commercial_insurance_types.csv`
   - `azure_personal_insurance_types.csv`
   - `azure_claim_types.csv`
   - `azure_clients.csv`
   - `azure_addresses.csv`
   - `azure_policies.csv`

### **Step 3: Modify Migration Script**
Replace the `COPY` commands in `complete_migration_script.sql`:

```sql
-- Instead of:
-- COPY temp_azure_insurers FROM 'azure_export/azure_insurance_companies.csv' WITH (FORMAT csv, HEADER true);

-- Use:
COPY temp_azure_insurers FROM 'https://your-project.supabase.co/storage/v1/object/public/migration-data/azure_insurance_companies.csv' WITH (FORMAT csv, HEADER true);
```

### **Step 4: Execute Migration**
1. **Open Supabase SQL Editor**
2. **Copy the modified script**
3. **Execute in sections** (recommended):
   - Run Steps 1-3 (Reference tables)
   - Run Step 4 (Clients)
   - Run Step 5 (Addresses)
   - Run Step 6 (Policies)

### **Step 5: Verify Migration**
Check the validation queries at the end of the script.

## ⚠️ **Important Notes**

### **Before Running:**
1. **Backup your Supabase data** (if any existing data)
2. **Test with small dataset** first
3. **Check CSV file encoding** (should be UTF-8)

### **During Migration:**
1. **Monitor for errors** - the script has error handling
2. **Check foreign key relationships** - ensure data integrity
3. **Validate data quality** - check for missing or invalid data

### **After Migration:**
1. **Verify record counts** match your expectations
2. **Test relationships** between tables
3. **Check data quality** in the Supabase dashboard

## 🎯 **Expected Results**

After successful migration, you should have:
- **9 Insurance Companies** in `insurers` table
- **Policy Types** in `policy_types` table (commercial + personal)
- **Claim Types** in `claim_types` table
- **~572 Clients** in `clients` table
- **~587 Addresses** in `addresses` table
- **~733 Policies** in `policies` table

## 🚨 **Troubleshooting**

### **Common Issues:**
1. **CSV Import Errors**: Check file encoding and format
2. **Foreign Key Errors**: Ensure reference data is loaded first
3. **Duplicate Key Errors**: Data already exists, use `ON CONFLICT DO NOTHING`
4. **Memory Issues**: Run in smaller batches

### **If Something Goes Wrong:**
1. **Check Supabase logs** for detailed error messages
2. **Rollback** if using transactions
3. **Clean up** temporary tables manually
4. **Retry** with smaller data sets

## 📞 **Need Help?**

If you encounter issues:
1. **Share error messages** from Supabase
2. **Check data quality** in your CSV files
3. **Verify table schemas** match expectations

---

**Ready to start the migration?** Let me know when you're ready to proceed with Step 1!
