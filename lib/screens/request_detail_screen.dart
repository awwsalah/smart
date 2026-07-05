import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../models/rating.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/contact_buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/request_status_widgets.dart';
import 'rate_feedback_screen.dart';

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
  Rating? _rating;
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
    Rating? rating;
    if (request != null && request.isCompleted) {
      rating = await _requestService.getRating(widget.requestId);
    }
    if (!mounted) return;
    setState(() {
      _request = request;
      _rating = rating;
      _loading = false;
    });
  }

  Future<void> _cancelRequest() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel request?'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for cancellation',
            ),
            maxLines: 2,
            validator: Validators.cancelReason,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Cancel pickup'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    if (!mounted) {
      reasonController.dispose();
      return;
    }

    final client = context.read<AuthProvider>().currentUser;
    if (client == null) {
      reasonController.dispose();
      return;
    }

    setState(() => _busy = true);
    final result = await _requestService.cancelRequest(
      client: client,
      requestId: widget.requestId,
      reason: reasonController.text,
    );
    reasonController.dispose();

    if (!mounted) return;
    setState(() => _busy = false);

    if (result.error != null) {
      AppSnackBar.showError(context, result.error!);
      return;
    }

    setState(() => _request = result.request);
    AppSnackBar.showSuccess(context, 'Request cancelled');
  }

  Future<void> _openRating() async {
    final rating = await Navigator.push<Rating>(
      context,
      MaterialPageRoute(
        builder: (_) => RateFeedbackScreen(requestId: widget.requestId),
      ),
    );
    if (rating != null) {
      setState(() => _rating = rating);
    } else {
      await _load();
    }
  }

  bool get _canCancel {
    final request = _request;
    return request != null &&
        (request.isPending || request.isAccepted);
  }

  bool get _canRate {
    final request = _request;
    return request != null && request.isCompleted && _rating == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Detail / Faahfaahin'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading request…')
          : _request == null
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Request not found',
                  message: 'This pickup request may have been removed.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.list),
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
                          if (_request!.note != null)
                            _Row('Note', _request!.note),
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
                      if (_rating != null) ...[
                        const SizedBox(height: 12),
                        RatingSummary(rating: _rating!),
                      ],
                      const SizedBox(height: AppSpacing.section),
                      if (_busy)
                        const LoadingView()
                      else ...[
                        if (_canCancel)
                          OutlinedButton.icon(
                            onPressed: _cancelRequest,
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ),
                        if (_canCancel && _canRate)
                          const SizedBox(height: AppSpacing.field),
                        if (_canRate)
                          FilledButton.icon(
                            onPressed: _openRating,
                            icon: const Icon(Icons.star_outline),
                            label: const Text('Rate this pickup'),
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
