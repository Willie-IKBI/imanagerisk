import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/imr_button.dart';
import '../../../shared/widgets/imr_text_field.dart';
import '../../../shared/widgets/imr_dropdown.dart';
import '../widgets/step_indicator.dart';
import '../widgets/progress_bar.dart';
import '../controllers/add_existing_client_controller.dart';

class AddExistingClientAddressScreen extends ConsumerStatefulWidget {
  const AddExistingClientAddressScreen({super.key});

  @override
  ConsumerState<AddExistingClientAddressScreen> createState() => _AddExistingClientAddressScreenState();
}

class _AddExistingClientAddressScreenState extends ConsumerState<AddExistingClientAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                            'Address Information',
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
                      currentStep: 3,
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
                        // Address Type Selection
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address Type',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildAddressTypeButton(
                                        context,
                                        'Physical',
                                        Icons.home,
                                        formData.addressType == 'physical',
                                        () => controller.updateAddressType('physical'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildAddressTypeButton(
                                        context,
                                        'Postal',
                                        Icons.mail,
                                        formData.addressType == 'postal',
                                        () => controller.updateAddressType('postal'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildAddressTypeButton(
                                        context,
                                        'Both',
                                        Icons.location_on,
                                        formData.addressType == 'both',
                                        () => controller.updateAddressType('both'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Physical Address (if selected)
                        if (formData.addressType == 'physical' || formData.addressType == 'both') ...[
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.home, color: const Color(0xFFF57C00), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Physical Address',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  IMRTextField(
                                    label: 'Street Number',

                                    onChanged: (value) => controller.updatePhysicalStreetNumber(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Street number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  IMRTextField(
                                    label: 'Street Name',

                                    onChanged: (value) => controller.updatePhysicalStreetName(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Street name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'Suburb',
      
                                          onChanged: (value) => controller.updatePhysicalSuburb(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Suburb is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'City',
      
                                          onChanged: (value) => controller.updatePhysicalCity(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'City is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                                                             Expanded(
                                         child: IMRDropdown(
                                           label: 'Province',
                                           items: SAProvinces.getDropdownItems(),
                                           value: formData.physicalProvince,
                                           onChanged: (value) => controller.updatePhysicalProvince(value),
                                           validator: (value) {
                                             if (value == null || value.trim().isEmpty) {
                                               return 'Province is required';
                                             }
                                             return null;
                                           },
                                         ),
                                       ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'Postal Code',
      
                                          onChanged: (value) => controller.updatePhysicalPostalCode(value),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Postal code is required';
                                            }
                                            if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                                              return 'Postal code must be 4 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Postal Address (if selected and different from physical)
                        if (formData.addressType == 'postal' || 
                            (formData.addressType == 'both' && formData.hasDifferentPostalAddress)) ...[
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.mail, color: const Color(0xFFF57C00), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Postal Address',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  IMRTextField(
                                    label: 'PO Box Number',

                                    onChanged: (value) => controller.updatePostalPoBox(value),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'PO Box number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'Suburb',
      
                                          onChanged: (value) => controller.updatePostalSuburb(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Suburb is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'City',
      
                                          onChanged: (value) => controller.updatePostalCity(value),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'City is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                                                             Expanded(
                                         child: IMRDropdown(
                                           label: 'Province',
                                           items: SAProvinces.getDropdownItems(),
                                           value: formData.postalProvince,
                                           onChanged: (value) => controller.updatePostalProvince(value),
                                           validator: (value) {
                                             if (value == null || value.trim().isEmpty) {
                                               return 'Province is required';
                                             }
                                             return null;
                                           },
                                         ),
                                       ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: IMRTextField(
                                          label: 'Postal Code',
      
                                          onChanged: (value) => controller.updatePostalPostalCode(value),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return 'Postal code is required';
                                            }
                                            if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
                                              return 'Postal code must be 4 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Different postal address checkbox (only show if both addresses selected)
                        if (formData.addressType == 'both') ...[
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: formData.hasDifferentPostalAddress,
                                    onChanged: (value) => controller.updateHasDifferentPostalAddress(value ?? false),
                                    activeColor: const Color(0xFFF57C00),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Postal address is different from physical address',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Additional Address Information
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Additional Information',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                IMRTextField(
                                  label: 'Complex/Building Name (Optional)',
                                  
                                  onChanged: (value) => controller.updateComplexName(value),
                                ),
                                const SizedBox(height: 16),

                                IMRTextField(
                                  label: 'Unit/Suite Number (Optional)',
                                  
                                  onChanged: (value) => controller.updateUnitNumber(value),
                                ),
                                const SizedBox(height: 16),

                                IMRTextField(
                                  label: 'Address Notes (Optional)',
                                  
                                  onChanged: (value) => controller.updateAddressNotes(value),
                                  maxLines: 2,
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
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IMRButton(
                        text: 'Next: Contacts',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.go('/add-existing-client/contacts');
                          } else {
                            // Scroll to first error
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
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

  Widget _buildAddressTypeButton(
    BuildContext context,
    String text,
    IconData icon,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF57C00).withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C00) : Colors.white30,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFF57C00) : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? const Color(0xFFF57C00) : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
