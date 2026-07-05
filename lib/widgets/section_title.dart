import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bold section heading — on gradient by default, or inside a glass card.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.inCard = false});

  final String text;
  final bool inCard;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        top: inCard ? AppSpacing.sm : 0,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: inCard ? colors.textPrimary : colors.onGradient,
              fontSize: inCard ? 17 : null,
            ),
      ),
    );
  }
}
