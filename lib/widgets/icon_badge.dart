import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular tinted icon container — soft sky/cyan, never orange CTA accent.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize,
  });

  final IconData icon;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = colors.iconTint;
    final resolvedIconSize = iconSize ?? size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: resolvedIconSize, color: tint),
    );
  }
}
