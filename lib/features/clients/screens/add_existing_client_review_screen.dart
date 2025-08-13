import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/imr_button.dart';
import '../widgets/step_indicator.dart';
import '../widgets/progress_bar.dart';
import '../services/client_service.dart';
import '../controllers/add_existing_client_controller.dart';
import '../widgets/client_type_selector.dart';

class AddExistingClientReviewScreen extends ConsumerStatefulWidget {
  const AddExistingClientReviewScreen({super.key});

  @override
  ConsumerState<AddExistingClientReviewScreen> createState() => _AddExistingClientReviewScreenState();
}

class _AddExistingClientReviewScreenState extends ConsumerState<AddExistingClientReviewScreen> {
  bool _isSaving = false;

  Future<void> _saveClient() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(addExistingClientControllerProvider.notifier);
      final state = ref.read(addExistingClientControllerProvider);
      final formData = state.formData;

      // Save client to database
      final savedClient = await ClientService.saveClient(formData);
      
      // Clear draft after successful save
      await controller.clearDraft();
      
      // Navigate to success screen
      if (mounted) {
        context.go('/add-existing-client/success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving client: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildInfoRow(String label, String? value, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label${isRequired ? ' *' : ''}:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not provided',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value != null ? Colors.white : Colors.white54,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(String title, Map<String, String?> addressData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFF57C00),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...addressData.entries.map((entry) {
          if (entry.value != null && entry.value!.isNotEmpty) {
            return _buildInfoRow(entry.key, entry.value);
          }
          return const SizedBox.shrink();
        }).where((widget) => widget != const SizedBox.shrink()),
      ],
    );
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
                            'Review & Save',
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
                      currentStep: 5,
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

              // Review content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client Type
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Basic Information
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Basic Information',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.go('/add-existing-client/basic'),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (formData.clientType == ClientType.personal) ...[
                                _buildInfoRow('First Name', formData.firstName, isRequired: true),
                                _buildInfoRow('Last Name', formData.lastName, isRequired: true),
                                _buildInfoRow('ID Number', formData.idNumber, isRequired: true),
                              ] else if (formData.clientType == ClientType.business) ...[
                                _buildInfoRow('Company Name', formData.companyName, isRequired: true),
                                _buildInfoRow('Registration Number', formData.registrationNumber, isRequired: true),
                                _buildInfoRow('VAT Number', formData.vatNumber),
                                                             ] else if (formData.clientType == ClientType.bodyCorporate) ...[
                                 _buildInfoRow('Entity Name', formData.entityName, isRequired: true),
                                 _buildInfoRow('Sectional Scheme Number', formData.ssNumber, isRequired: true),
                               ],

                              const SizedBox(height: 16),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 16),

                              _buildInfoRow('Email', formData.email, isRequired: true),
                              _buildInfoRow('Phone Number', formData.phoneNumber, isRequired: true),
                              _buildInfoRow('Alternative Phone', formData.alternativePhone),
                              if (formData.notes?.isNotEmpty == true) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow('Notes', formData.notes),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Address Information
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Address Information',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.go('/add-existing-client/address'),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (formData.addressType == 'physical' || formData.addressType == 'both') ...[
                                _buildAddressSection('Physical Address', {
                                  'Street Number': formData.physicalStreetNumber,
                                  'Street Name': formData.physicalStreetName,
                                  'Suburb': formData.physicalSuburb,
                                  'City': formData.physicalCity,
                                  'Province': formData.physicalProvince,
                                  'Postal Code': formData.physicalPostalCode,
                                }),
                                if (formData.addressType == 'both') const SizedBox(height: 16),
                              ],

                              if (formData.addressType == 'postal' || 
                                  (formData.addressType == 'both' && formData.hasDifferentPostalAddress)) ...[
                                _buildAddressSection('Postal Address', {
                                  'PO Box': formData.postalPoBox,
                                  'Suburb': formData.postalSuburb,
                                  'City': formData.postalCity,
                                  'Province': formData.postalProvince,
                                  'Postal Code': formData.postalPostalCode,
                                }),
                              ],

                              if (formData.complexName?.isNotEmpty == true || 
                                  formData.unitNumber?.isNotEmpty == true ||
                                  formData.addressNotes?.isNotEmpty == true) ...[
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 16),
                                _buildInfoRow('Complex/Building', formData.complexName),
                                _buildInfoRow('Unit/Suite', formData.unitNumber),
                                _buildInfoRow('Address Notes', formData.addressNotes),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Additional Contacts
                      if (formData.contacts.isNotEmpty) ...[
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Additional Contacts (${formData.contacts.length})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => context.go('/add-existing-client/contacts'),
                                      child: const Text('Edit'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                ...formData.contacts.map((contact) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (contact.position != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            contact.position!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                        if (contact.email != null || contact.phone != null) ...[
                                          const SizedBox(height: 8),
                                          if (contact.email != null)
                                            _buildInfoRow('Email', contact.email),
                                          if (contact.phone != null)
                                            _buildInfoRow('Phone', contact.phone),
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Save confirmation
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ready to Save',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'All required information has been collected. Review the details above and click "Save Client" to add this client to your system.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
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

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IMRButton(
                        text: 'Back',
                        type: IMRButtonType.secondary,
                        onPressed: _isSaving ? null : () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IMRButton(
                        text: _isSaving ? 'Saving...' : 'Save Client',
                        onPressed: _isSaving ? null : _saveClient,
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
