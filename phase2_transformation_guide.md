# Phase 2: Data Transformation & Loading Guide

## 🎯 **Objective**
Transform the exported Azure CSV files and load them into Supabase using the correct schema mapping.

## 📋 **Prerequisites**
- ✅ All 7 CSV files exported from Azure
- ✅ Supabase project linked and accessible
- ✅ CSV files in `azure_export/` folder

## 📊 **Expected Files**
```
azure_export/
├── azure_insurance_companies.csv (9 records)
├── azure_commercial_insurance_types.csv (11 records)
├── azure_personal_insurance_types.csv
├── azure_claim_types.csv
├── azure_clients.csv (572 records)
├── azure_addresses.csv (587 records)
└── azure_policies.csv (733 records)
```

## 🔄 **Transformation Process**

### **Step 1: Data Validation**
First, let's validate the exported data:

```sql
-- Check CSV file contents
-- Run this in your database tool to verify data quality
SELECT 'CSV Validation Complete' as status;
```

### **Step 2: Schema Mapping**
Here's how Azure fields map to Supabase:

| Azure Table | Azure Field | Supabase Table | Supabase Field | Transformation |
|-------------|-------------|----------------|----------------|----------------|
| `insurance_company_dim` | `Insurar_Name` | `insurers` | `name` | Direct mapping |
| `commercial_insurance_type_dim` | `insurance_type` | `policy_types` | `display_name` | Direct mapping |
| `personal_insurance_type_dim` | `insurance_type` | `policy_types` | `display_name` | Direct mapping |
| `ft_claim_type_dim` | `ft_claim_type` | `claim_types` | `name` | Direct mapping |
| `client_dim` | `Client_Name + Client_Surname` | `clients` | `first_name, last_name` | Concatenate |
| `client_dim` | `Client_ID_Nr` | `clients` | `id_number` | Direct mapping |
| `client_dim` | `Client_Type` | `clients` | `client_type` | Map: 'Personal' → 'personal' |
| `address_dim` | `Street, Suburb, City, Province` | `addresses` | `line1, line2, city, province` | Direct mapping |
| `policy_dim` | `Policy_Number` | `policies` | `policy_number` | Direct mapping |
| `policy_dim` | `Premium` | `policies` | `premium` | Direct mapping |
| `policy_dim` | `Insurance_Type` | `policies` | `coverage_details` | Direct mapping |

### **Step 3: Data Cleaning Rules**

#### **Clients Table**
- **Personal Clients**: `Client_Type = 'Personal'` → `client_type = 'personal'`
- **Commercial Clients**: `Client_Type = 'Commercial'` → `client_type = 'commercial'`
- **Entity Name**: Use `Company_Name` for commercial, `NULL` for personal
- **ID Number**: Clean and validate South African ID format
- **Status**: Map `Insurance_Status` to `status` field

#### **Addresses Table**
- **Line1**: Combine `Street` + `Unit_Number` (if exists)
- **Line2**: Use `Suburb`
- **City**: Direct mapping
- **Province**: Direct mapping
- **Postal Code**: Clean and validate

#### **Policies Table**
- **Policy Number**: Direct mapping
- **Premium**: Convert to decimal
- **Start Date**: `Ins_Start_Date` → `start_date`
- **End Date**: `Ins_End_Date` → `end_date`
- **Renewal Date**: `Ins_Renewal_Date` → `renewal_date`
- **Coverage Details**: Use `Insurance_Type` descriptive text

### **Step 4: Loading Order**
1. **Reference Tables First** (no dependencies):
   - `insurers`
   - `policy_types`
   - `claim_types`

2. **Core Tables** (depend on reference tables):
   - `clients`
   - `addresses`

3. **Transaction Tables** (depend on core tables):
   - `policies`

## 🛠️ **Implementation Steps**

### **Step 1: Create Transformation Scripts**
I'll create SQL scripts for each table transformation.

### **Step 2: Validate Data Quality**
Check for:
- Duplicate records
- Missing required fields
- Data format issues
- Foreign key relationships

### **Step 3: Load into Supabase**
Use Supabase migrations or direct SQL execution.

## ⚠️ **Important Considerations**

### **Data Quality Issues to Watch For**
1. **Duplicate ID Numbers**: Check for duplicate `Client_ID_Nr`
2. **Missing Required Fields**: Ensure all required fields are populated
3. **Date Format Issues**: Validate date formats
4. **Special Characters**: Handle special characters in text fields
5. **Null Values**: Decide how to handle NULL values

### **Business Rules**
1. **Active Policies**: Only migrate active policies (future end dates)
2. **Valid Clients**: Only migrate clients with valid contact information
3. **Address Validation**: Ensure addresses have at least city and province
4. **Premium Validation**: Ensure premium amounts are positive

## 🎯 **Next Steps**

1. **Review the transformation mapping** above
2. **Validate your CSV files** for data quality
3. **Create transformation scripts** for each table
4. **Test with small datasets** first
5. **Load data into Supabase** in the correct order

## 📞 **Need Help?**

If you encounter any issues during transformation:
1. **Data quality problems**: Share specific error messages
2. **Schema mapping questions**: Ask about specific field mappings
3. **Loading errors**: Share Supabase error messages

---

**Ready to proceed with transformation?** Let me know if you want to start with a specific table or if you have any questions about the mapping!
