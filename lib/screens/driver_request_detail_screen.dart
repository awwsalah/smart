import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/contact_buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/loading_view.dart';
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
      AppSnackBar.showError(context, result.error!);
      await _load();
      return;
    }

    setState(() => _request = result.request);
    if (!mounted) return;
    AppSnackBar.showSuccess(context, 'Job accepted');
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
      AppSnackBar.showError(context, result.error!);
      await _load();
      return;
    }

    setState(() => _request = result.request);
    if (!mounted) return;
    AppSnackBar.showSuccess(
      context,
      result.request!.isCompleted ? 'Job completed' : 'Status updated',
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<AuthProvider>().currentUser;
    final request = _request;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Job Detail / Shaqada'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading job…')
          : request == null
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Job not found',
                  message: 'This pickup request may no longer be available.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: context.appColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.list),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.wasteTypeName ?? 'Pickup',
                              style: Theme.of(context).textTheme.titleLarge,
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
                      const SizedBox(height: AppSpacing.section),
                      ..._buildActions(request, driver?.id),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildActions(PickupRequest request, int? driverId) {
    if (_busy) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }

    // Pending pool item — any driver in city can accept.
    if (request.isPending) {
      return [
        GradientButton(
          onPressed: _accept,
          label: 'Accept job',
          icon: Icons.check_circle_outline,
        ),
      ];
    }

    // Only the assigned driver can update or call.
    if (request.driverId != driverId) {
      return [
        EmptyState(
          compact: true,
          icon: Icons.person_off_outlined,
          title: 'Assigned to another driver',
          message: 'You can only manage jobs assigned to you.',
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
      actions.add(const SizedBox(height: AppSpacing.field));
    } else if (request.isCompleted && request.driverId == driverId) {
      actions.add(
        ContactButtons(
          phone: request.clientPhone ?? '',
          callLabel: 'Call Client',
          smsLabel: 'SMS Client',
        ),
      );
      actions.add(const SizedBox(height: AppSpacing.field));
    }

    if (request.isAccepted) {
      actions.add(
        GradientButton(
          onPressed: _advanceStatus,
          label: 'Mark En Route',
          icon: Icons.directions_car_outlined,
        ),
      );
    } else if (request.isEnRoute) {
      actions.add(
        GradientButton(
          onPressed: _advanceStatus,
          label: 'Mark Completed',
          icon: Icons.done_all,
        ),
      );
    } else if (request.isCompleted) {
      actions.add(
        GlassCard(
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: context.appColors.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Job completed — great work!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      row.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value ?? '—',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String? value;
}
