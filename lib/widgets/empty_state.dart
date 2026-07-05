import 'package:flutter/material.dart';

/// Reusable empty list / section placeholder.
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
    final colorScheme = Theme.of(context).colorScheme;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: compact ? 40 : 64,
          color: colorScheme.outline,
        ),
        SizedBox(height: compact ? 8 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: compact ? 13 : 14,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: compact ? 12 : 20),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );

    if (compact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: content,
      ),
    );
  }
}
