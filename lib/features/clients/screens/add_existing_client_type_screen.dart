import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/step_indicator.dart';
import '../widgets/client_type_selector.dart';
import '../controllers/add_existing_client_controller.dart';

class AddExistingClientTypeScreen extends ConsumerStatefulWidget {
  const AddExistingClientTypeScreen({super.key});

  @override
  ConsumerState<AddExistingClientTypeScreen> createState() => _AddExistingClientTypeScreenState();
}

class _AddExistingClientTypeScreenState extends ConsumerState<AddExistingClientTypeScreen> {
  ClientType? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F2F2F),
              Color(0xFF4A4A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Add Existing Client',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Step indicator
                StepIndicator(
                  currentStep: 1,
                  totalSteps: 5,
                  stepTitles: const [
                    'Type',
                    'Basic',
                    'Address',
                    'Contacts',
                    'Review',
                  ],
                ),
                const SizedBox(height: 32),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: ClientTypeSelector(
                      selectedType: selectedType,
                      onTypeSelected: (type) {
                        setState(() {
                          selectedType = type;
                        });
                      },
                    ),
                  ),
                ),
                
                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: IMRButton(
                        text: 'Cancel',
                        type: IMRButtonType.secondary,
                        onPressed: () => context.go('/'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IMRButton(
                        text: 'Continue',
                        onPressed: selectedType != null 
                            ? () => _handleContinue()
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (selectedType != null) {
      // Save the selected type to the controller
      ref.read(addExistingClientControllerProvider.notifier).setClientType(selectedType!);
      
      // Navigate to the next step
      context.go('/add-existing-client/basic');
    }
  }
}
