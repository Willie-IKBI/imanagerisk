import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/client_type_selector.dart';

// Form data models
class ClientFormData {
  final ClientType? clientType;
  
  // Basic Information - Personal
  final String? firstName;
  final String? lastName;
  final String? idNumber;
  
  // Basic Information - Business
  final String? companyName;
  final String? registrationNumber;
  final String? vatNumber;
  
  // Basic Information - Body Corporate
  final String? entityName;
  final String? ssNumber;
  
  // Contact Information
  final String? email;
  final String? phoneNumber;
  final String? alternativePhone;
  final String? notes;
  
  // Address Information
  final String? addressType; // 'physical', 'postal', 'both'
  final bool hasDifferentPostalAddress;
  
  // Physical Address
  final String? physicalStreetNumber;
  final String? physicalStreetName;
  final String? physicalSuburb;
  final String? physicalCity;
  final String? physicalProvince;
  final String? physicalPostalCode;
  
  // Postal Address
  final String? postalPoBox;
  final String? postalSuburb;
  final String? postalCity;
  final String? postalProvince;
  final String? postalPostalCode;
  
  // Additional Address Info
  final String? complexName;
  final String? unitNumber;
  final String? addressNotes;
  
  // Additional Contacts
  final List<ContactData> contacts;

  ClientFormData({
    this.clientType,
    this.firstName,
    this.lastName,
    this.idNumber,
    this.companyName,
    this.registrationNumber,
    this.vatNumber,
    this.entityName,
    this.ssNumber,
    this.email,
    this.phoneNumber,
    this.alternativePhone,
    this.notes,
    this.addressType = 'physical',
    this.hasDifferentPostalAddress = false,
    this.physicalStreetNumber,
    this.physicalStreetName,
    this.physicalSuburb,
    this.physicalCity,
    this.physicalProvince,
    this.physicalPostalCode,
    this.postalPoBox,
    this.postalSuburb,
    this.postalCity,
    this.postalProvince,
    this.postalPostalCode,
    this.complexName,
    this.unitNumber,
    this.addressNotes,
    this.contacts = const [],
  });

  ClientFormData copyWith({
    ClientType? clientType,
    String? firstName,
    String? lastName,
    String? idNumber,
    String? companyName,
    String? registrationNumber,
    String? vatNumber,
    String? entityName,
    String? ssNumber,
    String? email,
    String? phoneNumber,
    String? alternativePhone,
    String? notes,
    String? addressType,
    bool? hasDifferentPostalAddress,
    String? physicalStreetNumber,
    String? physicalStreetName,
    String? physicalSuburb,
    String? physicalCity,
    String? physicalProvince,
    String? physicalPostalCode,
    String? postalPoBox,
    String? postalSuburb,
    String? postalCity,
    String? postalProvince,
    String? postalPostalCode,
    String? complexName,
    String? unitNumber,
    String? addressNotes,
    List<ContactData>? contacts,
  }) {
    return ClientFormData(
      clientType: clientType ?? this.clientType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      idNumber: idNumber ?? this.idNumber,
      companyName: companyName ?? this.companyName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vatNumber: vatNumber ?? this.vatNumber,
      entityName: entityName ?? this.entityName,
      ssNumber: ssNumber ?? this.ssNumber,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      notes: notes ?? this.notes,
      addressType: addressType ?? this.addressType,
      hasDifferentPostalAddress: hasDifferentPostalAddress ?? this.hasDifferentPostalAddress,
      physicalStreetNumber: physicalStreetNumber ?? this.physicalStreetNumber,
      physicalStreetName: physicalStreetName ?? this.physicalStreetName,
      physicalSuburb: physicalSuburb ?? this.physicalSuburb,
      physicalCity: physicalCity ?? this.physicalCity,
      physicalProvince: physicalProvince ?? this.physicalProvince,
      physicalPostalCode: physicalPostalCode ?? this.physicalPostalCode,
      postalPoBox: postalPoBox ?? this.postalPoBox,
      postalSuburb: postalSuburb ?? this.postalSuburb,
      postalCity: postalCity ?? this.postalCity,
      postalProvince: postalProvince ?? this.postalProvince,
      postalPostalCode: postalPostalCode ?? this.postalPostalCode,
      complexName: complexName ?? this.complexName,
      unitNumber: unitNumber ?? this.unitNumber,
      addressNotes: addressNotes ?? this.addressNotes,
      contacts: contacts ?? this.contacts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientType': clientType?.name,
      'firstName': firstName,
      'lastName': lastName,
      'idNumber': idNumber,
      'companyName': companyName,
      'registrationNumber': registrationNumber,
      'vatNumber': vatNumber,
      'entityName': entityName,
      'ssNumber': ssNumber,
      'email': email,
      'phoneNumber': phoneNumber,
      'alternativePhone': alternativePhone,
      'notes': notes,
      'addressType': addressType,
      'hasDifferentPostalAddress': hasDifferentPostalAddress,
      'physicalStreetNumber': physicalStreetNumber,
      'physicalStreetName': physicalStreetName,
      'physicalSuburb': physicalSuburb,
      'physicalCity': physicalCity,
      'physicalProvince': physicalProvince,
      'physicalPostalCode': physicalPostalCode,
      'postalPoBox': postalPoBox,
      'postalSuburb': postalSuburb,
      'postalCity': postalCity,
      'postalProvince': postalProvince,
      'postalPostalCode': postalPostalCode,
      'complexName': complexName,
      'unitNumber': unitNumber,
      'addressNotes': addressNotes,
      'contacts': contacts.map((c) => c.toJson()).toList(),
    };
  }

