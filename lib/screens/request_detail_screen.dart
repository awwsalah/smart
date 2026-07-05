import 'package:flutter/material.dart';

import '../models/pickup_request.dart';
import '../services/request_service.dart';
import '../widgets/contact_buttons.dart';
import '../widgets/request_status_widgets.dart';

/// Shows full request info and a status tracker for the client.
class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _requestService = RequestService();
  PickupRequest? _request;
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Detail / Faahfaahin'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
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
                              _request!.wasteTypeName ?? 'Pickup request',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusChip(status: _request!.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _request!.statusLabel,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      RequestStatusTracker(status: _request!.status),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Details',
                        rows: [
                          _Row('Size', _request!.size),
                          _Row('Date', _request!.preferredDate),
                          _Row('Time slot', _request!.preferredSlot),
                          _Row('Payment', _request!.paymentMethod),
                          _Row(
                            'Est. fee',
                            '\$${_request!.fee.toStringAsFixed(2)}',
                          ),
                          if (_request!.note != null) _Row('Note', _request!.note),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Address / Cinwaanka',
                        rows: [
                          _Row('Location', _request!.addressSummary),
                        ],
                      ),
                      if (_request!.hasDriver &&
                          !_request!.isPending &&
                          !_request!.isCancelled) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'Assigned driver / Darawalka',
                          rows: [
                            _Row('Name', _request!.driverName),
                            _Row('Phone', _request!.driverPhone),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ContactButtons(
                          phone: _request!.driverPhone ?? '',
                          callLabel: 'Call Driver',
                          smsLabel: 'SMS Driver',
                          smsBody:
                              'Hello, regarding my waste pickup request #${_request!.id}.',
                        ),
                      ],
                      if (_request!.isCancelled &&
                          _request!.cancelReason != null) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'Cancellation',
                          rows: [
                            _Row('Reason', _request!.cancelReason),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

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
                      width: 100,
                      child: Text(
                        row.label,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(row.value ?? '—'),
                    ),
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
