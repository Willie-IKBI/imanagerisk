# Testing Guide for IMR Supabase Setup

This guide will help you test the Supabase configuration and ensure everything is working correctly.

## 🎯 Quick Test Options

### Option 1: Run the Flutter App (Recommended)

1. **Start the app**:
   ```bash
   flutter run
   ```

2. **Test the connection**:
   - The app will show a "Supabase Connection Test" card
   - Click the "Test Supabase Connection" button
   - Check the results displayed on screen

### Option 2: Run Unit Tests

1. **Run all tests**:
   ```bash
   flutter test
   ```

2. **Run specific Supabase tests**:
   ```bash
   flutter test test/supabase_test.dart
   ```

### Option 3: Standalone Test Script

1. **Run the standalone test**:
   ```bash
   dart test_supabase.dart
   ```

## 🔍 What to Test

### 1. Environment Configuration

✅ **Environment variables are set**:
- Supabase URL is configured
- Anon key is configured
- Service key is configured (optional)

✅ **Environment validation passes**:
- All required variables are present
- Variables are in correct format

### 2. Supabase Connection

✅ **Client initialization**:
- Supabase client can be created
- No initialization errors

✅ **Database connectivity**:
- Can connect to Supabase database
- Can query tables (e.g., `policy_types`)

✅ **Authentication**:
- Auth system is accessible
- Can check user status

### 3. App Integration

✅ **Flutter integration**:
- App starts without errors
- Supabase service is accessible
- UI components work correctly

## 🚨 Common Issues and Solutions

### Issue 1: "Invalid URL" Error

**Symptoms**: `Invalid URL` or `Connection failed` errors

**Solutions**:
1. Check if the Supabase URL is correct
2. Ensure the URL starts with `https://`
3. Verify the project reference in the URL

### Issue 2: "Invalid Key" Error

**Symptoms**: `Invalid API key` or authentication errors

**Solutions**:
1. Verify the anon key is copied correctly
2. Ensure the key starts with `eyJ`
3. Check if the key is from the correct project

### Issue 3: "Table not found" Error

**Symptoms**: `relation "policy_types" does not exist`

**Solutions**:
1. Run the database schema: `supabase/schema.sql`
2. Check if tables are created in Supabase dashboard
3. Verify RLS policies are set up

### Issue 4: Network Issues

**Symptoms**: `Connection timeout` or `Network error`

**Solutions**:
1. Check internet connectivity
2. Verify firewall settings
3. Try from different network

## 📊 Expected Test Results

### Successful Test Output

```
🚀 Testing Supabase Connection...
✅ Supabase initialized successfully
✅ Supabase client obtained
✅ Database query successful
📊 Found 2 policy types
ℹ️ No user authenticated (this is expected)
🎉 All tests passed! Supabase is working correctly.
```

### Environment Variables Check

```
Environment Variables:
- SUPABASE_URL: https://your-project.supabase.co
- SUPABASE_ANON_KEY: [YOUR_ANON_KEY_HERE]
- ENVIRONMENT: development
- APP_NAME: I Manage Risk
- APP_VERSION: 1.0.0
```

## 🔧 Manual Testing Steps

### Step 1: Verify Environment Setup

1. Check `lib/core/env/env_config.dart`:
   ```dart
   // Should return your actual Supabase URL
   print(EnvConfig.supabaseUrl);
   
   // Should return your actual anon key
   print(EnvConfig.supabaseAnonKey);
   ```

2. Run environment validation:
   ```dart
   print(EnvConfig.validateEnvironment()); // Should return true
   ```

### Step 2: Test Supabase Service

1. Test client initialization:
   ```dart
   final client = SupabaseService.client;
   print('Client initialized: ${client != null}');
   ```

2. Test database query:
   ```dart
   final response = await client.from('policy_types').select().limit(1);
   print('Query result: ${response.length} items');
   ```

### Step 3: Test Authentication

1. Check current user:
   ```dart
   final user = SupabaseService.currentUser;
   print('User: ${user?.email ?? 'Not authenticated'}');
   ```

2. Test sign-in (optional):
   ```dart
   try {
     final response = await SupabaseService.signInWithEmail(
       email: 'test@example.com',
       password: 'password123',
     );
     print('Sign-in successful: ${response.user?.email}');
   } catch (e) {
     print('Sign-in failed: $e');
   }
   ```

## 🎯 Next Steps After Testing

Once all tests pass:

1. **Start development**:
   - Begin building UI components
   - Implement authentication flows
   - Create data models

2. **Set up production**:
   - Configure production environment variables
   - Set up CI/CD pipeline
   - Deploy to production

3. **Monitor and maintain**:
   - Set up logging and monitoring
   - Regular security audits
   - Performance optimization

## 📞 Support

If you encounter issues:

1. **Check the logs**: Look for detailed error messages
2. **Verify configuration**: Double-check URLs and keys
3. **Test connectivity**: Ensure network access to Supabase
4. **Review documentation**: Check Supabase docs for specific errors

## 🔗 Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Supabase Dashboard](https://app.supabase.com)
- [Environment Setup Guide](ENVIRONMENT_SETUP.md)