  factory ClientFormData.fromJson(Map<String, dynamic> json) {
    return ClientFormData(
      clientType: json['clientType'] != null 
          ? ClientType.values.firstWhere((e) => e.name == json['clientType'])
          : null,
      firstName: json['firstName'],
      lastName: json['lastName'],
      idNumber: json['idNumber'],
      companyName: json['companyName'],
      registrationNumber: json['registrationNumber'],
      vatNumber: json['vatNumber'],
      entityName: json['entityName'],
      ssNumber: json['ssNumber'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      alternativePhone: json['alternativePhone'],
      notes: json['notes'],
      addressType: json['addressType'] ?? 'physical',
      hasDifferentPostalAddress: json['hasDifferentPostalAddress'] ?? false,
      physicalStreetNumber: json['physicalStreetNumber'],
      physicalStreetName: json['physicalStreetName'],
      physicalSuburb: json['physicalSuburb'],
      physicalCity: json['physicalCity'],
      physicalProvince: json['physicalProvince'],
      physicalPostalCode: json['physicalPostalCode'],
      postalPoBox: json['postalPoBox'],
      postalSuburb: json['postalSuburb'],
      postalCity: json['postalCity'],
      postalProvince: json['postalProvince'],
      postalPostalCode: json['postalPostalCode'],
      complexName: json['complexName'],
      unitNumber: json['unitNumber'],
      addressNotes: json['addressNotes'],
      contacts: (json['contacts'] as List<dynamic>?)
          ?.map((c) => ContactData.fromJson(c))
          .toList() ?? [],
    );
  }

  // Calculate completion percentage
  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 0;

    // Step 1: Client Type (1 field)
    totalFields++;
    if (clientType != null) completedFields++;

    // Step 2: Basic Information (varies by type)
    if (clientType == ClientType.personal) {
      totalFields += 5; // firstName, lastName, idNumber, email, phoneNumber
      if (firstName?.isNotEmpty == true) completedFields++;
      if (lastName?.isNotEmpty == true) completedFields++;
      if (idNumber?.isNotEmpty == true) completedFields++;
      if (email?.isNotEmpty == true) completedFields++;
      if (phoneNumber?.isNotEmpty == true) completedFields++;
    } else if (clientType == ClientType.business) {
      totalFields += 4; // companyName, registrationNumber, email, phoneNumber
      if (companyName?.isNotEmpty == true) completedFields++;
      if (registrationNumber?.isNotEmpty == true) completedFields++;
      if (email?.isNotEmpty == true) completedFields++;
      if (phoneNumber?.isNotEmpty == true) completedFields++;
    } else if (clientType == ClientType.bodyCorporate) {
      totalFields += 3; // entityName, ssNumber, email, phoneNumber
      if (entityName?.isNotEmpty == true) completedFields++;
      if (ssNumber?.isNotEmpty == true) completedFields++;
      if (email?.isNotEmpty == true) completedFields++;
      if (phoneNumber?.isNotEmpty == true) completedFields++;
    }

    // Step 3: Address (varies by address type)
    if (addressType == 'physical' || addressType == 'both') {
      totalFields += 6; // streetNumber, streetName, suburb, city, province, postalCode
      if (physicalStreetNumber?.isNotEmpty == true) completedFields++;
      if (physicalStreetName?.isNotEmpty == true) completedFields++;
      if (physicalSuburb?.isNotEmpty == true) completedFields++;
      if (physicalCity?.isNotEmpty == true) completedFields++;
      if (physicalProvince?.isNotEmpty == true) completedFields++;
      if (physicalPostalCode?.isNotEmpty == true) completedFields++;
    }
    
    if (addressType == 'postal' || (addressType == 'both' && hasDifferentPostalAddress)) {
      totalFields += 5; // poBox, suburb, city, province, postalCode
      if (postalPoBox?.isNotEmpty == true) completedFields++;
      if (postalSuburb?.isNotEmpty == true) completedFields++;
      if (postalCity?.isNotEmpty == true) completedFields++;
      if (postalProvince?.isNotEmpty == true) completedFields++;
      if (postalPostalCode?.isNotEmpty == true) completedFields++;
    }

    return totalFields > 0 ? completedFields / totalFields : 0.0;
  }
}

