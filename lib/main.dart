import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';
import 'core/env/env_config.dart';
import 'theme/theme.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    // Continue with the app even if Supabase fails to initialize
    // The auth controller will handle this error state
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    return MaterialApp(
      title: EnvConfig.appName,
      theme: IMRTheme.light,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen();
          } else {
            return const SignInScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Show more detailed error information in development
                      if (EnvConfig.isDevelopment) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error Details'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Error: ${error.toString()}'),
                                  const SizedBox(height: 8),
                                  Text('Stack Trace: ${stackTrace.toString()}'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Show Details'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
