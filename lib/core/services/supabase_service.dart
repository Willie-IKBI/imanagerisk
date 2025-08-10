import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_config.dart';

/// Service class for managing Supabase client and operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._internal();
  
  SupabaseService._internal();
  
  /// Check if Supabase is initialized
  static bool get isInitialized {
    try {
      // Try to access the client - if it throws an exception, it's not initialized
      final client = Supabase.instance.client;
      // Simple check to ensure the client is accessible
      return client != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    try {
      if (EnvConfig.isDevelopment) {
        print('🔧 Initializing Supabase...');
        print('🔗 URL: ${EnvConfig.supabaseUrl}');
        print('🔑 Anon Key: ${EnvConfig.supabaseAnonKey.substring(0, 20)}...');
      }
      
      // Validate environment variables
      if (!EnvConfig.validateEnvironment()) {
        throw Exception('Invalid environment configuration. Please check your Supabase keys.');
      }
      
      // Check if already initialized
      if (isInitialized) {
        if (EnvConfig.isDevelopment) {
          print('✅ Supabase already initialized');
        }
        return;
      }
      
      // Initialize Supabase
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        debug: EnvConfig.isDevelopment,
      );
      
      if (EnvConfig.isDevelopment) {
        print('✅ Supabase initialized successfully');
        print('🔗 URL: ${EnvConfig.supabaseUrl}');
        print('👤 Current user: ${currentUser?.email ?? 'None'}');
      }
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      print('🔍 Error type: ${e.runtimeType}');
      rethrow;
    }
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (!isInitialized) {
      throw Exception('Supabase is not initialized. Call SupabaseService.initialize() first.');
    }
    return Supabase.instance.client;
  }
  
  /// Get the current user
  static User? get currentUser {
    if (!isInitialized) return null;
    try {
      return client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if user is authenticated
  static bool get isAuthenticated {
    if (!isInitialized) return false;
    try {
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Get the current session
  static Session? get currentSession {
    if (!isInitialized) return null;
    try {
      return client.auth.currentSession;
    } catch (e) {
      return null;
    }
  }
  
  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (EnvConfig.isDevelopment) {
        print('✅ User signed in successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Sign in failed: $e');
      }
      rethrow;
    }
  }
  
  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      if (EnvConfig.isDevelopment) {
        print('🔐 Attempting to sign up user: $email');
        print('📊 Data: $data');
      }
      
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      if (EnvConfig.isDevelopment) {
        print('✅ User signed up successfully: ${response.user?.email}');
        print('📧 Email confirmation required: ${response.user?.emailConfirmedAt == null}');
        print('🔑 Session: ${response.session != null ? 'Created' : 'Not created'}');
      }
      
      // Check if email confirmation is required
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        if (EnvConfig.isDevelopment) {
          print('📧 Email confirmation required for user: ${response.user!.email}');
        }
      }
      
      return response;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Sign up failed: $e');
        print('🔍 Error type: ${e.runtimeType}');
        print('🔍 Error details: $e');
      }
      rethrow;
    }
  }
  
  /// Sign out
  static Future<void> signOut() async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      await client.auth.signOut();
      
      if (EnvConfig.isDevelopment) {
        print('✅ User signed out successfully');
      }
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Sign out failed: $e');
      }
      rethrow;
    }
  }
  
  /// Reset password
  static Future<void> resetPassword({required String email}) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      await client.auth.resetPasswordForEmail(email);
      
      if (EnvConfig.isDevelopment) {
        print('✅ Password reset email sent to: $email');
      }
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Password reset failed: $e');
      }
      rethrow;
    }
  }
  
  /// Update user profile
  static Future<UserResponse> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final response = await client.auth.updateUser(
        UserAttributes(
          data: data,
        ),
      );
      
      if (EnvConfig.isDevelopment) {
        print('✅ User profile updated successfully');
      }
      
      return response;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Profile update failed: $e');
      }
      rethrow;
    }
  }
  
  /// Get user profile from database
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final user = currentUser;
      if (user == null) return null;
      
      final response = await client
          .from('employees')
          .select()
          .eq('id', user.id)
          .single();
      
      return response;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Failed to get user profile: $e');
      }
      return null;
    }
  }
  
  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    if (!isInitialized) {
      return Stream.empty();
    }
    try {
      return client.auth.onAuthStateChange;
    } catch (e) {
      return Stream.empty();
    }
  }
  
  /// Check if user has specific role
  static Future<bool> hasRole(String role) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final profile = await getUserProfile();
      if (profile == null) return false;
      
      return profile['role'] == role;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Failed to check user role: $e');
      }
      return false;
    }
  }
  
  /// Check if user has any of the specified roles
  static Future<bool> hasAnyRole(List<String> roles) async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final profile = await getUserProfile();
      if (profile == null) return false;
      
      final userRole = profile['role'] as String?;
      if (userRole == null) return false;
      
      return roles.contains(userRole);
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Failed to check user roles: $e');
      }
      return false;
    }
  }
  
  /// Get user's role
  static Future<String?> getUserRole() async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      final profile = await getUserProfile();
      return profile?['role'] as String?;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Failed to get user role: $e');
      }
      return null;
    }
  }

  /// Test Supabase connection
  static Future<bool> testConnection() async {
    try {
      // Ensure Supabase is initialized
      if (!isInitialized) {
        await initialize();
      }
      
      // Test a simple query
      final response = await client.from('policy_types').select().limit(1);
      print('✅ Supabase connection test successful');
      return true;
    } catch (e) {
      print('❌ Supabase connection test failed: $e');
      return false;
    }
  }
}
