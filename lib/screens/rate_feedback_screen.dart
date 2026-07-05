import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pickup_request.dart';
import '../models/rating.dart';
import '../services/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';

/// 1–5 star rating + optional comment after a completed pickup.
class RateFeedbackScreen extends StatefulWidget {
  const RateFeedbackScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<RateFeedbackScreen> createState() => _RateFeedbackScreenState();
}

class _RateFeedbackScreenState extends State<RateFeedbackScreen> {
  final _requestService = RequestService();
  final _commentController = TextEditingController();

  PickupRequest? _request;
  int _stars = 0;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = await _requestService.getRequest(widget.requestId);
    if (!mounted) return;
    setState(() {
      _request = request;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      AppSnackBar.showError(context, 'Please select a star rating');
      return;
    }

    final client = context.read<AuthProvider>().currentUser;
    if (client == null || _request == null) return;

    setState(() => _submitting = true);
    final result = await _requestService.submitRating(
      client: client,
      request: _request!,
      stars: _stars,
      comment: _commentController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.error != null) {
      AppSnackBar.showError(context, result.error!);
      return;
    }

    Navigator.pop(context, result.rating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Feedback'),
      ),
      body: _loading
          ? const LoadingView(message: 'Loading…')
          : _request == null
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Request not found',
                  message: 'You can only rate completed pickup requests.',
                )
              : Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How was your pickup?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_request!.driverName != null) ...[
                    const SizedBox(height: AppSpacing.field),
                    Text(
                      'Driver: ${_request!.driverName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.section),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        iconSize: 40,
                        onPressed: () => setState(() => _stars = star),
                        icon: Icon(
                          star <= _stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.field),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                    ),
                    maxLines: 3,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit rating'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Shows existing rating on request detail after submit.
class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating.stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comment!),
            ],
          ],
        ),
      ),
    );
  }
}
