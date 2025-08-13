import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// IMRTextField widget for consistent text input styling
/// 
/// This widget provides a glass-styled text field following the IMR design system.
class IMRTextField extends StatefulWidget {
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
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  
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
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
  });
  
  @override
  State<IMRTextField> createState() => _IMRTextFieldState();
}

class _IMRTextFieldState extends State<IMRTextField> {
  late TextEditingController _controller;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(IMRTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the widget is still mounted
    if (_mounted && widget.controller != oldWidget.controller) {
      if (widget.controller != null) {
        _controller = widget.controller!;
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleChanged(String value) {
    if (_mounted && widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  void _handleTap() {
    if (_mounted && widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onTap: _handleTap,
      onChanged: _handleChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFFFFFF),
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0x4DFFFFFF),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xB3FFFFFF), // 70% opacity
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x80FFFFFF), // 50% opacity
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFFD32F2F),
        ),
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
      ),
    );
  }
}
