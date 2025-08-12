# Azure Data Extraction Guide - Phase 1

## 🎯 **Objective**
Extract all data from your Azure SQL Database tables for migration to Supabase.

## 📋 **Prerequisites**
- Access to your Azure SQL Database
- Azure Data Studio or SQL Server Management Studio (SSMS)
- Excel or similar tool for CSV handling

## 🚀 **Step-by-Step Process**

### **Step 1: Connect to Azure Database**
1. Open **Azure Data Studio** or **SQL Server Management Studio**
2. Connect to your Azure SQL Database using your credentials
3. Verify you can see the `dbo` schema and tables

### **Step 2: Verify Table Names**
Before running the extraction script, verify these table names exist in your database:
- `dbo.insurance_company_dim`
- `dbo.commercial_insurance_type_dim`
- `_personal_insurance_type_dim` (note: no `dbo.` prefix)
- `dbo.ft_claim_type_dim`
- `dbo.client_dim`
- `dbo.address_dim`
- `[Insurance_Policy_Table]` (replace with actual table name)

**Run this query to list all tables:**
```sql
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
```

### **Step 3: Run Data Extraction**
1. Open the `azure_data_extraction.sql` file
2. **Run each SELECT statement separately** (not the entire file at once)
3. **Export each result to CSV** with the specified filename

### **Step 4: Export Process for Each Table**

#### **4.1 Insurance Companies**
```sql
SELECT 
    Insurar_ID_Key,
    Insurar_Name,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.insurance_company_dim
WHERE Insurar_Name IS NOT NULL
ORDER BY Insurar_ID_Key;
```
**Export as:** `azure_insurance_companies.csv`

#### **4.2 Commercial Insurance Types**
```sql
SELECT 
    insurance_type_key,
    insurance_type,
    'commercial' as category,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.commercial_insurance_type_dim
WHERE insurance_type IS NOT NULL
ORDER BY insurance_type_key;
```
**Export as:** `azure_commercial_insurance_types.csv`

#### **4.3 Personal Insurance Types**
```sql
SELECT 
    insurance_type_key,
    insurance_type,
    'personal' as category,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM _personal_insurance_type_dim
WHERE insurance_type IS NOT NULL
ORDER BY insurance_type_key;
```
**Export as:** `azure_personal_insurance_types.csv`

#### **4.4 Claim Types**
```sql
SELECT 
    ft_claim_type_id,
    ft_claim_type,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.ft_claim_type_dim
WHERE ft_claim_type IS NOT NULL
ORDER BY ft_claim_type_id;
```
**Export as:** `azure_claim_types.csv`

#### **4.5 Clients**
```sql
SELECT 
    Client_ID,
    Client_Name,
    Client_Surname,
    Client_ID_Nr,
    Client_Type,
    Company_Name,
    Body_Corporate_Name,
    Insurance_Status,
    Comments,
    Email,
    Cell_Number,
    Alt_Email,
    Alt_Number,
    Trustee_Name,
    Trustee_Contact_Number,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.client_dim
WHERE Client_ID IS NOT NULL
ORDER BY Client_ID;
```
**Export as:** `azure_clients.csv`

#### **4.6 Addresses**
```sql
SELECT 
    Address_ID_Key,
    Client_Id_Key,
    Street,
    Suburb,
    City,
    Province,
    Postal_Code,
    Unit_Number,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM dbo.address_dim
WHERE Client_Id_Key IS NOT NULL
ORDER BY Client_Id_Key, Address_ID_Key;
```
**Export as:** `azure_addresses.csv`

#### **4.7 Insurance Policies**
```sql
SELECT 
    Insurance_ID_Key,
    Insurance_Client_Key,
    Insurar_ID,
    Insurance_Type_ID,
    Policy_Number,
    Premium,
    Excess,
    Ins_Start_Date,
    Ins_End_Date,
    Ins_Renewal_Date,
    'Extracted on: ' + CONVERT(VARCHAR, GETDATE(), 120) as extraction_date
FROM [Insurance_Policy_Table]  -- Replace with actual table name
WHERE Insurance_ID_Key IS NOT NULL
ORDER BY Insurance_ID_Key;
```
**Export as:** `azure_policies.csv`

