import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../services/client_service.dart';
import '../providers/client_list_providers.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).state = _searchController.text;
      });
    });
    
    // Trigger a refresh when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientListRefreshProvider.notifier).state++;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            colors: [
              Color(0xFF2F2F2F),
              Color(0xFF4A4A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Client List',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: tokens.pureWhite,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IMRButton(
                      text: 'Add New Client',
                      onPressed: () => context.go('/add-existing-client'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search and Filter
                GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    child: Column(
                      children: [
                        // Search Bar
                        IMRTextField(
                          controller: _searchController,
                          label: 'Search clients',
                          hint: 'Search by name, email, or phone',
                          prefixIcon: Icon(Icons.search, color: tokens.brandGrey),
                        ),
                        const SizedBox(height: 16),
                        
                        // Filter Buttons
                        if (isMobile) ...[
                          // Mobile: Stacked filters
                          _buildFilterButton('all', 'All Clients'),
                          const SizedBox(height: 8),
                          _buildFilterButton('personal', 'Personal'),
                          const SizedBox(height: 8),
                          _buildFilterButton('business', 'Business'),
                          const SizedBox(height: 8),
                          _buildFilterButton('bodyCorporate', 'Body Corporate'),
                        ] else ...[
                          // Desktop/Tablet: Row filters
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterButton('all', 'All Clients'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterButton('personal', 'Personal'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterButton('business', 'Business'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterButton('bodyCorporate', 'Body Corporate'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Client List
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final allClientsAsync = ref.watch(allClientsProvider);
                      final filteredClients = ref.watch(filteredClientsProvider);

                      return allClientsAsync.when(
                        data: (allClients) {
                          print('🎯 Client list data received: ${filteredClients.length} clients');
                          if (filteredClients.isEmpty) {
                            return GlassCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: tokens.brandGrey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        ref.watch(searchQueryProvider).isNotEmpty
                                            ? 'No clients found matching "${ref.watch(searchQueryProvider)}"'
                                            : 'No clients found',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: tokens.brandGrey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (ref.watch(searchQueryProvider).isEmpty) ...[
                                        const SizedBox(height: 16),
                                        IMRButton(
                                          text: 'Add Your First Client',
                                          onPressed: () => context.go('/add-existing-client'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredClients.length,
                            itemBuilder: (context, index) {
                              final client = filteredClients[index];
                              print('🔍 Client object: $client');
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  child: InkWell(
                                    onTap: () => context.go('/clients/${client['id']}'),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                                      child: Row(
                                        children: [
                                          // Client Avatar
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: tokens.brandOrange,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _getClientInitials(client),
                                                style: TextStyle(
                                                  color: tokens.pureWhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Client Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _getClientDisplayName(client),
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: tokens.pureWhite,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _getClientTypeDisplay(client['client_type']),
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: tokens.brandOrange,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (client['email'] != null) ...[
                                                  Text(
                                                    client['email'],
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: tokens.pureWhite.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                                if (client['phone'] != null) ...[
                                                  Text(
                                                    client['phone'],
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: tokens.pureWhite.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          
                                          // Arrow Icon
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: tokens.brandGrey,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () {
                          print('⏳ Client list is loading...');
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        error: (error, stack) {
                          print('❌ Client list error: $error');
                          return GlassCard(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: tokens.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading clients',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: tokens.error,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error.toString(),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: tokens.brandGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    
    return Consumer(
      builder: (context, ref, child) {
        final isSelected = ref.watch(selectedFilterProvider) == filter;
        return InkWell(
          onTap: () {
            ref.read(selectedFilterProvider.notifier).state = filter;
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? tokens.brandOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? tokens.brandOrange : tokens.glassBorder,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? tokens.pureWhite : tokens.pureWhite.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
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
      case 'personal':
        return 'Personal Client';
      case 'business':
        return 'Business Client';
      case 'bodyCorporate':
        return 'Body Corporate';
      default:
        return 'Unknown Type';
    }
  }
}
