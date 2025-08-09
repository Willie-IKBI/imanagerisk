import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_config.dart';

/// Service class for managing Supabase client and operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._internal();
  
  SupabaseService._internal();
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    try {
      // Validate environment variables
      if (!EnvConfig.validateEnvironment()) {
        throw Exception('Invalid environment configuration. Please check your Supabase keys.');
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
      }
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get the current user
  static User? get currentUser => client.auth.currentUser;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  /// Get the current session
  static Session? get currentSession => client.auth.currentSession;
  
  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
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
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      if (EnvConfig.isDevelopment) {
        print('✅ User signed up successfully: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Sign up failed: $e');
      }
      rethrow;
    }
  }
  
  /// Sign out
  static Future<void> signOut() async {
    try {
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
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  /// Check if user has specific role
  static Future<bool> hasRole(String role) async {
    try {
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
      final profile = await getUserProfile();
      return profile?['role'] as String?;
    } catch (e) {
      if (EnvConfig.isDevelopment) {
        print('❌ Failed to get user role: $e');
      }
      return null;
    }
  }
}
