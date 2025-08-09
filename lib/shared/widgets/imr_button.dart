import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// IMRButton widget for consistent button styling
/// 
/// This widget provides themed buttons following the IMR design system.
enum IMRButtonType { primary, secondary, text }

class IMRButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IMRButtonType type;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  
  const IMRButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = IMRButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case IMRButtonType.primary:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.brandOrange,
              foregroundColor: context.pureWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          ),
        );
      case IMRButtonType.secondary:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.brandOrange,
              side: const BorderSide(color: Color(0xFFF57C00), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          ),
        );
      case IMRButtonType.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: context.brandOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
        );
    }
  }
}
