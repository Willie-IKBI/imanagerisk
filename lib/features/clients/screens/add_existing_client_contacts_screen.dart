import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/imr_button.dart';
import '../../../shared/widgets/imr_text_field.dart';
import '../widgets/step_indicator.dart';
import '../widgets/progress_bar.dart';
import '../controllers/add_existing_client_controller.dart';

class AddExistingClientContactsScreen extends ConsumerStatefulWidget {
  const AddExistingClientContactsScreen({super.key});

  @override
  ConsumerState<AddExistingClientContactsScreen> createState() => _AddExistingClientContactsScreenState();
}

class _AddExistingClientContactsScreenState extends ConsumerState<AddExistingClientContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _contactNameController = TextEditingController();
  final _contactPositionController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _contactNameController.dispose();
    _contactPositionController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _clearContactForm() {
    _contactNameController.clear();
    _contactPositionController.clear();
    _contactEmailController.clear();
    _contactPhoneController.clear();
  }

  void _addContact() {
    if (_contactNameController.text.trim().isNotEmpty) {
      final contact = ContactData(
        name: _contactNameController.text.trim(),
        position: _contactPositionController.text.trim().isEmpty 
            ? null 
            : _contactPositionController.text.trim(),
        email: _contactEmailController.text.trim().isEmpty 
            ? null 
            : _contactEmailController.text.trim(),
        phone: _contactPhoneController.text.trim().isEmpty 
            ? null 
            : _contactPhoneController.text.trim(),
      );

      ref.read(addExistingClientControllerProvider.notifier).addContact(contact);
      _clearContactForm();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact "${contact.name}" added successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeContact(int index) {
    final contacts = ref.read(addExistingClientControllerProvider).formData.contacts;
    final contactName = contacts[index].name;
    
    ref.read(addExistingClientControllerProvider.notifier).removeContact(index);
    
    // Show removal message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact "$contactName" removed'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
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
                            'Additional Contacts',
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
                      currentStep: 4,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Information card
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: const Color(0xFFF57C00), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Additional Contacts',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add additional contacts for this client. This is optional but useful for business clients or when you need to contact someone other than the primary client.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Add new contact form
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Contact',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),

                              IMRTextField(
                                label: 'Contact Name *',
                                controller: _contactNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Contact name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: IMRTextField(
                                      label: 'Position (Optional)',
                                      controller: _contactPositionController,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: IMRTextField(
                                      label: 'Phone (Optional)',
                                      controller: _contactPhoneController,
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
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              IMRTextField(
                                label: 'Email (Optional)',
                                controller: _contactEmailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                      return 'Please enter a valid email address';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: IMRButton(
                                  text: 'Add Contact',
                                  onPressed: _addContact,
                                  type: IMRButtonType.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Existing contacts list
                      if (formData.contacts.isNotEmpty) ...[
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.people, color: const Color(0xFFF57C00), size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Added Contacts (${formData.contacts.length})',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                ...formData.contacts.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final contact = entry.value;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
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
                                        Row(
                                          children: [
                                            Expanded(
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
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _removeContact(index),
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              tooltip: 'Remove contact',
                                            ),
                                          ],
                                        ),
                                        if (contact.email != null || contact.phone != null) ...[
                                          const SizedBox(height: 8),
                                          if (contact.email != null) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.email, size: 16, color: Colors.white70),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    contact.email!,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (contact.phone != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 16, color: Colors.white70),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    contact.phone!,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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

                      // Skip option
                      if (formData.contacts.isEmpty) ...[
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.skip_next, color: Colors.orange, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No Additional Contacts',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You can skip this step if you don\'t need to add additional contacts. You can always add them later.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

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
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IMRButton(
                        text: 'Next: Review',
                        onPressed: () => context.go('/add-existing-client/review'),
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
