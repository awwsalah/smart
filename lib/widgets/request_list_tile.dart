import 'package:flutter/material.dart';

import '../models/pickup_request.dart';
import 'request_status_widgets.dart';

/// Consistent request row for client and driver lists.
class RequestListTile extends StatelessWidget {
  const RequestListTile({
    super.key,
    required this.request,
    required this.onTap,
    this.subtitle,
  });

  final PickupRequest request;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          request.wasteTypeName ?? 'Pickup request',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!),
              )
            : null,
        trailing: StatusChip(status: request.status),
        onTap: onTap,
      ),
    );
  }
}
