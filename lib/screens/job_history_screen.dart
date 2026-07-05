import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/request_list_tile.dart';
import 'driver_request_detail_screen.dart';

/// Completed jobs for the logged-in driver.
class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  final _requestService = RequestService();
  List<PickupRequest> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final driver = context.read<AuthProvider>().currentUser;
    if (driver?.id == null) return;

    setState(() => _loading = true);
    final jobs = await _requestService.getDriverJobHistory(driver!.id!);
    if (!mounted) return;
    setState(() {
      _jobs = jobs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Job History / Shaqooyin hore'),
      ),
      body: _loading
          ? const LoadingView()
          : _jobs.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'No completed jobs yet',
                  message:
                      'Jobs you finish will appear here for your records.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: context.appColors.accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.list),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return RequestListTile(
                        request: job,
                        subtitle:
                            '${job.clientName ?? 'Client'} • ${job.preferredDate ?? job.updatedAt ?? ''}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverRequestDetailScreen(
                                requestId: job.id,
                              ),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: (60 * index).ms,
                          )
                          .slideY(begin: 0.12, curve: Curves.easeOutCubic);
                    },
                  ),
                ),
    );
  }
}
