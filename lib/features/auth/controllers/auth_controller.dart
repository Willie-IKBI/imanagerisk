import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/env/env_config.dart';

/// Authentication state notifier
class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController() : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Initialize the auth controller
  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    try {
      // Try to initialize Supabase if not already initialized
      if (!SupabaseService.isInitialized) {
        if (EnvConfig.isDevelopment) {
          print('🔧 AuthController: Initializing Supabase...');
        }
        await SupabaseService.initialize();
      }
      
      // Get current user
      final user = SupabaseService.currentUser;
      state = AsyncValue.data(user);
      
      // Listen to auth state changes
      SupabaseService.authStateChanges.listen((authState) {
        if (!state.hasError) {
          state = AsyncValue.data(authState.session?.user);
        }
      });
    } catch (e, stackTrace) {
      if (EnvConfig.isDevelopment) {
        print('❌ AuthController: Initialization failed');
        print('🔍 Error: $e');
        print('🔍 Stack trace: $stackTrace');
      }
      
      // Instead of throwing an error, set the state to data(null) to allow the app to continue
      // This prevents the app from showing an error screen when Supabase is just not ready yet
      state = const AsyncValue.data(null);
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      if (EnvConfig.isDevelopment) {
        print('🔐 AuthController: Attempting to sign in user: $email');
      }
      
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        if (EnvConfig.isDevelopment) {
          print('✅ AuthController: Sign in successful for ${response.user?.email}');
        }
        state = AsyncValue.data(response.user);
      } else {
        throw Exception('Sign in failed: No user returned');
      }
    } catch (e, stackTrace) {
      if (EnvConfig.isDevelopment) {
        print('❌ AuthController: Sign in failed');
        print('🔍 Error: $e');
        print('🔍 Stack trace: $stackTrace');
      }
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (EnvConfig.isDevelopment) {
        print('🔐 AuthController: Starting sign up process for $email');
      }
      
      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );
      
      if (response.user != null) {
        if (EnvConfig.isDevelopment) {
          print('✅ AuthController: Sign up successful for ${response.user?.email}');
          print('📧 Email confirmation required: ${response.user?.emailConfirmedAt == null}');
        }
        
        // Check if email confirmation is required
        if (response.user!.emailConfirmedAt == null) {
          if (EnvConfig.isDevelopment) {
            print('📧 Email confirmation required - user will need to confirm email before signing in');
          }
          // Don't set the user state if email confirmation is required
          // The user should confirm their email first
          state = const AsyncValue.data(null);
        } else {
          // Email already confirmed, set the user state
          state = AsyncValue.data(response.user);
        }
      } else {
        throw Exception('Sign up failed: No user returned');
      }
    } catch (e, stackTrace) {
      if (EnvConfig.isDevelopment) {
        print('❌ AuthController: Sign up failed');
        print('🔍 Error: $e');
        print('🔍 Stack trace: $stackTrace');
      }
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await SupabaseService.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => state.value;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await SupabaseService.getUserProfile();
    } catch (e) {
      return null;
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(String role) async {
    try {
      return await SupabaseService.hasRole(role);
    } catch (e) {
      return false;
    }
  }

  /// Check if user has any of the specified roles
  Future<bool> hasAnyRole(List<String> roles) async {
    try {
      return await SupabaseService.hasAnyRole(roles);
    } catch (e) {
      return false;
    }
  }

  /// Retry initialization
  Future<void> retryInitialization() async {
    await _initialize();
  }
}

/// Provider for the auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>(
  (ref) => AuthController(),
);

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).value;
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
