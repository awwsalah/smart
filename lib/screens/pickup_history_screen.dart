import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/request_list_tile.dart';
import 'request_detail_screen.dart';

/// Completed and cancelled pickups for the logged-in client.
class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen> {
  final _requestService = RequestService();
  List<PickupRequest> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = context.read<AuthProvider>().currentUser;
    if (client?.id == null) return;

    setState(() => _loading = true);
    final history = await _requestService.getClientHistory(client!.id!);
    if (!mounted) return;
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup History / Taariikhda'),
      ),
      body: _loading
          ? const LoadingView()
          : _history.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'No pickup history',
                  message:
                      'Completed and cancelled requests will show up here.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.list),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final request = _history[index];
                      return RequestListTile(
                        request: request,
                        subtitle:
                            '${request.preferredDate ?? request.createdAt ?? ''} • ${request.statusLabel}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestDetailScreen(
                                requestId: request.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
