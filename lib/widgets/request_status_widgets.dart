import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Glass pill showing request status with colored dot.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            AppTheme.prettyStatus(status),
            style: GoogleFonts.manrope(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual step tracker for pending → accepted → en_route → completed.
class RequestStatusTracker extends StatelessWidget {
  const RequestStatusTracker({super.key, required this.status});

  final String status;

  static const _steps = ['pending', 'accepted', 'en_route', 'completed'];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return GlassCard(
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: AppTheme.statusColor('cancelled'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This request was cancelled.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexOf(status);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking / Raadraaca',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            final isDone = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final stepColor = AppTheme.statusColor(step);
            final labels = {
              'pending': 'Pending — waiting for driver',
              'accepted': 'Accepted — driver assigned',
              'en_route': 'En route — driver on the way',
              'completed': 'Completed — waste collected',
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCurrent
                        ? stepColor
                        : isDone
                            ? AppTheme.statusColor('completed')
                            : context.appColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      labels[step] ?? step,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isDone
                                ? context.appColors.textPrimary
                                : context.appColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
