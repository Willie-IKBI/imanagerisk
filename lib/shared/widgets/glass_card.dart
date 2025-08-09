import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// GlassCard widget for creating glassmorphism surfaces
/// 
/// This widget creates a translucent card with glass-like appearance
/// following the IMR design system specifications.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.boxShadow,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.glassSurface,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: context.glassBorder),
        boxShadow: boxShadow ?? [
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
