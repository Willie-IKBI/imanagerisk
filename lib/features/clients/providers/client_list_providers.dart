import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/client_service.dart';

/// Provider for all clients - this fetches data from the database
final allClientsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  print('🔄 allClientsProvider called');
  // Watch the refresh provider to trigger refetch
  ref.watch(clientListRefreshProvider);
  print('🔄 Calling ClientService.getAllClients()');
  return await ClientService.getAllClients();
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for selected filter
final selectedFilterProvider = StateProvider<String>((ref) => 'all');

/// Provider for filtered clients - this only filters existing data, doesn't fetch
final filteredClientsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  print('🔍 filteredClientsProvider called');
  final allClientsAsync = ref.watch(allClientsProvider);
  
  return allClientsAsync.when(
    data: (allClients) {
      print('🔍 Processing ${allClients.length} clients for filtering');
      final searchQuery = ref.watch(searchQueryProvider);
      final filter = ref.watch(selectedFilterProvider);
      
      List<Map<String, dynamic>> filteredClients = allClients;
      
      // Apply filter
      if (filter != 'all') {
        filteredClients = filteredClients.where((client) {
          return client['client_type'] == filter;
        }).toList();
      }
      
      // Apply search
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredClients = filteredClients.where((client) {
          // Search in name fields
          final firstName = (client['first_name'] ?? '').toString().toLowerCase();
          final lastName = (client['last_name'] ?? '').toString().toLowerCase();
          final companyName = (client['company_name'] ?? '').toString().toLowerCase();
          final entityName = (client['entity_name'] ?? '').toString().toLowerCase();
          final email = (client['email'] ?? '').toString().toLowerCase();
          final idNumber = (client['id_number'] ?? '').toString().toLowerCase();
          final registrationNumber = (client['registration_number'] ?? '').toString().toLowerCase();
          final ssNumber = (client['ss_number'] ?? '').toString().toLowerCase();
          
          return firstName.contains(query) ||
                 lastName.contains(query) ||
                 companyName.contains(query) ||
                 entityName.contains(query) ||
                 email.contains(query) ||
                 idNumber.contains(query) ||
                 registrationNumber.contains(query) ||
                 ssNumber.contains(query);
        }).toList();
      }
      
      // Sort by creation date (newest first)
      filteredClients.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
        return bDate.compareTo(aDate);
      });
      
      print('🔍 Returning ${filteredClients.length} filtered clients');
      return filteredClients;
    },
    loading: () {
      print('🔍 allClientsProvider is still loading');
      return <Map<String, dynamic>>[];
    },
    error: (error, stack) {
      print('🔍 allClientsProvider error: $error');
      return <Map<String, dynamic>>[];
    },
  );
});

/// Provider for a specific client by ID
final clientByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, clientId) async {
  return await ClientService.getClientById(clientId);
});

/// Provider to trigger client list refresh
final clientListRefreshProvider = StateProvider<int>((ref) => 0);
