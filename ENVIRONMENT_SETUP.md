# Environment Setup Guide

This guide will help you configure the Supabase keys and environment variables for the IMR application.

## Prerequisites

1. **Supabase Project**: You should have already created a Supabase project
2. **Flutter SDK**: Ensure Flutter is installed and configured
3. **Dependencies**: Run `flutter pub get` to install dependencies

## Step 1: Get Supabase Keys

### 1.1 Access Your Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Sign in to your account
3. Select your IMR project

### 1.2 Get Project URL and Keys

1. In your Supabase project dashboard, go to **Settings** > **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-ref.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)
   - **service_role key** (starts with `eyJ...`) - Keep this secret!

## Step 2: Configure Environment Variables

### 2.1 Development Environment

For development, you can configure environment variables in several ways:

#### Option A: Using --dart-define (Recommended)

Create a script or use the following command when running the app:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key-here \
            --dart-define=SUPABASE_SERVICE_KEY=your-service-key-here
```

#### Option B: Using Environment Files

1. Create a `.env` file in the project root (add to .gitignore)
2. Add the following content:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here
```

#### Option C: Using IDE Configuration

If using VS Code or Android Studio, you can configure environment variables in your launch configuration.

### 2.2 Production Environment

For production builds, use the same `--dart-define` approach:

```bash
flutter build web --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
                 --dart-define=SUPABASE_ANON_KEY=your-anon-key-here \
                 --dart-define=SUPABASE_SERVICE_KEY=your-service-key-here
```

## Step 3: Update Configuration Files

### 3.1 Update EnvConfig

The `lib/core/env/env_config.dart` file is already configured to read environment variables. Make sure the keys match your actual Supabase project:

```dart
// In lib/core/env/env_config.dart
static String get supabaseUrl {
  if (kDebugMode) {
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://your-project-ref.supabase.co', // Update this
    );
  } else {
    return const String.fromEnvironment('SUPABASE_URL');
  }
}

static String get supabaseAnonKey {
  if (kDebugMode) {
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'your-anon-key-here', // Update this
    );
  } else {
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }
}
```

### 3.2 Initialize Supabase in main.dart

Update your `lib/main.dart` to initialize Supabase:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';
import 'core/env/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## Step 4: Verify Configuration

### 4.1 Test Supabase Connection

Create a simple test to verify your configuration:

```dart
// Add this to your main.dart or create a test file
void testSupabaseConnection() async {
  try {
    final client = SupabaseService.client;
    final response = await client.from('policy_types').select().limit(1);
    print('✅ Supabase connection successful');
    print('Response: $response');
  } catch (e) {
    print('❌ Supabase connection failed: $e');
  }
}
```

### 4.2 Check Environment Variables

You can also check if environment variables are loaded correctly:

```dart
void checkEnvironmentVariables() {
  final vars = EnvConfig.getAllVariables();
  print('Environment Variables:');
  vars.forEach((key, value) {
    print('$key: $value');
  });
}
```

## Step 5: Security Considerations

### 5.1 Never Commit Secrets

- ✅ Add `.env` to your `.gitignore` file
- ✅ Never commit actual keys to version control
- ✅ Use environment variables for production
- ✅ Rotate keys regularly

### 5.2 Key Management

- **anon key**: Safe to use in client-side code
- **service_role key**: Keep secret, only use in server-side code
- **URL**: Safe to expose in client-side code

## Step 6: Troubleshooting

### Common Issues

1. **Invalid URL**: Make sure the Supabase URL is correct and includes `https://`
2. **Invalid Key**: Ensure the anon key is copied correctly (starts with `eyJ...`)
3. **Network Issues**: Check if your device can reach the Supabase URL
4. **CORS Issues**: Ensure your Supabase project allows your app's domain

### Debug Mode

Enable debug mode to see detailed logs:

```dart
// In lib/core/env/env_config.dart
static const bool enableLogging = true;
static const String logLevel = 'DEBUG';
```

## Step 7: Next Steps

Once your environment is configured:

1. **Test Authentication**: Try signing in/up with test users
2. **Test Database**: Verify you can read/write to your tables
3. **Test Storage**: Upload and download files
4. **Test RLS**: Verify row-level security is working

## Support

If you encounter issues:

1. Check the [Supabase Documentation](https://supabase.com/docs)
2. Verify your project settings in the Supabase dashboard
3. Check the Flutter console for error messages
4. Ensure all dependencies are installed (`flutter pub get`)

## Example Configuration

Here's a complete example of how your environment should be configured:

```bash
# Development
flutter run --dart-define=SUPABASE_URL=https://abcdefghijklm.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... \
            --dart-define=SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Production
flutter build web --dart-define=SUPABASE_URL=https://abcdefghijklm.supabase.co \
                 --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Remember to replace the example values with your actual Supabase project credentials!
