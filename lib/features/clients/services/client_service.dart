import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/add_existing_client_controller.dart';

class ClientService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Save a new client to the database
  static Future<Map<String, dynamic>> saveClient(ClientFormData formData) async {
    try {
      // First, insert the client
             final clientData = {
         'client_type': formData.clientType?.name,
         'first_name': formData.firstName,
         'last_name': formData.lastName,
         'id_number': formData.idNumber,
         'company_name': formData.companyName,
         'registration_number': formData.registrationNumber,
         'vat_number': formData.vatNumber,
         'entity_name': formData.entityName,
         'ss_number': formData.ssNumber,
         'email': formData.email,
         'phone': formData.phoneNumber,
         'alternative_phone': formData.alternativePhone,
         'notes': formData.notes,
       };

      // Remove null values
      clientData.removeWhere((key, value) => value == null || value.toString().isEmpty);

      final clientResponse = await _supabase
          .from('clients')
          .insert(clientData)
          .select()
          .single();

      final clientId = clientResponse['id'];

      // Then, insert the address
      if (formData.addressType == 'physical' || formData.addressType == 'both') {
        // Combine street number and name into line_1
        final streetLine1 = [
          formData.physicalStreetNumber,
          formData.physicalStreetName,
        ].where((part) => part != null && part.isNotEmpty).join(' ');

        final addressData = {
          'client_id': clientId,
          'type': 'physical',
          'line_1': streetLine1.isNotEmpty ? streetLine1 : null,
          'line_2': formData.physicalSuburb,
          'city': formData.physicalCity,
          'province': formData.physicalProvince,
          'postal_code': formData.physicalPostalCode,
          'country': 'South Africa',
          'complex_name': formData.complexName,
          'unit_number': formData.unitNumber,
          'address_notes': formData.addressNotes,
        };

        // Remove null values
        addressData.removeWhere((key, value) => value == null || value.toString().isEmpty);

        await _supabase
            .from('addresses')
            .insert(addressData);
      }

      // Insert postal address if different
      if (formData.addressType == 'postal' || 
          (formData.addressType == 'both' && formData.hasDifferentPostalAddress)) {
        final postalAddressData = {
          'client_id': clientId,
          'type': 'postal',
          'line_1': formData.postalPoBox,
          'line_2': formData.postalSuburb,
          'city': formData.postalCity,
          'province': formData.postalProvince,
          'postal_code': formData.postalPostalCode,
          'country': 'South Africa',
        };

        // Remove null values
        postalAddressData.removeWhere((key, value) => value == null || value.toString().isEmpty);

        await _supabase
            .from('addresses')
            .insert(postalAddressData);
      }

      // Finally, insert contacts
      for (final contact in formData.contacts) {
        final contactData = {
          'client_id': clientId,
          'name': contact.name,
          'position': contact.position,
          'email': contact.email,
          'phone': contact.phone,
          'is_primary': contact.isPrimary,
        };

        // Remove null values
        contactData.removeWhere((key, value) => value == null || value.toString().isEmpty);

        await _supabase
            .from('client_contacts')
            .insert(contactData);
      }

      return clientResponse;
    } catch (e) {
      throw Exception('Failed to save client: $e');
    }
  }

  /// Get client count for dashboard
  static Future<int> getClientCount() async {
    try {
      final response = await _supabase
          .from('clients')
          .select('id');
      
      return response.length;
    } catch (e) {
      throw Exception('Failed to get client count: $e');
    }
  }

  /// Get new clients count for this week
  static Future<int> getNewClientsThisWeek() async {
    try {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final response = await _supabase
          .from('clients')
          .select('id')
          .gte('created_at', oneWeekAgo.toIso8601String());
      
      return response.length;
    } catch (e) {
      throw Exception('Failed to get new clients count: $e');
    }
  }

  /// Get all clients for the list
  static Future<List<Map<String, dynamic>>> getAllClients() async {
    try {
      print('🔍 Fetching all clients from database...');
      
      final response = await _supabase
          .from('clients')
          .select('*')
          .order('created_at', ascending: false);
      
      print('📊 Found ${response.length} clients in database');
      if (response.isNotEmpty) {
        print('📋 First client: ${response.first}');
      } else {
        print('📭 No clients found in database');
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching clients: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error details: ${e.toString()}');
      throw Exception('Failed to get all clients: $e');
    }
  }

  /// Get a specific client by ID
  static Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      print('🔍 Fetching client by ID: $clientId');
      final response = await _supabase
          .from('clients')
          .select('*')
          .eq('id', clientId)
          .single();
      
      print('🔍 Client found: $response');
      return response;
    } catch (e) {
      print('❌ Error fetching client by ID: $e');
      if (e.toString().contains('No rows found')) {
        print('❌ No client found with ID: $clientId');
        return null;
      }
      throw Exception('Failed to get client by ID: $e');
    }
  }

  /// Update a client
  static Future<Map<String, dynamic>> updateClient(String clientId, Map<String, dynamic> clientData) async {
    try {
      // Remove null values
      clientData.removeWhere((key, value) => value == null || value.toString().isEmpty);
      
      final response = await _supabase
          .from('clients')
          .update(clientData)
          .eq('id', clientId)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  /// Delete a client
  static Future<void> deleteClient(String clientId) async {
    try {
      // First delete related records
      await _supabase
          .from('client_contacts')
          .delete()
          .eq('client_id', clientId);
      
      await _supabase
          .from('addresses')
          .delete()
          .eq('client_id', clientId);
      
      // Then delete the client
      await _supabase
          .from('clients')
          .delete()
          .eq('id', clientId);
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }

  /// Get client addresses
  static Future<List<Map<String, dynamic>>> getClientAddresses(String clientId) async {
    try {
      final response = await _supabase
          .from('addresses')
          .select('*')
          .eq('client_id', clientId)
          .order('type');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get client addresses: $e');
    }
  }

  /// Get client contacts
  static Future<List<Map<String, dynamic>>> getClientContacts(String clientId) async {
    try {
      final response = await _supabase
          .from('client_contacts')
          .select('*')
          .eq('client_id', clientId)
          .order('created_at');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get client contacts: $e');
    }
  }

  /// Create a new address
  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _supabase
          .from('addresses')
          .insert(addressData)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to create address: $e');
    }
  }

  /// Update an existing address
  static Future<Map<String, dynamic>> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    try {
      final response = await _supabase
          .from('addresses')
          .update(addressData)
          .eq('id', addressId)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  /// Create a new contact
  static Future<Map<String, dynamic>> createContact(Map<String, dynamic> contactData) async {
    try {
      final response = await _supabase
          .from('client_contacts')
          .insert(contactData)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to create contact: $e');
    }
  }

  /// Update an existing contact
  static Future<Map<String, dynamic>> updateContact(String contactId, Map<String, dynamic> contactData) async {
    try {
      final response = await _supabase
          .from('client_contacts')
          .update(contactData)
          .eq('id', contactId)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update contact: $e');
    }
  }

  /// Delete a contact
  static Future<void> deleteContact(String contactId) async {
    try {
      final response = await _supabase
          .from('client_contacts')
          .delete()
          .eq('id', contactId);
      
      print('✅ Contact deleted successfully: $contactId');
    } catch (e) {
      print('❌ Error deleting contact: $e');
      rethrow;
    }
  }

  static Future<void> deleteAddress(String addressId) async {
    try {
      final response = await _supabase
          .from('addresses')
          .delete()
          .eq('id', addressId);
      
      print('✅ Address deleted successfully: $addressId');
    } catch (e) {
      print('❌ Error deleting address: $e');
      rethrow;
    }
  }
}
