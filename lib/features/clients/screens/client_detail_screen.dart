import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/client_list_providers.dart';
import '../services/client_service.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;
  
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  String? _error;



  // Address and Contact data
  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoadingAddresses = false;
  bool _isLoadingContacts = false;


  @override
  void initState() {
    super.initState();
    _loadAddressesAndContacts();
  }

  @override
  void didUpdateWidget(ClientDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clientId != widget.clientId) {
      _loadAddressesAndContacts();
    }
  }





  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, just show a message that editing is not implemented yet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Edit functionality coming soon'),
            backgroundColor: Theme.of(context).extension<IMRTokens>()!.brandOrange,
          ),
        );
      }
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClient() async {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.glassSurface,
        surfaceTintColor: Colors.transparent,
        title: Text('Delete Client', style: TextStyle(color: tokens.pureWhite)),
        content: Text(
          'Are you sure you want to delete this client? This action cannot be undone.',
          style: TextStyle(color: tokens.pureWhite.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: tokens.brandGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await ClientService.deleteClient(widget.clientId);
        ref.invalidate(allClientsProvider);
        ref.invalidate(dashboardStatsProvider);
        
        if (mounted) {
          context.go('/clients');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Client deleted successfully'),
              backgroundColor: tokens.success,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAddressesAndContacts() async {
    setState(() {
      _isLoadingAddresses = true;
      _isLoadingContacts = true;
    });

    try {
      final addresses = await ClientService.getClientAddresses(widget.clientId);
      final contacts = await ClientService.getClientContacts(widget.clientId);
      
      setState(() {
        _addresses = addresses;
        _contacts = contacts;
        _isLoadingAddresses = false;
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
        _isLoadingContacts = false;
      });
      // Error loading addresses and contacts
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F2F2F), Color(0xFF4A4A4A)],
          ),
        ),
        child: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final clientAsync = ref.watch(clientByIdProvider(widget.clientId));

              return clientAsync.when(
                data: (client) {
                  if (client == null) {
                    return Center(
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_off, size: 64, color: tokens.brandGrey),
                              const SizedBox(height: 16),
                              Text('Client not found', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: tokens.brandGrey)),
                              const SizedBox(height: 16),
                              IMRButton(text: 'Back to Client List', onPressed: () => context.go('/clients')),
                            ],
                          ),
                        ),
                      ),
                    );
                  }



                  return Column(
                    children: [
                      _buildHeader(context, tokens, isMobile),
                      if (_error != null) ...[
                        _buildErrorCard(tokens),
                        const SizedBox(height: 16),
                      ],
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          child: Column(
                            children: [
                              _buildClientOverview(context, client, tokens, isMobile),
                              const SizedBox(height: 24),
                              _buildClientDetails(context, client, tokens, isMobile),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(context, tokens, error),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, tokens, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/clients'),
            icon: Icon(Icons.arrow_back, color: tokens.pureWhite),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Client' : 'Client Details',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: tokens.pureWhite,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!_isEditing) ...[
            IMRButton(
              text: 'Edit',
              type: IMRButtonType.secondary,
              onPressed: () {
                if (mounted) {
                  setState(() => _isEditing = true);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: tokens.error),
              const SizedBox(width: 12),
              Expanded(child: Text(_error!, style: TextStyle(color: tokens.error))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientOverview(BuildContext context, Map<String, dynamic> client, tokens, bool isMobile) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tokens.brandOrange,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  _getClientInitials(client),
                  style: TextStyle(color: tokens.pureWhite, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              _getClientDisplayName(client),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Type
            Text(
              _getClientTypeDisplay(client['client_type']),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.brandOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            // Contact Info - Using Column instead of Row
            Column(
              children: [
                // Email
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.glassSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email, color: tokens.brandOrange, size: 16),
                          const SizedBox(width: 8),
                          Text('Email', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tokens.pureWhite.withValues(alpha: 0.7))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client['email'] ?? 'Not provided',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.pureWhite, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Phone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.glassSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, color: tokens.brandOrange, size: 16),
                          const SizedBox(width: 8),
                          Text('Phone', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tokens.pureWhite.withValues(alpha: 0.7))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client['phone'] ?? 'Not provided',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens.pureWhite, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDetails(BuildContext context, Map<String, dynamic> client, tokens, bool isMobile) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
                         // Client type specific fields
             if (client['client_type'] == 'personal') ...[
               _buildFormField('First Name', client['first_name'] ?? '', enabled: _isEditing),
               _buildFormField('Last Name', client['last_name'] ?? '', enabled: _isEditing),
               _buildFormField('ID Number', client['id_number'] ?? '', enabled: _isEditing),
             ] else if (client['client_type'] == 'business') ...[
               _buildFormField('Company Name', client['company_name'] ?? '', enabled: _isEditing),
               _buildFormField('Registration Number', client['registration_number'] ?? '', enabled: _isEditing),
               _buildFormField('VAT Number', client['vat_number'] ?? '', enabled: _isEditing),
             ] else if (client['client_type'] == 'bodyCorporate') ...[
               _buildFormField('Entity Name', client['entity_name'] ?? '', enabled: _isEditing),
               _buildFormField('SS Number', client['ss_number'] ?? '', enabled: _isEditing),
             ],
             
             // Common fields
             _buildFormField('Email', client['email'] ?? '', enabled: _isEditing),
             _buildFormField('Phone', client['phone'] ?? '', enabled: _isEditing),
             _buildFormField('Alternative Phone', client['alternative_phone'] ?? '', enabled: _isEditing),
             _buildFormField('Notes', client['notes'] ?? '', enabled: _isEditing, maxLines: 3),
            
            const SizedBox(height: 24),
            
            // Addresses Section
            _buildAddressesSection(context, tokens, isMobile),
            
            const SizedBox(height: 24),
            
            // Contacts Section
            _buildContactsSection(context, tokens, isMobile),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            if (_isEditing) ...[
              _buildActionButtons(context, tokens, isMobile),
            ] else ...[
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: IMRButton(
                      text: 'Edit Client',
                      type: IMRButtonType.secondary,
                      onPressed: () {
                        if (mounted) {
                          setState(() => _isEditing = true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: IMRButton(
                      text: 'Delete Client',
                      type: IMRButtonType.secondary,
                      onPressed: _isLoading ? null : _deleteClient,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value, {bool enabled = false, int maxLines = 1}) {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.pureWhite.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled ? tokens.glassSurface.withValues(alpha: 0.1) : tokens.glassSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.3)),
            ),
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: enabled ? tokens.pureWhite : tokens.pureWhite.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, tokens, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: tokens.brandOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Addresses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_isEditing) ...[
              IconButton(
                onPressed: _addNewAddress,
                icon: Icon(Icons.add, color: tokens.brandOrange),
                tooltip: 'Add Address',
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoadingAddresses) ...[
          const Center(child: CircularProgressIndicator()),
        ] else if (_addresses.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.glassSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No addresses found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.pureWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          ..._addresses.map((address) => _buildAddressCard(context, address, tokens, isMobile)),
        ],
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> address, tokens, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.glassSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                address['address_type'] == 'physical' ? Icons.home : Icons.mail,
                color: tokens.brandOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                address['address_type'] == 'physical' ? 'Physical Address' : 'Postal Address',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isEditing) ...[
                IconButton(
                  onPressed: () => _editAddress(address),
                  icon: Icon(Icons.edit, color: tokens.brandOrange, size: 16),
                  tooltip: 'Edit Address',
                ),
                IconButton(
                  onPressed: () => _deleteAddress(address['id']),
                  icon: Icon(Icons.delete, color: tokens.error, size: 16),
                  tooltip: 'Delete Address',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatAddress(address),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.pureWhite.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(BuildContext context, tokens, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: tokens.brandOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Contacts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_isEditing) ...[
              IconButton(
                onPressed: _addNewContact,
                icon: Icon(Icons.add, color: tokens.brandOrange),
                tooltip: 'Add Contact',
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoadingContacts) ...[
          const Center(child: CircularProgressIndicator()),
        ] else if (_contacts.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.glassSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No contacts found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.pureWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          ..._contacts.map((contact) => _buildContactCard(context, contact, tokens, isMobile)),
        ],
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, Map<String, dynamic> contact, tokens, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.glassSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: tokens.brandOrange, size: 16),
              const SizedBox(width: 8),
              Text(
                contact['name'] ?? 'Unnamed Contact',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isEditing) ...[
                IconButton(
                  onPressed: () => _editContact(contact),
                  icon: Icon(Icons.edit, color: tokens.brandOrange, size: 16),
                  tooltip: 'Edit Contact',
                ),
                IconButton(
                  onPressed: () => _deleteContact(contact['id']),
                  icon: Icon(Icons.delete, color: tokens.error, size: 16),
                  tooltip: 'Delete Contact',
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (contact['email'] != null) ...[
            Row(
              children: [
                Icon(Icons.email, color: tokens.brandOrange, size: 14),
                const SizedBox(width: 4),
                Text(
                  contact['email'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.pureWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (contact['phone'] != null) ...[
            Row(
              children: [
                Icon(Icons.phone, color: tokens.brandOrange, size: 14),
                const SizedBox(width: 4),
                Text(
                  contact['phone'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.pureWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildActionButtons(BuildContext context, tokens, bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: IMRButton(
            text: 'Cancel',
            type: IMRButtonType.secondary,
            onPressed: _isLoading ? null : () {
              if (mounted) {
                setState(() => _isEditing = false);
                ref.invalidate(clientByIdProvider(widget.clientId));
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: IMRButton(
            text: _isLoading ? 'Saving...' : 'Save Changes',
            onPressed: _isLoading ? null : () {
              if (mounted) {
                _saveChanges();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, tokens, error) {
    return Center(
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: tokens.error),
              const SizedBox(height: 16),
              Text('Error loading client', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: tokens.error)),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tokens.brandGrey), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              IMRButton(text: 'Back to Client List', onPressed: () => context.go('/clients')),
            ],
          ),
        ),
      ),
    );
  }

  String _getClientInitials(Map<String, dynamic> client) {
    if (client['client_type'] == 'personal') {
      final firstName = client['first_name'] ?? '';
      final lastName = client['last_name'] ?? '';
      return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    } else if (client['client_type'] == 'business') {
      final companyName = client['company_name'] ?? '';
      return companyName.isNotEmpty ? companyName[0].toUpperCase() : 'B';
    } else if (client['client_type'] == 'bodyCorporate') {
      final entityName = client['entity_name'] ?? '';
      return entityName.isNotEmpty ? entityName[0].toUpperCase() : 'C';
    }
    return 'C';
  }

  String _getClientDisplayName(Map<String, dynamic> client) {
    if (client['client_type'] == 'personal') {
      final firstName = client['first_name'] ?? '';
      final lastName = client['last_name'] ?? '';
      return '${firstName.isNotEmpty ? firstName : ''} ${lastName.isNotEmpty ? lastName : ''}'.trim();
    } else if (client['client_type'] == 'business') {
      return client['company_name'] ?? 'Business Client';
    } else if (client['client_type'] == 'bodyCorporate') {
      return client['entity_name'] ?? 'Body Corporate Client';
    }
    return 'Unknown Client';
  }

  String _getClientTypeDisplay(String? clientType) {
    switch (clientType) {
      case 'personal': return 'Personal Client';
      case 'business': return 'Business Client';
      case 'bodyCorporate': return 'Body Corporate';
      default: return 'Unknown Type';
    }
  }

  String _formatAddress(Map<String, dynamic> address) {
    final List<String> parts = [];
    
    if (address['address_type'] == 'physical') {
      if (address['street_number'] != null) parts.add(address['street_number']);
      if (address['street_name'] != null) parts.add(address['street_name']);
      if (address['suburb'] != null) parts.add(address['suburb']);
      if (address['city'] != null) parts.add(address['city']);
      if (address['province'] != null) parts.add(address['province']);
      if (address['postal_code'] != null) parts.add(address['postal_code']);
      if (address['complex_name'] != null) parts.add('Complex: ${address['complex_name']}');
      if (address['unit_number'] != null) parts.add('Unit: ${address['unit_number']}');
    } else {
      if (address['po_box'] != null) parts.add('P.O. Box ${address['po_box']}');
      if (address['suburb'] != null) parts.add(address['suburb']);
      if (address['city'] != null) parts.add(address['city']);
      if (address['province'] != null) parts.add(address['province']);
      if (address['postal_code'] != null) parts.add(address['postal_code']);
    }
    
    return parts.isEmpty ? 'No address details' : parts.join(', ');
  }

  void _addNewAddress() {
    // TODO: Implement add address dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add address functionality coming soon'),
        backgroundColor: Theme.of(context).extension<IMRTokens>()!.brandOrange,
      ),
    );
  }

  void _editAddress(Map<String, dynamic> address) {
    // TODO: Implement edit address dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit address functionality coming soon'),
        backgroundColor: Theme.of(context).extension<IMRTokens>()!.brandOrange,
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.glassSurface,
        surfaceTintColor: Colors.transparent,
        title: Text('Delete Address', style: TextStyle(color: tokens.pureWhite)),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: tokens.pureWhite.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: tokens.brandGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ClientService.deleteAddress(addressId);
        await _loadAddressesAndContacts(); // Reload data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Address deleted successfully'),
              backgroundColor: tokens.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting address: $e'),
              backgroundColor: tokens.error,
            ),
          );
        }
      }
    }
  }

  void _addNewContact() {
    // TODO: Implement add contact dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add contact functionality coming soon'),
        backgroundColor: Theme.of(context).extension<IMRTokens>()!.brandOrange,
      ),
    );
  }

  void _editContact(Map<String, dynamic> contact) {
    // TODO: Implement edit contact dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit contact functionality coming soon'),
        backgroundColor: Theme.of(context).extension<IMRTokens>()!.brandOrange,
      ),
    );
  }

  Future<void> _deleteContact(String contactId) async {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.glassSurface,
        surfaceTintColor: Colors.transparent,
        title: Text('Delete Contact', style: TextStyle(color: tokens.pureWhite)),
        content: Text(
          'Are you sure you want to delete this contact?',
          style: TextStyle(color: tokens.pureWhite.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: tokens.brandGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: tokens.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ClientService.deleteContact(contactId);
        await _loadAddressesAndContacts(); // Reload data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contact deleted successfully'),
              backgroundColor: tokens.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting contact: $e'),
              backgroundColor: tokens.error,
            ),
          );
        }
      }
    }
  }
}
