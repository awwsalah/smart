import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver_dashboard_counts.dart';
import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/request_list_tile.dart';
import '../widgets/section_title.dart';
import 'driver_request_detail_screen.dart';
import 'job_history_screen.dart';
import 'profile_screen.dart';
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JobHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Job history',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const LoadingView(message: 'Loading jobs…')
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.list),
                children: [
                  Text(
                    'Welcome, ${driver?.fullName ?? 'Driver'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (driver?.vehicleType != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${driver!.vehicleType} • Service city filter active',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.list),
                  if (_counts != null) _DashboardCards(counts: _counts!),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle('Pending pickups / Sugitaan'),
                  if (_pending.isEmpty)
                    const EmptyState(
                      compact: true,
                      icon: Icons.inbox_outlined,
                      title: 'No pending pickups',
                      message:
                          'New client requests in your service city will appear here.',
                    )
                  else
                    ..._pending.map(
                      (request) => RequestListTile(
                        request: request,
                        subtitle: request.addressSummary,
                        onTap: () => _openDetail(request),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  const SectionTitle('My active jobs / Shaqooyinkayga'),
                  if (_activeJobs.isEmpty)
                    const EmptyState(
                      compact: true,
                      icon: Icons.work_outline,
                      title: 'No active jobs',
                      message: 'Accept a pending pickup to start a job.',
                    )
                  else
                    ..._activeJobs.map(
                      (request) => RequestListTile(
                        request: request,
                        subtitle:
                            '${request.clientName ?? 'Client'} • ${request.statusLabel}',
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
