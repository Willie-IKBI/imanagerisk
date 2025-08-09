import 'package:flutter_test/flutter_test.dart';
import 'package:imanagerisk/core/env/env_config.dart';

void main() {
  group('Supabase Configuration Tests', () {
    test('Environment variables are properly configured', () {
      // Test that environment variables are set
      expect(EnvConfig.supabaseUrl, isNotEmpty);
      expect(EnvConfig.supabaseAnonKey, isNotEmpty);
      expect(EnvConfig.supabaseUrl, contains('supabase.co'));
      expect(EnvConfig.supabaseAnonKey, startsWith('eyJ'));
    });

    test('Environment validation passes', () {
      // Test that environment validation works
      expect(EnvConfig.validateEnvironment(), isTrue);
    });

    test('Environment variables are accessible', () {
      // Test that we can access all environment variables
      final vars = EnvConfig.getAllVariables();
      expect(vars['SUPABASE_URL'], isNotEmpty);
      expect(vars['SUPABASE_ANON_KEY'], isNotEmpty);
      expect(vars['ENVIRONMENT'], isNotEmpty);
    });
  });
}
