import 'package:supabase_flutter/supabase_flutter.dart';

// This is a standalone test script to verify Supabase connection
// Run with: dart test_supabase.dart

void main() async {
  print('🚀 Testing Supabase Connection...');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://gqwonqnhdcqksafucbmo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MzIzMDcsImV4cCI6MjA3MDMwODMwN30.vMwsQxB51kRbAavHdZCfg4_H4LiL2PUAhXXHXApp0TA',
    );
    
    print('✅ Supabase initialized successfully');
    
    // Get client
    final client = Supabase.instance.client;
    print('✅ Supabase client obtained');
    
    // Test database connection
    final response = await client.from('policy_types').select().limit(1);
    print('✅ Database query successful');
    print('📊 Found ${response.length} policy types');
    
    // Test authentication status
    final user = client.auth.currentUser;
    if (user != null) {
      print('✅ User authenticated: ${user.email}');
    } else {
      print('ℹ️ No user authenticated (this is expected)');
    }
    
    print('\n🎉 All tests passed! Supabase is working correctly.');
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('\n🔍 Troubleshooting tips:');
    print('1. Check if your Supabase project is active');
    print('2. Verify the URL and keys are correct');
    print('3. Check if the database schema is set up');
    print('4. Ensure network connectivity');
  }
}
