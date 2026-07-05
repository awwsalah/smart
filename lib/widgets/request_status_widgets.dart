import 'package:flutter/material.dart';

/// Coloured chip showing request status.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  Color _color(BuildContext context) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'en_route':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _label() {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'en_route':
        return 'En Route';
      case 'completed':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        _label(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
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
      return Card(
        color: Colors.grey.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.grey),
              SizedBox(width: 12),
              Text('This request was cancelled.'),
            ],
          ),
        ),
      );
    }

    final currentIndex = _steps.indexOf(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking / Raadraaca',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isDone = index <= currentIndex;
              final isCurrent = index == currentIndex;
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
                          ? Theme.of(context).colorScheme.primary
                          : isDone
                              ? Colors.green
                              : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        labels[step] ?? step,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
