import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_theme.dart';

/// Full-screen photo background with a theme-colored scrim for legibility.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.assetPath = AppAssets.backgroundApp,
  });

  final Widget child;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.gradientTop,
                  colors.gradientMid,
                  colors.gradientBottom,
                ],
              ),
            ),
          ),
        ),
        // Navy scrim keeps glass cards readable over bright photos.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.gradientTop.withValues(alpha: 0.50),
                colors.gradientMid.withValues(alpha: 0.62),
                colors.gradientBottom.withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
