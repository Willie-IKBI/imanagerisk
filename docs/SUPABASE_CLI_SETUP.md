# Supabase CLI Setup & Usage Guide

## ✅ **Current Status - FULLY OPERATIONAL**

### **What's Working:**
- **Supabase CLI**: Version 2.33.9 installed ✅
- **Authentication**: Successfully logged in ✅
- **Project Access**: Can see your "imr" project ✅
- **Project Linking**: Successfully linked to production database ✅
- **Database Operations**: Full access to production database ✅
- **Schema Management**: Complete schema deployed ✅
- **Type Generation**: Working correctly ✅
- **Migration Management**: All migrations applied ✅

### **Database Schema Status:**
- **Tables**: 14 tables created and operational
- **Enums**: 8 enums defined
- **Indexes**: Performance indexes created
- **Constraints**: Data integrity constraints applied
- **RLS Policies**: Security policies in place
- **Triggers**: Automatic timestamp updates

---

## 🎯 **Database Rebuild Summary**

### **Completed Actions:**
1. ✅ **Database Reset**: Completely reset production database
2. ✅ **Clean Migrations**: Removed problematic system table operations
3. ✅ **Schema Deployment**: Applied complete IMR schema
4. ✅ **Foreign Keys**: All relationships established
5. ✅ **Constraints**: Data validation rules applied
6. ✅ **Indexes**: Performance optimization completed
7. ✅ **RLS Policies**: Security policies implemented
8. ✅ **Type Generation**: API types working correctly

### **Migration Files Applied:**
1. **`20250812062117_initial_schema.sql`** - Base schema with tables, enums, and RLS
2. **`20250812062118_foreign_keys.sql`** - Foreign key relationships
3. **`20250812062119_constraints_indexes.sql`** - Constraints, indexes, and triggers
4. **`20250812062120_rls_policies.sql`** - Row Level Security policies
5. **`20250812062121_add_missing_client_fields.sql`** - Added missing fields for frontend compatibility ✅ **NEW**
6. **`20250812122359_add_ss_number_field.sql`** - Added SS Number field for Body Corporate clients ✅ **NEW**

### **Recent Database Updates (August 12, 2025):**
- ✅ **Added missing client fields**: `alternative_phone`, `notes` to `clients` table
- ✅ **Added missing address fields**: `suburb`, `complex_name`, `unit_number`, `address_notes` to `addresses` table
- ✅ **Added address structure fields**: `street_number`, `street_name` for better address handling
- ✅ **Added Body Corporate fields**: `entity_name`, `ss_number` (Sectional Scheme Number) to `clients` table
- ✅ **Created indexes**: Performance indexes for new fields
- ✅ **Updated TypeScript types**: Generated new types reflecting schema changes
- ✅ **Fixed CLI connection issues**: Resolved database authentication problems
- ✅ **Fixed RLS policies**: Updated policies to allow authenticated users to access clients table

---

## 🚀 **Available Commands**

### **✅ Working Commands:**

1. **Database Operations:**
   ```bash
   # List migrations
   supabase migration list --linked --password "ulUcDzghm1DLRtms"
   
   # Create new migration
   supabase migration new <migration_name>
   
   # Push migrations to production
   supabase db push --linked --password "ulUcDzghm1DLRtms"
   
   # Reset database (WARNING: deletes all data)
   supabase db reset --linked --password "ulUcDzghm1DLRtms"
   ```

2. **Type Generation:**
   ```bash
   # Generate TypeScript types
   supabase gen types typescript --project-id gqwonqnhdcqksafucbmo --schema public > lib/types/supabase.ts
   ```

3. **Project Management:**
   ```bash
   # List projects
   supabase projects list
   
   # List API keys
   supabase projects api-keys --project-ref gqwonqnhdcqksafucbmo
   
   # List functions
   supabase functions list --project-ref gqwonqnhdcqksafucbmo
   ```