### **Step 5: Data Quality Checks**
Run these queries to check data quality:

#### **5.1 Record Counts**
```sql
SELECT 'insurance_company_dim' as table_name, COUNT(*) as record_count
FROM dbo.insurance_company_dim
UNION ALL
SELECT 'commercial_insurance_type_dim', COUNT(*)
FROM dbo.commercial_insurance_type_dim
UNION ALL
SELECT '_personal_insurance_type_dim', COUNT(*)
FROM _personal_insurance_type_dim
UNION ALL
SELECT 'ft_claim_type_dim', COUNT(*)
FROM dbo.ft_claim_type_dim
UNION ALL
SELECT 'client_dim', COUNT(*)
FROM dbo.client_dim
UNION ALL
SELECT 'address_dim', COUNT(*)
FROM dbo.address_dim;
```

#### **5.2 Data Quality Issues**
```sql
-- Check for null values in key fields
SELECT 'clients_without_name' as issue, COUNT(*) as count
FROM dbo.client_dim
WHERE Client_Name IS NULL OR Client_Surname IS NULL
UNION ALL
SELECT 'addresses_without_client', COUNT(*)
FROM dbo.address_dim
WHERE Client_Id_Key IS NULL;

-- Check for duplicate ID numbers
SELECT 'duplicate_client_ids', COUNT(*) as count
FROM (
    SELECT Client_ID_Nr, COUNT(*) as cnt
    FROM dbo.client_dim
    WHERE Client_ID_Nr IS NOT NULL
    GROUP BY Client_ID_Nr
    HAVING COUNT(*) > 1
) duplicates;
```

### **Step 6: Export Settings**
When exporting to CSV, use these settings:
- **Encoding:** UTF-8
- **Delimiter:** Comma (,)
- **Include headers:** Yes
- **Quote text fields:** Yes

### **Step 7: File Organization**
Create a folder structure:
```
azure_export/
├── azure_insurance_companies.csv
├── azure_commercial_insurance_types.csv
├── azure_personal_insurance_types.csv
├── azure_claim_types.csv
├── azure_clients.csv
├── azure_addresses.csv
└── azure_policies.csv
```

## ⚠️ **Important Notes**

1. **Backup First:** Make sure you have a backup of your Azure database before extraction
2. **Test with Small Dataset:** If you have a large dataset, test with a small sample first
3. **Check Data Types:** Ensure all data types are properly handled during export
4. **Handle Special Characters:** Pay attention to special characters in text fields
5. **Document Issues:** Note any data quality issues found during extraction

## 🔍 **Troubleshooting**

### **Common Issues:**
- **Table not found:** Verify table names and schema
- **Permission errors:** Ensure you have SELECT permissions
- **Encoding issues:** Use UTF-8 encoding for CSV export
- **Large datasets:** Consider breaking into smaller chunks

### **If Tables Don't Exist:**
1. Check the actual table names in your database
2. Update the extraction script with correct names
3. Verify schema names (dbo, etc.)

## ✅ **Completion Checklist**

- [ ] All 7 tables extracted successfully
- [ ] CSV files created with correct names
- [ ] Data quality checks completed
- [ ] No critical data quality issues found
- [ ] Files saved in `azure_export` folder
- [ ] UTF-8 encoding used for all files
- [ ] Record counts documented

## 🚀 **Next Steps**

Once extraction is complete:
1. Review the data quality summary
2. Proceed to **Phase 2: Data Transformation**
3. Clean and prepare the CSV files for import
4. Map data according to the ETL_IMR.md guide

---

**Need Help?** If you encounter any issues during extraction, document the error and we can troubleshoot together!
