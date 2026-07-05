import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'gradient_button.dart';
import 'icon_badge.dart';

/// Reusable empty list / section placeholder with gentle motion.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBadge(
          icon: icon,
          size: compact ? 56 : 72,
          iconSize: compact ? 28 : 36,
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.06, 1.06),
              duration: 1800.ms,
              curve: Curves.easeInOut,
            ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          GradientButton(
            onPressed: onAction,
            label: actionLabel!,
            icon: Icons.add,
            expanded: false,
          ),
        ],
      ],
    );

    if (compact) {
      return GlassCard.lite(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: content,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: GlassCard(
          child: content,
        )
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),
      ),
    );
  }
}