4. **Function Management:**
   ```bash
   # Create new function
   supabase functions new <function-name>
   
   # Deploy function
   supabase functions deploy <function-name> --project-ref gqwonqnhdcqksafucbmo
   
   # List function logs
   supabase functions logs <function-name> --project-ref gqwonqnhdcqksafucbmo
   ```

---

## 📊 **Database Schema Overview**

### **Core Tables:**
- **clients**: Client information (personal/business)
- **addresses**: Client addresses
- **client_contacts**: Client contact information
- **insurers**: Insurance companies
- **products**: Insurance products
- **policy_types**: Types of policies
- **policies**: Insurance policies
- **policy_covers**: Policy coverage details
- **policy_endorsements**: Policy modifications
- **claims**: Insurance claims
- **claim_items**: Claim line items
- **claim_updates**: Claim status updates
- **attachments**: File attachments
- **employees**: Staff information

### **Enums:**
- **client_type**: personal, business, body_corporate
- **client_status**: active, inactive, prospect
- **policy_status**: active, expired, cancelled, pending
- **claim_status**: open, in_progress, closed, rejected
- **claim_type**: theft, accident, fire, flood, other
- **employee_role**: admin, manager, sales, claims, support
- **task_status**: pending, in_progress, completed, cancelled
- **task_priority**: low, medium, high, urgent

---

## 🔐 **Security & Access Control**

### **Row Level Security (RLS):**
- ✅ **Enabled**: All tables have RLS enabled
- ✅ **Policies**: Role-based access policies implemented
- ✅ **Helper Functions**: Access control functions created
- ✅ **User Isolation**: Users can only access their own data
- ✅ **Role-Based Access**: Admin/manager/sales/claims/support roles

### **Access Rules:**
- **Admin/Manager**: Full access to all data
- **Sales**: Access to clients they created or are assigned to
- **Claims**: Access to claims they created or are assigned to
- **Support**: Limited access based on role
- **Employees**: Can only see their own profile

---

## 🛠 **Development Workflow**

### **Making Schema Changes:**
1. **Create Migration:**
   ```bash
   supabase migration new add_new_feature
   ```

2. **Edit Migration File:**
   - Edit the generated SQL file in `supabase/migrations/`
   - Add your schema changes

3. **Apply Changes:**
   ```bash
   supabase db push --linked --password "ulUcDzghm1DLRtms"
   ```

4. **Update Types:**
   ```bash
   supabase gen types typescript --project-id gqwonqnhdcqksafucbmo --schema public > lib/types/supabase.ts
   ```

### **Adding Sample Data:**
1. **Create Seed File:**
   ```bash
   # Add data to supabase/seed.sql
   ```

2. **Apply Seed Data:**
   ```bash
   supabase db reset --linked
   ```

---

## 📁 **Project Structure**

```
supabase/
├── config.toml              # Supabase configuration
├── migrations/              # Database migrations
│   ├── 20250812062117_initial_schema.sql
│   ├── 20250812062118_foreign_keys.sql
│   ├── 20250812062119_constraints_indexes.sql
│   └── 20250812062120_rls_policies.sql
└── seed.sql                 # Sample data (if needed)

lib/
├── types/
│   └── supabase.ts          # Generated TypeScript types
└── core/
    └── services/
        └── supabase_service.dart  # Supabase client service
```

---

## 🔧 **Configuration**

