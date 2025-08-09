import 'package:flutter/material.dart';
import '../core/services/supabase_service.dart';
import '../core/env/env_config.dart';

class SupabaseTestWidget extends StatefulWidget {
  const SupabaseTestWidget({super.key});

  @override
  State<SupabaseTestWidget> createState() => _SupabaseTestWidgetState();
}

class _SupabaseTestWidgetState extends State<SupabaseTestWidget> {
  bool _isLoading = false;
  String _testResult = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Supabase Connection Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Environment Info
            _buildInfoSection('Environment Variables', [
              'URL: ${EnvConfig.supabaseUrl}',
              'Anon Key: ${EnvConfig.supabaseAnonKey.substring(0, 20)}...',
              'Environment: ${EnvConfig.isDevelopment ? 'Development' : 'Production'}',
            ]),
            const SizedBox(height: 16),
            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Test Supabase Connection'),
              ),
            ),
            const SizedBox(height: 16),
            // Test Results
            if (_testResult.isNotEmpty)
              _buildInfoSection('Test Results', [_testResult]),
            if (_errorMessage.isNotEmpty)
              _buildInfoSection('Error', [_errorMessage], isError: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items, {bool isError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isError ? Colors.red : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  color: isError ? Colors.red : Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
    });

    try {
      // Test 1: Check if Supabase is initialized
      final client = SupabaseService.client;
      setState(() {
        _testResult += '✅ Supabase client initialized\n';
      });

      // Test 2: Try to query a table
      final response = await client.from('policy_types').select().limit(1);
      setState(() {
        _testResult += '✅ Database query successful\n';
        _testResult += '📊 Found ${response.length} policy types\n';
      });

      // Test 3: Check authentication status
      final user = SupabaseService.currentUser;
      setState(() {
        _testResult += user != null
            ? '✅ User authenticated: ${user.email}\n'
            : 'ℹ️ No user authenticated\n';
      });

      // Test 4: Test environment validation
      if (EnvConfig.validateEnvironment()) {
        setState(() {
          _testResult += '✅ Environment validation passed\n';
        });
      } else {
        setState(() {
          _testResult += '⚠️ Environment validation failed\n';
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = '❌ Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
