import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Primary CTA: mint→emerald gradient with press scale feedback.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.expanded = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool expanded;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = widget.onPressed != null;

    final button = AnimatedScale(
      scale: _pressed && enabled ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          gradient: LinearGradient(
            colors: enabled
                ? [colors.accent, colors.gradientMid]
                : [colors.glassFill, colors.glassFill],
          ),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: enabled
                          ? const Color(0xFF0F172A)
                          : colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: enabled
                          ? const Color(0xFF0F172A)
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
