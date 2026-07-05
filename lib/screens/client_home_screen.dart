import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/request_list_tile.dart';
import 'new_request_screen.dart';
import 'pickup_history_screen.dart';
import 'profile_screen.dart';
import 'request_detail_screen.dart';
import 'role_select_screen.dart';

/// Lists the client's pickup requests with a New Request action.
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _requestService = RequestService();
  List<PickupRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final client = context.read<AuthProvider>().currentUser;
    if (client?.id == null) return;

    setState(() => _loading = true);
    final requests = await _requestService.getClientRequests(client!.id!);
    if (!mounted) return;
    setState(() {
      _requests = requests;
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

  Future<void> _openNewRequest() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewRequestScreen()),
    );
    await _loadRequests();
  }

  Future<void> _openDetail(PickupRequest request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(requestId: request.id),
      ),
    );
    await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests / Codsiyadayda'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PickupHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'History',
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
          ? const LoadingView(message: 'Loading your requests…')
          : _requests.isEmpty
              ? EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No pickup requests yet',
                  message:
                      'Schedule your first waste collection with the button below.',
                  actionLabel: 'New Request',
                  onAction: _openNewRequest,
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.list),
                    itemCount: _requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return RequestListTile(
                        request: request,
                        subtitle:
                            '${request.addressSummary}\n${request.preferredDate ?? ''} • ${request.preferredSlot ?? ''}',
                        onTap: () => _openDetail(request),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRequest,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}
