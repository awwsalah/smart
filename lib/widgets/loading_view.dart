import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'shimmer_skeleton.dart';

/// Shimmer skeleton loading (replaces bare spinner on list screens).
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message,
    this.showSkeleton = true,
  });

  final String? message;
  final bool showSkeleton;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (showSkeleton) {
      return Column(
        children: [
          if (message != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onGradient,
                    ),
              ),
            ),
          ],
          const Expanded(child: ShimmerSkeletonList()),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.accent),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onGradient,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
