import 'package:flutter/foundation.dart';

/// Environment configuration for the IMR application
class EnvConfig {
  static const String _supabaseUrlKey = 'SUPABASE_URL';
  static const String _supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';
  static const String _supabaseServiceKeyKey = 'SUPABASE_SERVICE_KEY';
  
  // Supabase Configuration
  static String get supabaseUrl {
    // Use the same URL for both development and production
    return 'https://gqwonqnhdcqksafucbmo.supabase.co';
  }

  static String get supabaseAnonKey {
    // Use the same key for both development and production
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3MzIzMDcsImV4cCI6MjA3MDMwODMwN30.vMwsQxB51kRbAavHdZCfg4_H4LiL2PUAhXXHXApp0TA';
  }

  static String get supabaseServiceKey {
    // Use the same key for both development and production
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxd29ucW5oZGNxa3NhZnVjYm1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDczMjMwNywiZXhwIjoyMDcwMzA4MzA3fQ.0eg-XYAnuIjxhXvI6YL4pg-i4X4ihtSW2PgSmeoiXVw';
  }

  // Environment detection
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => !kDebugMode;
  
  // App configuration
  static const String appName = 'I Manage Risk';
  static const String appVersion = '1.0.0';
  
  // API configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // File upload configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
  
  // Validation configuration
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxPhoneLength = 20;
  static const int maxEmailLength = 255;
  
  // Pagination configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache configuration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration authCacheDuration = Duration(days: 7);
  
  // Error reporting configuration
  static const bool enableErrorReporting = true;
  static const String errorReportingEndpoint = 'https://your-error-reporting-endpoint.com';
  
  // Logging configuration
  static const bool enableLogging = true;
  static const String logLevel = 'INFO';
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;
  
  /// Validates that all required environment variables are set
  static bool validateEnvironment() {
    final requiredVars = [
      supabaseUrl,
      supabaseAnonKey,
    ];
    
    for (final variable in requiredVars) {
      if (variable.isEmpty || variable.contains('your-')) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Returns a map of all environment variables (for debugging)
  static Map<String, String> getAllVariables() {
    return {
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'SUPABASE_SERVICE_KEY': supabaseServiceKey,
      'ENVIRONMENT': isDevelopment ? 'development' : 'production',
      'APP_NAME': appName,
      'APP_VERSION': appVersion,
    };
  }
}
