import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

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
    final colors = context.appColors;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 40 : 64,
          color: colors.accent,
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
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel!),
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
