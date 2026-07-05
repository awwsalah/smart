import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Shimmer placeholder cards while DB reads load.
class ShimmerSkeletonList extends StatelessWidget {
  const ShimmerSkeletonList({
    super.key,
    this.itemCount = 4,
    this.compact = true,
  });

  final int itemCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Shimmer.fromColors(
      baseColor: colors.glassFill,
      highlightColor: colors.glassBorder,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.list),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => GlassCard.lite(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