class ContactData {
  final String name;
  final String? position;
  final String? email;
  final String? phone;
  final bool isPrimary;

  ContactData({
    required this.name,
    this.position,
    this.email,
    this.phone,
    this.isPrimary = false,
  });

  ContactData copyWith({
    String? name,
    String? position,
    String? email,
    String? phone,
    bool? isPrimary,
  }) {
    return ContactData(
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'email': email,
      'phone': phone,
      'isPrimary': isPrimary,
    };
  }

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      name: json['name'],
      position: json['position'],
      email: json['email'],
      phone: json['phone'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class AddExistingClientState {
  final ClientFormData formData;
  final bool isLoading;
  final String? error;
  final DateTime? lastSaved;
  final bool isSaving;

  AddExistingClientState({
    required this.formData,
    this.isLoading = false,
    this.error,
    this.lastSaved,
    this.isSaving = false,
  });

  double get completionPercentage => formData.completionPercentage;

  AddExistingClientState copyWith({
    ClientFormData? formData,
    bool? isLoading,
    String? error,
    DateTime? lastSaved,
    bool? isSaving,
  }) {
    return AddExistingClientState(
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSaved: lastSaved ?? this.lastSaved,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddExistingClientController extends StateNotifier<AddExistingClientState> {
  AddExistingClientController() : super(AddExistingClientState(formData: ClientFormData()));

  // Load draft from local storage
  Future<void> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('add_existing_client_draft');
      
      if (draftJson != null) {
        final draftData = ClientFormData.fromJson(jsonDecode(draftJson));
        state = state.copyWith(formData: draftData);
      }
    } catch (e) {
      // Ignore errors when loading draft
      print('Error loading draft: $e');
    }
  }

  // Save draft to local storage
  Future<void> saveDraft() async {
    try {
      state = state.copyWith(isSaving: true);
      
      final prefs = await SharedPreferences.getInstance();
      final draftJson = jsonEncode(state.formData.toJson());
      await prefs.setString('add_existing_client_draft', draftJson);
      
      state = state.copyWith(
        lastSaved: DateTime.now(),
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to save draft: $e',
        isSaving: false,
      );
    }
  }

  // Clear draft
  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('add_existing_client_draft');
      
      state = AddExistingClientState(formData: ClientFormData());
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear draft: $e');
    }
  }

  // Update form data
  void updateFormData(ClientFormData Function(ClientFormData) update) {
    final newFormData = update(state.formData);
    state = state.copyWith(formData: newFormData);
    
    // Auto-save draft
    saveDraft();
  }

  // Convenience methods for updating specific fields
  void setClientType(ClientType clientType) {
    updateFormData((formData) => formData.copyWith(clientType: clientType));
  }

  // Basic Information - Personal
  void updateFirstName(String? value) {
    updateFormData((formData) => formData.copyWith(firstName: value));
  }

  void updateLastName(String? value) {
    updateFormData((formData) => formData.copyWith(lastName: value));
  }

  void updateIdNumber(String? value) {
    updateFormData((formData) => formData.copyWith(idNumber: value));
  }

  // Basic Information - Business/Body Corporate
  void updateCompanyName(String? value) {
    updateFormData((formData) => formData.copyWith(companyName: value));
  }

  void updateRegistrationNumber(String? value) {
    updateFormData((formData) => formData.copyWith(registrationNumber: value));
  }

  void updateVatNumber(String? value) {
    updateFormData((formData) => formData.copyWith(vatNumber: value));
  }

  // Basic Information - Body Corporate
  void updateEntityName(String? value) {
    updateFormData((formData) => formData.copyWith(entityName: value));
  }

  void updateSsNumber(String? value) {
    updateFormData((formData) => formData.copyWith(ssNumber: value));
  }

  // Contact Information
  void updateEmail(String? value) {
    updateFormData((formData) => formData.copyWith(email: value));
  }

  void updatePhoneNumber(String? value) {
    updateFormData((formData) => formData.copyWith(phoneNumber: value));
  }

  void updateAlternativePhone(String? value) {
    updateFormData((formData) => formData.copyWith(alternativePhone: value));
  }

  void updateNotes(String? value) {
    updateFormData((formData) => formData.copyWith(notes: value));
  }

  // Address Information
  void updateAddressType(String? value) {
    updateFormData((formData) => formData.copyWith(addressType: value));
  }

  void updateHasDifferentPostalAddress(bool value) {
    updateFormData((formData) => formData.copyWith(hasDifferentPostalAddress: value));
  }

  // Physical Address
  void updatePhysicalStreetNumber(String? value) {
    updateFormData((formData) => formData.copyWith(physicalStreetNumber: value));
  }

  void updatePhysicalStreetName(String? value) {
    updateFormData((formData) => formData.copyWith(physicalStreetName: value));
  }

  void updatePhysicalSuburb(String? value) {
    updateFormData((formData) => formData.copyWith(physicalSuburb: value));
  }

  void updatePhysicalCity(String? value) {
    updateFormData((formData) => formData.copyWith(physicalCity: value));
  }

  void updatePhysicalProvince(String? value) {
    updateFormData((formData) => formData.copyWith(physicalProvince: value));
  }

  void updatePhysicalPostalCode(String? value) {
    updateFormData((formData) => formData.copyWith(physicalPostalCode: value));
  }

  // Postal Address
  void updatePostalPoBox(String? value) {
    updateFormData((formData) => formData.copyWith(postalPoBox: value));
  }

  void updatePostalSuburb(String? value) {
    updateFormData((formData) => formData.copyWith(postalSuburb: value));
  }

  void updatePostalCity(String? value) {
    updateFormData((formData) => formData.copyWith(postalCity: value));
  }

  void updatePostalProvince(String? value) {
    updateFormData((formData) => formData.copyWith(postalProvince: value));
  }

  void updatePostalPostalCode(String? value) {
    updateFormData((formData) => formData.copyWith(postalPostalCode: value));
  }

  // Additional Address Info
  void updateComplexName(String? value) {
    updateFormData((formData) => formData.copyWith(complexName: value));
  }

  void updateUnitNumber(String? value) {
    updateFormData((formData) => formData.copyWith(unitNumber: value));
  }

  void updateAddressNotes(String? value) {
    updateFormData((formData) => formData.copyWith(addressNotes: value));
  }

  // Contact management
  void addContact(ContactData contact) {
    updateFormData((formData) {
      final contacts = List<ContactData>.from(formData.contacts);
      contacts.add(contact);
      return formData.copyWith(contacts: contacts);
    });
  }

  void updateContact(int index, ContactData contact) {
    updateFormData((formData) {
      final contacts = List<ContactData>.from(formData.contacts);
      contacts[index] = contact;
      return formData.copyWith(contacts: contacts);
    });
  }

  void removeContact(int index) {
    updateFormData((formData) {
      final contacts = List<ContactData>.from(formData.contacts);
      contacts.removeAt(index);
      return formData.copyWith(contacts: contacts);
    });
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear form data and draft
  Future<void> clearForm() async {
    await clearDraft();
  }
}

final addExistingClientControllerProvider = StateNotifierProvider<AddExistingClientController, AddExistingClientState>((ref) {
  return AddExistingClientController();
});
