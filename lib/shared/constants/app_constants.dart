/// Application constants used throughout the IMR application
class AppConstants {
  // App Information
  static const String appName = 'I Manage Risk';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Comprehensive insurance management system';
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.imanagerisk.com';
  static const String apiVersion = 'v1';
  
  // Storage Buckets
  static const String clientsBucket = 'clients';
  static const String policiesBucket = 'policies';
  static const String claimsBucket = 'claims';
  static const String quotesBucket = 'quotes';
  static const String complianceBucket = 'compliance';
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'];
  
  // Validation
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxPhoneLength = 20;
  static const int maxEmailLength = 255;
  static const int maxAddressLength = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration authCacheDuration = Duration(days: 7);
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedErrorMessage = 'Unauthorized. Please sign in again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String saveSuccessMessage = 'Saved successfully.';
  static const String deleteSuccessMessage = 'Deleted successfully.';
  static const String uploadSuccessMessage = 'Uploaded successfully.';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayDateTimeFormat = 'dd MMM yyyy HH:mm';
  
  // Currency
  static const String defaultCurrency = 'ZAR';
  static const String currencySymbol = 'R';
  
  // Phone Number Format (South Africa)
  static const String phoneNumberFormat = '+27 ## ### ####';
  static const String phoneNumberRegex = r'^\+27[0-9]{9}$';
  
  // Email Validation
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // ID Number Validation (South Africa)
  static const String idNumberRegex = r'^[0-9]{13}$';
  
  // VAT Number Validation (South Africa)
  static const String vatNumberRegex = r'^[0-9]{10}$';
  
  // Company Registration Number Validation (South Africa)
  static const String companyRegNumberRegex = r'^[0-9]{4}/[0-9]{6}/[0-9]{2}$';
  
  // Postal Code Validation (South Africa)
  static const String postalCodeRegex = r'^[0-9]{4}$';
  
  // Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleManager = 'manager';
  static const String roleSalesBroker = 'sales_broker';
  static const String roleAdminStaff = 'admin_staff';
  static const String roleClaimsHandler = 'claims_handler';
  static const String roleFinance = 'finance';
  
  // Status Values
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Client Types
  static const String clientTypePersonal = 'personal';
  static const String clientTypeBusiness = 'business';
  static const String clientTypeBodyCorporate = 'body_corporate';
  
  // Policy Status
  static const String policyStatusActive = 'active';
  static const String policyStatusCancelled = 'cancelled';
  static const String policyStatusPending = 'pending';
  
  // Claim Status
  static const String claimStatusReported = 'reported';
  static const String claimStatusInReview = 'in_review';
  static const String claimStatusApproved = 'approved';
  static const String claimStatusDeclined = 'declined';
  static const String claimStatusSettled = 'settled';
  
  // Task Priority
  static const String taskPriorityLow = 'low';
  static const String taskPriorityMedium = 'medium';
  static const String taskPriorityHigh = 'high';
  static const String taskPriorityUrgent = 'urgent';
  
  // Task Status
  static const String taskStatusPending = 'pending';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusCompleted = 'completed';
  static const String taskStatusCancelled = 'cancelled';
  
  // Lead Status
  static const String leadStatusNew = 'new';
  static const String leadStatusContacted = 'contacted';
  static const String leadStatusQualifying = 'qualifying';
  static const String leadStatusQuoting = 'quoting';
  static const String leadStatusAwaitingDocs = 'awaiting_docs';
  static const String leadStatusDecision = 'decision';
  static const String leadStatusWon = 'won';
  static const String leadStatusLost = 'lost';
  
  // Quote Status
  static const String quoteStatusDraft = 'draft';
  static const String quoteStatusSent = 'sent';
  static const String quoteStatusAccepted = 'accepted';
  static const String quoteStatusDeclined = 'declined';
  static const String quoteStatusExpired = 'expired';
  
  // Interaction Types
  static const String interactionTypeCall = 'call';
  static const String interactionTypeEmail = 'email';
  static const String interactionTypeMeeting = 'meeting';
  static const String interactionTypeNote = 'note';
  
  // Renewal Status
  static const String renewalStatusPending = 'pending';
  static const String renewalStatusInProgress = 'in_progress';
  static const String renewalStatusClientNotified = 'client_notified';
  static const String renewalStatusAwaitingResponse = 'awaiting_response';
  static const String renewalStatusFinalized = 'finalized';
}
