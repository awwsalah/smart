import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared form field decoration padding — keeps labels from overlapping values.
class AppForm {
  AppForm._();

  static const fieldSpacing = SizedBox(height: AppSpacing.field);
  static const sectionSpacing = SizedBox(height: AppSpacing.section);

  static const contentPadding = AppTheme.fieldContentPadding;

  static InputDecoration decoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    final colors = context.appColors;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: colors.glassFill,
      contentPadding: contentPadding,
      labelStyle: Theme.of(context).textTheme.bodySmall,
      hintStyle: Theme.of(context).textTheme.bodySmall,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        borderSide: BorderSide(color: colors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        borderSide: BorderSide(color: colors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        borderSide: const BorderSide(color: Color(0xFFF43F5E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 2),
      ),
    );
  }
}

/// Text form field with consistent glass styling and spacing.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: AppForm.decoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}

/// Tappable date field matching dropdown styling and theme colors.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.labelText,
    required this.value,
    required this.onTap,
    this.hintText = 'Tap to choose date',
  });

  final String labelText;
  final DateTime? value;
  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
      child: InputDecorator(
        decoration: AppForm.decoration(
          context,
          labelText: labelText,
          hintText: hasValue ? null : hintText,
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: colors.iconTint,
            size: 22,
          ),
        ),
        child: hasValue
            ? Text(
                MaterialLocalizations.of(context).formatMediumDate(value!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
              )
            : const SizedBox(height: 20),
      ),
    );
  }
}

/// Themed date picker dialog matching the app palette.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final colors = context.appColors;
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: colors.accent,
            onPrimary: colors.onAccent,
            surface: colors.gradientMid,
            onSurface: colors.textPrimary,
            onSurfaceVariant: colors.textSecondary,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: colors.gradientMid,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
