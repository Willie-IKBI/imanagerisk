import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../controllers/add_existing_client_controller.dart';

class AddExistingClientSuccessScreen extends ConsumerStatefulWidget {
  const AddExistingClientSuccessScreen({super.key});

  @override
  ConsumerState<AddExistingClientSuccessScreen> createState() => _AddExistingClientSuccessScreenState();
}

class _AddExistingClientSuccessScreenState extends ConsumerState<AddExistingClientSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger dashboard refresh when success screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardRefreshProvider.notifier).state++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Client Added Successfully!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Client ID: CL-001',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'What would you like to do next?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        IMRButton(
                          text: 'Add Policy for this Client',
                          onPressed: () {
                            // TODO: Navigate to add policy
                          },
                        ),
                        const SizedBox(height: 16),
                        IMRButton(
                          text: 'Add Another Client',
                          type: IMRButtonType.secondary,
                          onPressed: () {
                            // Clear form data and navigate to start
                            ref.read(addExistingClientControllerProvider.notifier).clearForm();
                            context.go('/add-existing-client');
                          },
                        ),
                        const SizedBox(height: 16),
                        IMRButton(
                          text: 'Go to Dashboard',
                          type: IMRButtonType.text,
                          onPressed: () {
                            // Clear form data and go to dashboard
                            ref.read(addExistingClientControllerProvider.notifier).clearForm();
                            context.go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
