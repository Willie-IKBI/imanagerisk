# Supabase CLI Setup & Usage Guide

## ✅ **Current Status**

### **What's Working:**
- **Supabase CLI**: Version 2.33.9 installed ✅
- **Authentication**: Successfully logged in ✅
- **Project Access**: Can see your "imr" project ✅
- **Local Setup**: Supabase project initialized ✅
- **Type Generation**: Generated TypeScript types ✅

### **What's Not Working:**
- **Project Linking**: Database password authentication failing
- **Local Development**: Docker not running (required for local Supabase)

## 🔧 **Database Password Issue**

The password `uAFy4pbdtuM4Dd12` is not working for database authentication. This could be due to:

1. **Password Reset**: The password might have been reset recently
2. **Special Characters**: URL encoding issues
3. **Different Password**: The password might be different from what was copied

### **To Fix This:**

1. **Get Current Password:**
   - Go to: https://supabase.com/dashboard/project/gqwonqnhdcqksafucbmo/settings/database
   - Look for "Database Password" section
   - Copy the current password

2. **Reset Password (if needed):**
   - Click "Reset Database Password"
   - Set a new password you can remember

3. **Try Linking Again:**
   ```bash
   supabase link --project-ref gqwonqnhdcqksafucbmo
   ```

## 🚀 **What We Can Do Without Linking**

### **✅ Working Commands:**

1. **List Projects:**
   ```bash
   supabase projects list
   ```

2. **List Functions:**
   ```bash
   supabase functions list --project-ref gqwonqnhdcqksafucbmo
   ```

3. **Generate TypeScript Types:**
   ```bash
   supabase gen types typescript --project-id gqwonqnhdcqksafucbmo --schema public
   ```

4. **Deploy Functions:**
   ```bash
   supabase functions deploy <function-name> --project-ref gqwonqnhdcqksafucbmo
   ```

### **❌ Commands That Require Linking:**

1. **Database Operations:**
   - `supabase db pull` - Pull schema from remote
   - `supabase db push` - Push local changes to remote
   - `supabase migration new <name>` - Create new migrations

2. **Local Development:**
   - `supabase start` - Start local Supabase (requires Docker)
   - `supabase stop` - Stop local Supabase

3. **Storage Operations:**
   - `supabase storage ls` - List storage buckets
   - `supabase storage cp` - Copy files

## 📁 **Generated Files**

### **TypeScript Types:**
- **File**: `lib/types/supabase.ts`
- **Content**: Complete database schema types for all tables, views, functions, and enums
- **Usage**: Import in your Flutter/Dart code for type safety

### **Database Schema:**
- **Tables**: 14 tables including clients, policies, claims, employees, etc.
- **Views**: 3 views including client_summary, dashboard_stats, policy_summary
- **Functions**: 2 functions including generate_quote_number, get_client_full_name
- **Enums**: 7 enums for status fields

## 🎯 **Next Steps**

### **Immediate:**
1. **Get Correct Database Password** from Supabase dashboard
2. **Link Project** using the correct password
3. **Test Database Operations** like `supabase db pull`

### **Future:**
1. **Set Up Local Development** with Docker
2. **Create Database Migrations** for schema changes
3. **Deploy Edge Functions** for server-side logic
4. **Manage Storage** for file uploads

## 🔍 **Useful Commands**

### **Project Management:**
```bash
# List all projects
supabase projects list

# Get project details
supabase projects show --project-ref gqwonqnhdcqksafucbmo

# List project functions
supabase functions list --project-ref gqwonqnhdcqksafucbmo
```

### **Type Generation:**
```bash
# Generate TypeScript types
supabase gen types typescript --project-id gqwonqnhdcqksafucbmo --schema public > lib/types/supabase.ts

# Generate Dart types (if supported)
supabase gen types dart --project-id gqwonqnhdcqksafucbmo --schema public > lib/types/supabase.dart
```

### **Function Management:**
```bash
# Create new function
supabase functions new <function-name>

# Deploy function
supabase functions deploy <function-name> --project-ref gqwonqnhdcqksafucbmo

# List function logs
supabase functions logs <function-name> --project-ref gqwonqnhdcqksafucbmo
```

## 📊 **Database Schema Overview**

### **Core Tables:**
- **clients**: Client information (personal/business)
- **policies**: Insurance policies
- **claims**: Insurance claims
- **quotes**: Insurance quotes
- **leads**: Sales leads
- **tasks**: Task management
- **employees**: Staff information

### **Supporting Tables:**
- **insurers**: Insurance companies
- **products**: Insurance products
- **policy_types**: Types of policies
- **policy_covers**: Policy coverage details
- **policy_endorsements**: Policy modifications
- **quote_options**: Quote alternatives
- **renewals**: Policy renewals
- **interactions**: Communication history
- **client_contacts**: Client contact information
- **claim_updates**: Claim status updates

### **Views:**
- **client_summary**: Client overview with counts
- **policy_summary**: Policy overview with relationships
- **dashboard_stats**: Dashboard statistics

## 🔐 **Security Notes**

- **Service Role Key**: Never use in client-side code
- **Anon Key**: Safe for client-side use
- **Database Password**: Keep secure, don't commit to repository
- **Environment Variables**: Use for sensitive configuration

## 📞 **Support**

If you encounter issues:
1. Check Supabase documentation: https://supabase.com/docs
2. Use `--debug` flag for detailed error information
3. Check Supabase dashboard for project status
4. Verify network connectivity and firewall settings
