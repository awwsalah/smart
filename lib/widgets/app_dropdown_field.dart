import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dropdown form field with consistent spacing — avoids text/arrow overlap.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.decoration = const InputDecoration(),
    this.hint,
    this.selectedItemBuilder,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final InputDecoration decoration;
  final Widget? hint;
  final DropdownButtonBuilder? selectedItemBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      isExpanded: true,
      isDense: false,
      hint: hint,
      decoration: decoration.copyWith(
        contentPadding: AppTheme.fieldContentPadding,
      ),
      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
      dropdownColor: Color.alphaBlend(
        colors.glassFill,
        colors.gradientMid,
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      icon: Icon(Icons.expand_more, color: colors.iconTint),
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
