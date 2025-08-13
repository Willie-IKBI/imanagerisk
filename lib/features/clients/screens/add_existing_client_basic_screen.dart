import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/imr_button.dart';
import '../../../shared/widgets/imr_text_field.dart';
import '../widgets/step_indicator.dart';
import '../widgets/progress_bar.dart';
import '../controllers/add_existing_client_controller.dart';
import '../widgets/client_type_selector.dart';
import '../../../core/navigation/app_router.dart';

class AddExistingClientBasicScreen extends ConsumerStatefulWidget {
  const AddExistingClientBasicScreen({super.key});

  @override
  ConsumerState<AddExistingClientBasicScreen> createState() => _AddExistingClientBasicScreenState();
}

class _AddExistingClientBasicScreenState extends ConsumerState<AddExistingClientBasicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToError() {
    if (!_mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleNext() {
    if (!_mounted) return;
    
    if (_formKey.currentState?.validate() == true) {
      AddExistingClientNavigation.goToAddress(context);
    } else {
      _scrollToError();
    }
  }

  void _handleBack() {
    if (!_mounted) return;
    AddExistingClientNavigation.goToType(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(addExistingClientControllerProvider.notifier);
    final state = ref.watch(addExistingClientControllerProvider);
    final formData = state.formData;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Existing Client',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    StepIndicator(
                      currentStep: 2,
                      totalSteps: 6,
                      steps: const [
                        'Type',
                        'Basic Info',
                        'Address',
                        'Contacts',
                        'Review',
                        'Success',
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      progress: state.completionPercentage,
                      lastSaved: state.lastSaved,
                      isSaving: state.isSaving,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Client Type Display
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Client Type',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      formData.clientType?.icon ?? Icons.person,
                                      color: const Color(0xFFF57C00),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formData.clientType?.displayName ?? 'Not selected',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            formData.clientType?.subtitle ?? '',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/add-existing-client/type'),
                                      child: const Text('Change'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Basic Information Form
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basic Information',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Personal/Business/Body Corporate specific fields
                                if (formData.clientType == ClientType.personal) ...[
                                  // Personal Client Fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'First Name',

                                          onChanged: (value) => controller.updateFirstName(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'First name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'Last Name',

                                          onChanged: (value) => controller.updateLastName(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Last name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  IMRTextField(
                                    label: 'ID Number',

                                    onChanged: (value) => controller.updateIdNumber(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'ID number is required';
                                      }
                                      // Basic SA ID validation (13 digits)
                                      if (!RegExp(r'^\d{13}$').hasMatch(value.trim())) {
                                        return 'ID number must be 13 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                ] else if (formData.clientType == ClientType.business) ...[
                                  // Business Fields
                                  IMRTextField(
                                    label: 'Company Name',

                                    onChanged: (value) => controller.updateCompanyName(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Company name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  IMRTextField(
                                    label: 'Registration Number',

                                    onChanged: (value) => controller.updateRegistrationNumber(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Registration number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  IMRTextField(
                                    label: 'VAT Number',

                                    onChanged: (value) => controller.updateVatNumber(value),
                                    validator: (value) {
                                      if (value != null && value.trim().isNotEmpty) {
                                        // Basic VAT validation (10 digits starting with 4)
                                        if (!RegExp(r'^4\d{9}$').hasMatch(value.trim())) {
                                          return 'VAT number must be 10 digits starting with 4';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ] else if (formData.clientType == ClientType.bodyCorporate) ...[
                                  // Body Corporate Fields
                                  IMRTextField(
                                    label: 'Entity Name',

                                    onChanged: (value) => controller.updateEntityName(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Entity name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                                                     IMRTextField(
                                     label: 'Sectional Scheme Number',

                                     onChanged: (value) => controller.updateSsNumber(value),
                                     validator: (value) {
                                       if (value == null || value.trim().isEmpty) {
                                         return 'Sectional scheme number is required';
                                       }
                                       // Basic SS number validation (alphanumeric)
                                       if (!RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(value.trim())) {
                                         return 'Sectional scheme number can only contain letters, numbers, and hyphens';
                                       }
                                       return null;
                                     },
                                   ),
                                ],

                                const SizedBox(height: 24),

                                // Common fields for all client types
                                Text(
                                  'Contact Information',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: IMRTextField(
                                        label: 'Email',
        
                                        onChanged: (value) => controller.updateEmail(value),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Email is required';
                                          }
                                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                            return 'Please enter a valid email address';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: IMRTextField(
                                        label: 'Phone Number',
        
                                        onChanged: (value) => controller.updatePhoneNumber(value),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Phone number is required';
                                          }
                                          // Basic SA phone validation
                                          if (!RegExp(r'^(\+27|0)[6-8][0-9]{8}$').hasMatch(value.trim())) {
                                            return 'Please enter a valid SA phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                IMRTextField(
                                  label: 'Alternative Phone (Optional)',
  
                                  onChanged: (value) => controller.updateAlternativePhone(value),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value != null && value.trim().isNotEmpty) {
                                      if (!RegExp(r'^(\+27|0)[6-8][0-9]{8}$').hasMatch(value.trim())) {
                                        return 'Please enter a valid SA phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Additional Information
                                Text(
                                  'Additional Information',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                IMRTextField(
                                  label: 'Notes (Optional)',
  
                                  onChanged: (value) => controller.updateNotes(value),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IMRButton(
                        text: 'Back',
                        type: IMRButtonType.secondary,
                        onPressed: _handleBack,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IMRButton(
                        text: 'Next: Address',
                        onPressed: _handleNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
