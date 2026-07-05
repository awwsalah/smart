import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Frosted-glass card with optional tap. Use [GlassCard.lite] inside ListViews.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.cardPadding),
    this.blur = 12,
    this.onTap,
    this.margin,
    this.lite = false,
  });

  const GlassCard.lite({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.cardPadding),
    this.onTap,
    this.margin,
  })  : blur = 0,
        lite = true;

  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool lite;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.glassFill,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: colors.glassBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (!lite && blur > 0) {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: surface,
        ),
      );
    } else {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: surface,
      );
    }

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: surface,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
