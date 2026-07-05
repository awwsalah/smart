import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_dashboard_counts.dart';
import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../widgets/request_status_widgets.dart';
import 'driver_request_detail_screen.dart';
import 'role_select_screen.dart';

/// Pending pool + active jobs for drivers in their service city.
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _requestService = RequestService();

  DriverDashboardCounts? _counts;
  List<PickupRequest> _pending = [];
  List<PickupRequest> _activeJobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final driver = context.read<AuthProvider>().currentUser;
    if (driver == null) return;

    setState(() => _loading = true);

    final counts = await _requestService.getDriverDashboardCounts(driver);
    final pending = await _requestService.getPendingForDriver(driver);
    final active = driver.id == null
        ? <PickupRequest>[]
        : await _requestService.getActiveJobsForDriver(driver.id!);

    if (!mounted) return;
    setState(() {
      _counts = counts;
      _pending = pending;
      _activeJobs = active;
      _loading = false;
    });
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (_) => false,
    );
  }

  Future<void> _openDetail(PickupRequest request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverRequestDetailScreen(requestId: request.id),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home / Darawal'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Welcome, ${driver?.fullName ?? 'Driver'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (driver?.vehicleType != null) ...[
                    const SizedBox(height: 4),
                    Text('${driver!.vehicleType} • Service city filter active'),
                  ],
                  const SizedBox(height: 16),
                  if (_counts != null) _DashboardCards(counts: _counts!),
                  const SizedBox(height: 24),
                  const Text(
                    'Pending pickups / Sugitaan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_pending.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No pending requests in your service city.'),
                      ),
                    )
                  else
                    ..._pending.map(
                      (request) => _RequestTile(
                        request: request,
                        subtitle: request.addressSummary,
                        onTap: () => _openDetail(request),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'My active jobs / Shaqooyinkayga',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_activeJobs.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No active jobs — accept a pending pickup.'),
                      ),
                    )
                  else
                    ..._activeJobs.map(
                      (request) => _RequestTile(
                        request: request,
                        subtitle: '${request.clientName ?? 'Client'} • ${request.statusLabel}',
                        onTap: () => _openDetail(request),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _DashboardCards extends StatelessWidget {
  const _DashboardCards({required this.counts});

  final DriverDashboardCounts counts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountCard(
            label: 'Pending',
            value: counts.pending,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: 'Active',
            value: counts.accepted,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: 'Done today',
            value: counts.completedToday,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.subtitle,
    required this.onTap,
  });

  final PickupRequest request;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          request.wasteTypeName ?? 'Pickup',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: StatusChip(status: request.status),
        onTap: onTap,
      ),
    );
  }
}
