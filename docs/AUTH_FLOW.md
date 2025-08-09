# IMR Authentication Flow

## Overview

This document outlines the complete authentication flow for the IMR application, including all screens, user journeys, and design specifications. The authentication system follows the IMR design system with glassmorphism aesthetics and modern UX patterns.

## Authentication Screens

### 1. Sign In Screen (`/auth/signin`)

**Purpose**: Primary entry point for existing users to access the application.

**Design Specifications**:
- **Background**: Gradient backdrop (#2F2F2F → #4A4A4A) with subtle orange blobs at 8-12% opacity
- **Card**: Glass surface (rgba(255,255,255,0.15)) with 20px radius and glass border
- **Layout**: Centered card with max-width 400px on desktop, full-width on mobile
- **Typography**: Poppins for headers, Roboto for body text

**Components**:
- IMR logo (top center)
- "Welcome back" heading (H1, Poppins 600)
- "Sign in to your account" subtitle (Body, Roboto 400)
- Email input field (glass style, 14px radius)
- Password input field (glass style, 14px radius, show/hide toggle)
- "Remember me" checkbox (glass style)
- "Sign In" button (Brand Orange, 14px radius)
- "Forgot password?" link (text button, Brand Orange)
- Divider with "or" text
- "Don't have an account? Sign up" link (text button, Brand Orange)

**Validation**:
- Email: Required, valid email format
- Password: Required, minimum 8 characters
- Show inline error messages below fields
- Disable submit button until valid

**User Journey**:
1. User enters email and password
2. Validation occurs on blur and submit
3. On successful sign in → redirect to dashboard
4. On error → show error message below form
5. "Forgot password?" → navigate to forgot password screen
6. "Sign up" → navigate to sign up screen

**Error States**:
- Invalid credentials: "Invalid email or password"
- Network error: "Connection failed. Please try again."
- Account locked: "Account temporarily locked. Please try again later."

---

### 2. Sign Up Screen (`/auth/signup`)

**Purpose**: New user registration with email verification.

**Design Specifications**:
- Same background and card styling as sign in
- Two-step process: Account details → Email verification

**Step 1 - Account Details**:
- IMR logo (top center)
- "Create your account" heading (H1, Poppins 600)
- "Join I Manage Risk today" subtitle (Body, Roboto 400)
- First name input field (required)
- Last name input field (required)
- Email input field (required, valid email format)
- Password input field (required, minimum 8 characters, strength indicator)
- Confirm password input field (required, must match password)
- "I agree to the Terms of Service and Privacy Policy" checkbox (required)
- "Create Account" button (Brand Orange, 14px radius)
- "Already have an account? Sign in" link (text button, Brand Orange)

**Step 2 - Email Verification**:
- Email icon (large, centered)
- "Check your email" heading (H1, Poppins 600)
- "We've sent a verification link to {email}" subtitle (Body, Roboto 400)
- "Didn't receive the email?" text
- "Resend verification email" button (outlined, Brand Orange)
- "Back to sign in" link (text button, Brand Orange)

**Validation**:
- First name: Required, 2-50 characters
- Last name: Required, 2-50 characters
- Email: Required, valid email format, unique
- Password: Required, minimum 8 characters, at least one uppercase, one lowercase, one number
- Confirm password: Must match password
- Terms: Must be accepted

**User Journey**:
1. User fills out account details
2. Validation occurs on blur and submit
3. On successful registration → show email verification screen
4. User clicks verification link in email → redirect to dashboard
5. "Sign in" → navigate to sign in screen

**Error States**:
- Email already exists: "An account with this email already exists"
- Weak password: "Password must be at least 8 characters with uppercase, lowercase, and number"
- Network error: "Connection failed. Please try again."

---

### 3. Forgot Password Screen (`/auth/forgot-password`)

**Purpose**: Allow users to request password reset via email.

**Design Specifications**:
- Same background and card styling as other auth screens
- Simple, focused design

**Components**:
- IMR logo (top center)
- "Forgot your password?" heading (H1, Poppins 600)
- "Enter your email address and we'll send you a link to reset your password" subtitle (Body, Roboto 400)
- Email input field (glass style, 14px radius)
- "Send reset link" button (Brand Orange, 14px radius)
- "Back to sign in" link (text button, Brand Orange)

**Validation**:
- Email: Required, valid email format

**User Journey**:
1. User enters email address
2. Validation occurs on blur and submit
3. On successful request → show confirmation screen
4. User receives email with reset link
5. "Back to sign in" → navigate to sign in screen

**Confirmation Screen**:
- Email icon (large, centered)
- "Check your email" heading (H1, Poppins 600)
- "We've sent a password reset link to {email}" subtitle (Body, Roboto 400)
- "Didn't receive the email?" text
- "Resend reset email" button (outlined, Brand Orange)
- "Back to sign in" link (text button, Brand Orange)

**Error States**:
- Email not found: "No account found with this email address"
- Network error: "Connection failed. Please try again."

---

### 4. Reset Password Screen (`/auth/reset-password`)

**Purpose**: Allow users to set a new password using a reset token.

**Design Specifications**:
- Same background and card styling as other auth screens
- Token validation before showing form

**Components**:
- IMR logo (top center)
- "Reset your password" heading (H1, Poppins 600)
- "Enter your new password below" subtitle (Body, Roboto 400)
- New password input field (glass style, 14px radius, strength indicator)
- Confirm new password input field (glass style, 14px radius)
- "Reset Password" button (Brand Orange, 14px radius)

**Validation**:
- New password: Required, minimum 8 characters, at least one uppercase, one lowercase, one number
- Confirm password: Must match new password
- Token: Must be valid and not expired

**User Journey**:
1. User clicks reset link from email
2. Token is validated automatically
3. If valid → show reset password form
4. If invalid/expired → show error message
5. User enters new password
6. Validation occurs on blur and submit
7. On successful reset → redirect to sign in screen with success message

**Error States**:
- Invalid token: "This reset link is invalid or has expired"
- Weak password: "Password must be at least 8 characters with uppercase, lowercase, and number"
- Network error: "Connection failed. Please try again."

---

## Shared Components

### GlassCard Widget
```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.glassBorder),
        boxShadow: [
          BoxShadow(
            color: context.shadowGrey,
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
```

### IMRTextField Widget
```dart
class IMRTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  
  const IMRTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.validator,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFFFFFF),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFF57C00),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x99FFFFFF),
        ),
      ),
    );
  }
}
```

### IMRButton Widget
```dart
class IMRButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IMRButtonType type;
  final bool isLoading;
  
  const IMRButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = IMRButtonType.primary,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case IMRButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.brandOrange,
            foregroundColor: context.pureWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                  ),
                )
              : Text(text),
        );
      case IMRButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: context.brandOrange,
            side: const BorderSide(color: Color(0xFFF57C00), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57C00)),
                  ),
                )
              : Text(text),
        );
      case IMRButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: context.brandOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57C00)),
                  ),
                )
              : Text(text),
        );
    }
  }
}

enum IMRButtonType { primary, secondary, text }
```

## Navigation Flow

```
Sign In (/auth/signin)
├── Forgot Password (/auth/forgot-password)
│   └── Reset Password (/auth/reset-password)
├── Sign Up (/auth/signup)
│   └── Email Verification (/auth/verify-email)
└── Dashboard (/dashboard) [on successful sign in]

Sign Up (/auth/signup)
├── Email Verification (/auth/verify-email)
└── Dashboard (/dashboard) [on successful verification]

Forgot Password (/auth/forgot-password)
├── Reset Password (/auth/reset-password)
└── Sign In (/auth/signin) [on successful reset]
```

## State Management

### Authentication Provider
```dart
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final SupabaseService _supabaseService;
  
  AuthController(this._supabaseService) : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    try {
      final user = await _supabaseService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _supabaseService.signIn(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> signUp(String email, String password, String firstName, String lastName) async {
    state = const AsyncValue.loading();
    try {
      final user = await _supabaseService.signUp(email, password, firstName, lastName);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}
```

## Security Considerations

1. **Password Requirements**: Minimum 8 characters, at least one uppercase, one lowercase, one number
2. **Email Verification**: Required for new accounts
3. **Rate Limiting**: Implement on sign in, sign up, and password reset
4. **Session Management**: Short JWT lifetimes with refresh tokens
5. **Input Validation**: Client-side and server-side validation
6. **Error Messages**: Generic error messages to prevent information leakage
7. **HTTPS**: All authentication requests over HTTPS
8. **CSRF Protection**: Implement CSRF tokens for sensitive operations

## Accessibility

1. **Screen Reader Support**: Semantic labels for all form fields
2. **Keyboard Navigation**: Full keyboard accessibility
3. **Focus Management**: Visible focus indicators
4. **Color Contrast**: AA minimum contrast ratios
5. **Error Announcements**: Screen reader announcements for errors
6. **Alternative Text**: Descriptive alt text for images and icons

## Testing Scenarios

### Sign In
- [ ] Valid credentials → successful sign in
- [ ] Invalid email format → validation error
- [ ] Invalid password → validation error
- [ ] Non-existent email → error message
- [ ] Network error → error message
- [ ] Empty fields → validation errors

### Sign Up
- [ ] Valid data → successful registration
- [ ] Existing email → error message
- [ ] Weak password → validation error
- [ ] Mismatched passwords → validation error
- [ ] Missing required fields → validation errors
- [ ] Terms not accepted → validation error

### Forgot Password
- [ ] Valid email → confirmation screen
- [ ] Non-existent email → error message
- [ ] Invalid email format → validation error
- [ ] Network error → error message

### Reset Password
- [ ] Valid token → reset form
- [ ] Invalid token → error message
- [ ] Expired token → error message
- [ ] Weak password → validation error
- [ ] Mismatched passwords → validation error

## Implementation Notes

1. **Routing**: Use GoRouter for navigation with route guards
2. **State Management**: Riverpod for authentication state
3. **Validation**: Form validation with proper error handling
4. **Loading States**: Show loading indicators during async operations
5. **Error Handling**: User-friendly error messages
6. **Responsive Design**: Mobile-first approach with breakpoints
7. **Theme Integration**: Use IMR theme tokens throughout
8. **Testing**: Unit tests for controllers, widget tests for screens
