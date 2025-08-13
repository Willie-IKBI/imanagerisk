import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/auth/controllers/auth_controller.dart';

// Add Existing Client Flow Screens
import '../../features/clients/screens/add_existing_client_type_screen.dart';
import '../../features/clients/screens/add_existing_client_basic_screen.dart';
import '../../features/clients/screens/add_existing_client_address_screen.dart';
import '../../features/clients/screens/add_existing_client_contacts_screen.dart';
import '../../features/clients/screens/add_existing_client_review_screen.dart';
import '../../features/clients/screens/add_existing_client_success_screen.dart';

// Client Management Screens
import '../../features/clients/screens/client_list_screen.dart';
import '../../features/clients/screens/client_detail_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // This will be handled by the auth controller
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      
      // Main app shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavigation(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Add Existing Client Flow
          GoRoute(
            path: '/add-existing-client',
            name: 'add-existing-client',
            builder: (context, state) => const AddExistingClientTypeScreen(),
            routes: [
              GoRoute(
                path: 'type',
                name: 'add-existing-client-type',
                builder: (context, state) => const AddExistingClientTypeScreen(),
              ),
              GoRoute(
                path: 'basic',
                name: 'add-existing-client-basic',
                builder: (context, state) => const AddExistingClientBasicScreen(),
              ),
              GoRoute(
                path: 'address',
                name: 'add-existing-client-address',
                builder: (context, state) => const AddExistingClientAddressScreen(),
              ),
              GoRoute(
                path: 'contacts',
                name: 'add-existing-client-contacts',
                builder: (context, state) => const AddExistingClientContactsScreen(),
              ),
              GoRoute(
                path: 'review',
                name: 'add-existing-client-review',
                builder: (context, state) => const AddExistingClientReviewScreen(),
              ),
              GoRoute(
                path: 'success',
                name: 'add-existing-client-success',
                builder: (context, state) => const AddExistingClientSuccessScreen(),
              ),
            ],
          ),

          // Client Management
          GoRoute(
            path: '/clients',
            name: 'clients',
            builder: (context, state) => const ClientListScreen(),
          ),
          GoRoute(
            path: '/clients/:clientId',
            name: 'client-detail',
            builder: (context, state) {
              final clientId = state.pathParameters['clientId']!;
              return ClientDetailScreen(clientId: clientId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
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
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

class ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      // Add bottom navigation or side navigation here if needed
    );
  }
}

// Navigation helpers for the Add Existing Client flow
class AddExistingClientNavigation {
  static void goToType(BuildContext context) {
    context.go('/add-existing-client/type');
  }

  static void goToBasic(BuildContext context) {
    context.go('/add-existing-client/basic');
  }

  static void goToAddress(BuildContext context) {
    context.go('/add-existing-client/address');
  }

  static void goToContacts(BuildContext context) {
    context.go('/add-existing-client/contacts');
  }

  static void goToReview(BuildContext context) {
    context.go('/add-existing-client/review');
  }

  static void goToSuccess(BuildContext context) {
    context.go('/add-existing-client/success');
  }

  static void goToDashboard(BuildContext context) {
    context.go('/');
  }

  static void goBack(BuildContext context) {
    context.pop();
  }
}
