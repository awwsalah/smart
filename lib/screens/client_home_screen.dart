import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../widgets/request_status_widgets.dart';
import 'new_request_screen.dart';
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
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? _EmptyRequests(onCreate: _openNewRequest)
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            request.wasteTypeName ?? 'Pickup request',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(request.addressSummary),
                              if (request.preferredDate != null)
                                Text(
                                  '${request.preferredDate} • ${request.preferredSlot ?? ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: StatusChip(status: request.status),
                          onTap: () => _openDetail(request),
                        ),
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

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No pickup requests yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap New Request to schedule your first pickup.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
            ),
          ],
        ),
      ),
    );
  }
}
