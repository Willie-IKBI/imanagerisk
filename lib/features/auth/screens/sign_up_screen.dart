import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Focus nodes for better UX
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _showEmailVerification = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    try {
      if (kDebugMode) {
        print('🔐 Starting sign up process...');
        print('📧 Email: ${_emailController.text.trim()}');
        print('👤 First Name: ${_firstNameController.text.trim()}');
        print('👤 Last Name: ${_lastNameController.text.trim()}');
      }

      await ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      
      // If successful, show email verification screen
      if (mounted) {
        setState(() {
          _showEmailVerification = true;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email for verification before signing in.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up failed with error: $e');
        print('🔍 Error type: ${e.runtimeType}');
        print('🔍 Error string: ${e.toString()}');
        print('🔍 Error hash: ${e.hashCode}');
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Log the full error details for debugging
    if (kDebugMode) {
      print('🔍 Full error object: $error');
      print('🔍 Error string: $errorString');
      print('🔍 Error type: ${error.runtimeType}');
      print('🔍 Error hash: ${error.hashCode}');
    }
    
    // Check for specific error patterns
    if (errorString.contains('user already registered') || errorString.contains('already registered')) {
      return 'An account with this email already exists';
    } else if (errorString.contains('password should be at least') || errorString.contains('password')) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and number';
    } else if (errorString.contains('invalid email') || errorString.contains('email')) {
      return 'Please enter a valid email address';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorString.contains('supabase is not initialized') || errorString.contains('service not ready')) {
      return 'Initializing services... Please wait a moment and try again.';
    } else if (errorString.contains('rate limit') || errorString.contains('too many requests')) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (errorString.contains('email confirmation')) {
      return 'Email confirmation is required. Please check your email.';
    } else if (errorString.contains('weak password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (errorString.contains('invalid credentials')) {
      return 'Invalid credentials. Please check your information.';
    } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('server error') || errorString.contains('internal error')) {
      return 'Server error. Please try again in a moment.';
    } else if (errorString.contains('authapi') || errorString.contains('auth api')) {
      return 'Authentication service error. Please try again.';
    } else if (errorString.contains('gotrue') || errorString.contains('go true')) {
      return 'Authentication service error. Please try again.';
    } else if (errorString.contains('http') || errorString.contains('status')) {
      return 'Connection error. Please check your internet and try again.';
    } else if (errorString.contains('sign up failed') || errorString.contains('signup failed')) {
      return 'Account creation failed. Please try again.';
    } else if (errorString.contains('no user returned') || errorString.contains('user returned')) {
      return 'Account creation failed. Please try again.';
    } else if (errorString.contains('environment variable') || errorString.contains('required in production')) {
      return 'Configuration error. Please contact support.';
    } else if (errorString.contains('exception') || errorString.contains('error')) {
      return 'An unexpected error occurred. Please try again.';
    } else {
      // Log the actual error for debugging
      if (kDebugMode) {
        print('🔍 Sign up error: $error');
        print('🔍 Error string: $errorString');
        print('🔍 Error type: ${error.runtimeType}');
      }
      return 'Sign up failed. Please try again.';
    }
  }

  Future<void> _handleResendVerification() async {
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend verification email: ${e.toString()}'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    if (_showEmailVerification) {
      return _buildEmailVerificationScreen();
    }

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
                          'Create your account',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join I Manage Risk today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // First name field
                        IMRTextField(
                          label: 'First Name',
                          hint: 'Enter your first name',
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // Auto-focus last name when first name is entered
                            if (value.isNotEmpty && _lastNameController.text.isEmpty) {
                              _lastNameFocusNode.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First name is required';
                            }
                            if (value.length < 2) {
                              return 'First name must be at least 2 characters';
                            }
                            if (value.length > 50) {
                              return 'First name must be less than 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Last name field
                        IMRTextField(
                          label: 'Last Name',
                          hint: 'Enter your last name',
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // Auto-focus email when last name is entered
                            if (value.isNotEmpty && _emailController.text.isEmpty) {
                              _emailFocusNode.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last name is required';
                            }
                            if (value.length < 2) {
                              return 'Last name must be at least 2 characters';
                            }
                            if (value.length > 50) {
                              return 'Last name must be less than 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field
                        IMRTextField(
                          label: 'Email',
                          hint: 'Enter your email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // Auto-focus password when email is entered
                            if (value.isNotEmpty && _passwordController.text.isEmpty) {
                              _passwordFocusNode.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password field
                        IMRTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // Auto-focus confirm password when password is entered
                            if (value.isNotEmpty && _confirmPasswordController.text.isEmpty) {
                              _confirmPasswordFocusNode.requestFocus();
                            }
                          },
                          validator: _validatePassword,
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
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirm password field
                        IMRTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            // Auto-submit when confirm password is entered and all fields are valid
                            if (value.isNotEmpty && 
                                _firstNameController.text.isNotEmpty &&
                                _lastNameController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty &&
                                _agreeToTerms) {
                              _handleSignUp();
                            }
                          },
                          validator: _validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFFFFFFFF),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            style: IconButton.styleFrom(
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Terms and conditions checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: context.brandOrange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: context.brandOrange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Create account button
                        IMRButton(
                          text: 'Create Account',
                          onPressed: isLoading ? null : _handleSignUp,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sign in link
                        IMRButton(
                          text: 'Already have an account? Sign in',
                          type: IMRButtonType.text,
                          onPressed: () {
                            context.go('/sign-in');
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

  Widget _buildEmailVerificationScreen() {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email icon
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: context.brandOrange,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Heading
                      Text(
                        'Check your email',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'We\'ve sent a verification link to ${_emailController.text}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Additional guidance
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Important: You must confirm your email before you can sign in to your account.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange[200],
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Didn't receive email text
                      Text(
                        'Didn\'t receive the email?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Resend verification button
                      IMRButton(
                        text: 'Resend verification email',
                        type: IMRButtonType.secondary,
                        onPressed: _handleResendVerification,
                      ),
                      const SizedBox(height: 24),
                      
                      // Back to sign in link
                      IMRButton(
                        text: 'Back to sign in',
                        type: IMRButtonType.text,
                        onPressed: () {
                          context.go('/sign-in');
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
    );
  }
}
