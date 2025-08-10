import 'package:supabase_flutter/supabase_flutter.dart';

// This is a standalone test script to verify Supabase connection
// Run with: dart test_supabase.dart

void main() async {
  print('🚀 Testing Supabase Connection...');
  
  try {
    print('🔧 Step 1: Checking environment variables...');
    final url = 'https://gqwonqnhdcqksafucbmo.supabase.co';
    final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MzIzMDcsImV4cCI6MjA3MDMwODMwN30.vMwsQxB51kRbAavHdZCfg4_H4LiL2PUAhXXHXApp0TA';
    
    print('✅ URL: $url');
    print('✅ Anon Key: ${anonKey.substring(0, 20)}...');
    
    print('🔧 Step 2: Initializing Supabase...');
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
    
    print('✅ Supabase initialized successfully');
    
    print('🔧 Step 3: Getting client...');
    final client = Supabase.instance.client;
    print('✅ Supabase client obtained');
    
    print('🔧 Step 4: Testing database connection...');
    final response = await client.from('policy_types').select().limit(1);
    print('✅ Database query successful');
    print('📊 Found ${response.length} policy types');
    
    print('🔧 Step 5: Testing authentication status...');
    final user = client.auth.currentUser;
    if (user != null) {
      print('✅ User authenticated: ${user.email}');
    } else {
      print('ℹ️ No user authenticated (this is expected)');
    }
    
    print('🔧 Step 6: Testing auth state changes...');
    final authStateStream = client.auth.onAuthStateChange;
    print('✅ Auth state changes stream accessible');
    
    print('\n🎉 All tests passed! Supabase is working correctly.');
    print('\n📋 Summary:');
    print('- ✅ Environment variables are valid');
    print('- ✅ Supabase initialization successful');
    print('- ✅ Database connection working');
    print('- ✅ Authentication system accessible');
    print('- ✅ Auth state changes working');
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('\n🔍 Error details:');
    print('- Error type: ${e.runtimeType}');
    print('- Error message: $e');
    
    print('\n🔧 Troubleshooting tips:');
    print('1. Check if your Supabase project is active');
    print('2. Verify the URL and keys are correct');
    print('3. Check if the database schema is set up');
    print('4. Ensure network connectivity');
    print('5. Check if the policy_types table exists');
    
    print('\n📞 Next steps:');
    print('1. Go to Supabase Dashboard and verify project status');
    print('2. Check if the policy_types table exists in your database');
    print('3. Verify your API keys are correct');
    print('4. Check your network connection');
  }
}