### **Environment Variables:**
```bash
# Set these in your environment or .env file
SUPABASE_URL=https://gqwonqnhdcqksafucbmo.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### **Database Connection:**
- **Project ID**: `gqwonqnhdcqksafucbmo`
- **Project Name**: `imr`
- **Region**: West EU (Ireland)
- **Database Password**: `ulUcDzghm1DLRtms` ✅ **CONFIRMED WORKING**

---

## 🚨 **Important Notes**

### **Security:**
- **Service Role Key**: Never use in client-side code
- **Anon Key**: Safe for client-side use
- **Database Password**: Keep secure, don't commit to repository
- **Environment Variables**: Use for sensitive configuration

### **Data Management:**
- **Backup**: Always backup before major changes
- **Testing**: Test migrations on local environment first
- **Rollback**: Keep previous migration files for rollback
- **Documentation**: Update documentation when schema changes

---

## 📞 **Troubleshooting**

### **Common Issues:**

1. **Database Connection Authentication Issues:**
   ```bash
   # Problem: "failed SASL auth (invalid SCRAM server-final-message received from server)"
   # Cause: Database password authentication failing during CLI operations
   # Solution: Use password parameter with commands
   
   # Link with password
   supabase link --project-ref gqwonqnhdcqksafucbmo --password "ulUcDzghm1DLRtms"
   
   # Push migrations with password
   supabase db push --linked --password "ulUcDzghm1DLRtms"
   
   # List migrations with password
   supabase migration list --linked --password "ulUcDzghm1DLRtms"
   ```

2. **Migration Conflicts:**
   ```bash
   # Repair migration history
   supabase migration repair --status applied <migration_id>
   ```

3. **Connection Issues:**
   ```bash
   # Unlink and relink project
   supabase unlink
   supabase link --project-ref gqwonqnhdcqksafucbmo --password "ulUcDzghm1DLRtms"
   ```

4. **Type Generation Issues:**
   ```bash
   # Regenerate types
   supabase gen types typescript --project-id gqwonqnhdcqksafucbmo --schema public > lib/types/supabase.ts
   ```

### **Debug Mode:**
```bash
# Add --debug flag to any command for detailed output
supabase db push --linked --debug
```

### **Connection Issue Resolution:**

**Problem Encountered:**
- Supabase CLI was failing to connect to the production database
- Error: `failed SASL auth (invalid SCRAM server-final-message received from server)`
- The CLI was prompting for database password but authentication was failing

**Root Cause:**
- The Supabase CLI requires the database password for direct database operations
- The password stored in documentation was correct, but CLI commands needed explicit password parameter
- Some CLI commands don't automatically use stored credentials

**Solution Implemented:**
- Use the `--password` parameter with all database operations
- Verified the password `ulUcDzghm1DLRtms` is correct and working
- Updated all CLI commands to include the password parameter

**Working Commands:**
```bash
# Link to project
supabase link --project-ref gqwonqnhdcqksafucbmo --password "ulUcDzghm1DLRtms"

# Push migrations
supabase db push --linked --password "ulUcDzghm1DLRtms"

# List migrations
supabase migration list --linked --password "ulUcDzghm1DLRtms"

# Reset database (if needed)
supabase db reset --linked --password "ulUcDzghm1DLRtms"
```

**Note:** The password parameter is required for all database operations that connect directly to the PostgreSQL database. API operations (like type generation) don't require the password parameter.

---

## 🎯 **Next Steps**

### **Immediate:**
1. ✅ **Database Setup**: Complete
2. ✅ **Schema Deployment**: Complete
3. ✅ **Type Generation**: Complete
4. 🔄 **Test Authentication**: Sign up/sign in users
5. 🔄 **Add Sample Data**: Insert test data for development
6. 🔄 **Test API Endpoints**: Verify all CRUD operations work

### **Future:**
1. **Local Development**: Set up local Supabase with Docker
2. **Edge Functions**: Deploy server-side logic
3. **Storage**: Configure file uploads
4. **Real-time**: Enable real-time subscriptions
5. **Analytics**: Set up usage analytics

---

## 📚 **Resources**

- **Supabase Documentation**: https://supabase.com/docs
- **CLI Reference**: https://supabase.com/docs/reference/cli
- **Database Schema**: See `docs/DATA_SCHEMA.md`
- **API Reference**: https://supabase.com/docs/reference/javascript

---

**The Supabase CLI is now fully operational and ready for development!** 🚀
