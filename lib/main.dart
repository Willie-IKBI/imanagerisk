import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/env/env_config.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'theme/theme.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Add web-specific error handling
  if (kIsWeb) {
    // Suppress web-specific warnings that are not critical
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('No Overlay widget found') ||
          details.exception.toString().contains('Cannot get renderObject of inactive element')) {
        // Log but don't crash for these web-specific issues
        print('Web-specific warning: ${details.exception}');
        return;
      }
      // Let other errors through to the normal error handling
      FlutterError.presentError(details);
    };
  }

  runApp(
    const ProviderScope(
      child: IMRApp(),
    ),
  );
}

class IMRApp extends ConsumerWidget {
  const IMRApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    // Add debugging to see the provider state
    if (EnvConfig.isDevelopment) {
      print('🔍 Main: authState = $authState');
      print('🔍 Main: authState.hasValue = ${authState.hasValue}');
      print('🔍 Main: authState.hasError = ${authState.hasError}');
      print('🔍 Main: authState.isLoading = ${authState.isLoading}');
      print('🔍 Main: authState.value = ${authState.value}');
    }

    return MaterialApp.router(
      title: EnvConfig.appName,
      theme: IMRTheme.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Watch the auth state in the builder to ensure it rebuilds
        final authStateInBuilder = ref.watch(authControllerProvider);
        
        if (EnvConfig.isDevelopment) {
          print('🔍 Builder: authState = $authStateInBuilder');
          print('🔍 Builder: authState.isLoading = ${authStateInBuilder.isLoading}');
        }
        
        // Direct state check without OverlayEntry
        if (EnvConfig.isDevelopment) {
          print('🔍 Builder: Checking auth state');
          print('🔍 Builder: authStateInBuilder.isLoading = ${authStateInBuilder.isLoading}');
          print('🔍 Builder: authStateInBuilder.hasError = ${authStateInBuilder.hasError}');
          print('🔍 Builder: authStateInBuilder.hasValue = ${authStateInBuilder.hasValue}');
        }
        
        if (authStateInBuilder.isLoading) {
          if (EnvConfig.isDevelopment) {
            print('🔍 Builder: Showing loading screen');
          }
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        } else if (authStateInBuilder.hasError) {
          if (EnvConfig.isDevelopment) {
            print('🔍 Builder: Showing error screen');
          }
          final error = authStateInBuilder.error;
          final stackTrace = authStateInBuilder.stackTrace;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Authentication Error',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Retry initialization
                        ref.read(authControllerProvider.notifier).retryInitialization();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Data state
          final user = authStateInBuilder.value;
          if (EnvConfig.isDevelopment) {
            print('🔍 Builder: Rendering data state - User = ${user?.email ?? 'null'}');
          }
          if (user != null) {
            if (EnvConfig.isDevelopment) {
              print('🔍 Builder: User is authenticated, showing dashboard');
            }
            return child!;
          } else {
            if (EnvConfig.isDevelopment) {
              print('🔍 Builder: No user, showing SignInScreen');
            }
            return const SignInScreen();
          }
        }
      },
    );
  }
}
