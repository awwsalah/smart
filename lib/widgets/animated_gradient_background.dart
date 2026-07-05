import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Slowly shifting navy gradient behind every screen.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final v = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + v, -1),
              end: Alignment(1, 1 - v),
              colors: [
                colors.gradientTop,
                colors.gradientMid,
                colors.gradientBottom,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
