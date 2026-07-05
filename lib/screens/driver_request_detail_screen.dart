import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../widgets/contact_buttons.dart';
import '../widgets/request_status_widgets.dart';

/// Driver view: accept job, update status, call client.
class DriverRequestDetailScreen extends StatefulWidget {
  const DriverRequestDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<DriverRequestDetailScreen> createState() =>
      _DriverRequestDetailScreenState();
}

class _DriverRequestDetailScreenState extends State<DriverRequestDetailScreen> {
  final _requestService = RequestService();
  PickupRequest? _request;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final request = await _requestService.getRequest(widget.requestId);
    if (!mounted) return;
    setState(() {
      _request = request;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    final driver = context.read<AuthProvider>().currentUser;
    if (driver == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept this job?'),
        content: const Text(
          'You will be assigned to this pickup and the client can track your status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    final result = await _requestService.acceptRequest(
      requestId: widget.requestId,
      driver: driver,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      await _load();
      return;
    }

    setState(() => _request = result.request);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job accepted')),
    );
  }

  Future<void> _advanceStatus() async {
    final driver = context.read<AuthProvider>().currentUser;
    if (driver == null || _request == null) return;

    final label = _request!.isAccepted ? 'Mark as En Route?' : 'Mark as Completed?';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    final result = await _requestService.advanceStatus(
      requestId: widget.requestId,
      driver: driver,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      await _load();
      return;
    }

    setState(() => _request = result.request);
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<AuthProvider>().currentUser;
    final request = _request;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Detail / Shaqada'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : request == null
              ? const Center(child: Text('Request not found'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.wasteTypeName ?? 'Pickup',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusChip(status: request.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RequestStatusTracker(status: request.status),
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Client / Macmiil',
                        rows: [
                          _Row('Name', request.clientName),
                          _Row('Phone', request.clientPhone),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: 'Pickup details',
                        rows: [
                          _Row('Address', request.addressSummary),
                          _Row('Size', request.size),
                          _Row('Date', request.preferredDate),
                          _Row('Time', request.preferredSlot),
                          _Row('Payment', request.paymentMethod),
                          if (request.note != null) _Row('Note', request.note),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ..._buildActions(request, driver?.id),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildActions(PickupRequest request, int? driverId) {
    if (_busy) {
      return [const Center(child: CircularProgressIndicator())];
    }

    // Pending pool item — any driver in city can accept.
    if (request.isPending) {
      return [
        FilledButton.icon(
          onPressed: _accept,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Accept job'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ];
    }

    // Only the assigned driver can update or call.
    if (request.driverId != driverId) {
      return [
        const Text(
          'This job is assigned to another driver.',
          style: TextStyle(color: Colors.grey),
        ),
      ];
    }

    final actions = <Widget>[];

    if (request.isAccepted || request.isEnRoute) {
      actions.add(
        ContactButtons(
          phone: request.clientPhone ?? '',
          callLabel: 'Call Client',
          smsLabel: 'SMS Client',
          smsBody:
              'Hello, I am your waste pickup driver for request #${request.id}.',
        ),
      );
      actions.add(const SizedBox(height: 12));
    } else if (request.isCompleted && request.driverId == driverId) {
      actions.add(
        ContactButtons(
          phone: request.clientPhone ?? '',
          callLabel: 'Call Client',
          smsLabel: 'SMS Client',
        ),
      );
      actions.add(const SizedBox(height: 12));
    }

    if (request.isAccepted) {
      actions.add(
        FilledButton.icon(
          onPressed: _advanceStatus,
          icon: const Icon(Icons.directions_car_outlined),
          label: const Text('Mark En Route'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    } else if (request.isEnRoute) {
      actions.add(
        FilledButton.icon(
          onPressed: _advanceStatus,
          icon: const Icon(Icons.done_all),
          label: const Text('Mark Completed'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    } else if (request.isCompleted) {
      actions.add(
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('Job completed — great work!'),
              ],
            ),
          ),
        ),
      );
    }

    return actions;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(row.label, style: const TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Text(row.value ?? '—')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String? value;
}
