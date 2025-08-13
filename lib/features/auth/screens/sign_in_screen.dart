import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';
import 'sign_up_screen.dart';
import 'package:flutter/foundation.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authControllerProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // If successful, the auth state will be updated automatically
      // and the user will be redirected to the dashboard
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid login credentials') || errorString.contains('invalid credentials')) {
      return 'Invalid email or password';
    } else if (errorString.contains('email not confirmed') || errorString.contains('email confirmation')) {
      return 'Please check your email and confirm your account before signing in';
    } else if (errorString.contains('too many requests') || errorString.contains('rate limit')) {
      return 'Too many login attempts. Please try again later';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorString.contains('supabase is not initialized') || errorString.contains('service not ready')) {
      return 'Initializing services... Please wait a moment and try again.';
    } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('server error') || errorString.contains('internal error')) {
      return 'Server error. Please try again in a moment.';
    } else {
      if (kDebugMode) {
        print('🔍 Sign in error: $error');
      }
      return 'Sign in failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔍 SignInScreen: build() called');
    }
    
    final authState = ref.watch(authControllerProvider);
    
    // Show loading indicator when signing in
    final isLoading = authState.isLoading;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo placeholder
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.brandOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'IMR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Welcome text
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Email field
                        IMRTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // Auto-focus password field when email is entered
                            if (value.isNotEmpty && _passwordController.text.isEmpty) {
                              _passwordFocusNode.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password field
                        IMRTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            // Auto-submit when password is entered and email exists
                            if (value.isNotEmpty && _emailController.text.isNotEmpty) {
                              _handleSignIn();
                            }
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFFFFFFF),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            style: IconButton.styleFrom(
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Remember me checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: MaterialStateProperty.resolveWith(
                                (states) => states.contains(MaterialState.selected)
                                    ? context.brandOrange
                                    : Colors.transparent,
                              ),
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Sign in button
                        IMRButton(
                          text: 'Sign In',
                          onPressed: isLoading ? null : _handleSignIn,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),
                        
                        // Forgot password link
                        IMRButton(
                          text: 'Forgot password?',
                          type: IMRButtonType.text,
                          onPressed: () {
                            // TODO: Navigate to forgot password screen
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white30)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.white30)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Sign up link
                        IMRButton(
                          text: 'Don\'t have an account? Sign up',
                          type: IMRButtonType.text,
                          onPressed: () {
                            context.go('/sign-up');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
