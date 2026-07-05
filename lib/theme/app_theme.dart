import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTheme {
  AppTheme._();

  static const double radiusCard = 24;
  static const double radiusChip = 999;
  static const double radiusButton = 16;
  static const double cardPadding = 20;
  static const EdgeInsets fieldContentPadding =
      EdgeInsets.fromLTRB(16, 18, 16, 14);

  /// Soft gold for star ratings (not the orange CTA accent).
  static const Color starColor = Color(0xFFFBBF24);

  /// Status colors 
  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'en_route':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFF43F5E);
      default:
        return const Color(0xFF38BDF8);
    }
  }

  static String prettyStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'en_route':
        return 'En Route';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static ThemeData get light => _build(AppColors.light);

  static ThemeData get dark => _build(AppColors.dark);

  static ThemeData _build(AppColors colors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.accent,
      brightness: colors.brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.accentSecondary,
      onSecondary: colors.onAccent,
      surface: Colors.transparent,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceTint: Colors.transparent,
    );

    final sora = GoogleFonts.soraTextTheme();
    final manrope = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      extensions: [colors],
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
      ),
      textTheme: TextTheme(
        displaySmall: sora.displaySmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        titleLarge: sora.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyMedium: manrope.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        bodySmall: manrope.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onGradient,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.onGradient,
        ),
        iconTheme: IconThemeData(color: colors.onGradient),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.glassFill,
        contentPadding: fieldContentPadding,
        labelStyle: GoogleFonts.manrope(color: colors.textSecondary),
        hintStyle: GoogleFonts.manrope(color: colors.textSecondary),
        prefixIconColor: colors.iconTint,
        suffixIconColor: colors.iconTint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: colors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: Color(0xFFF43F5E)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.accentSecondary,
          side: BorderSide(color: colors.accentSecondary.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accentSecondary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.glassBorder,
        space: AppSpacing.lg,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.glassFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
    );
  }
}

/// Navy + coral palette via ThemeExtension.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.gradientTop,
    required this.gradientMid,
    required this.gradientBottom,
    required this.accent,
    required this.accentSecondary,
    required this.iconTint,
    required this.onGradient,
    required this.onAccent,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Brightness brightness;
  final Color gradientTop;
  final Color gradientMid;
  final Color gradientBottom;
  final Color accent;
  final Color accentSecondary;
  final Color iconTint;
  final Color onGradient;
  final Color onAccent;
  final Color glassFill;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;

  static const light = AppColors(
    brightness: Brightness.light,
    gradientTop: Color(0xFF0F172A),
    gradientMid: Color(0xFF1E293B),
    gradientBottom: Color(0xFF1E3A8A),
    accent: Color(0xFFF97316),
    accentSecondary: Color(0xFF7DD3FC),
    iconTint: Color(0xFFA5F3FC),
    onGradient: Color(0xFFF8FAFC),
    onAccent: Color(0xFFFFFFFF),
    glassFill: Color(0x1FFFFFFF),
    glassBorder: Color(0x38FFFFFF),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
  );

  static const dark = AppColors(
    brightness: Brightness.dark,
    gradientTop: Color(0xFF020617),
    gradientMid: Color(0xFF0F172A),
    gradientBottom: Color(0xFF172554),
    accent: Color(0xFFFB923C),
    accentSecondary: Color(0xFFBAE6FD),
    iconTint: Color(0xFFCFFAFE),
    onGradient: Color(0xFFF1F5F9),
    onAccent: Color(0xFFFFFFFF),
    glassFill: Color(0x14FFFFFF),
    glassBorder: Color(0x24FFFFFF),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
  );

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? gradientTop,
    Color? gradientMid,
    Color? gradientBottom,
    Color? accent,
    Color? accentSecondary,
    Color? iconTint,
    Color? onGradient,
    Color? onAccent,
    Color? glassFill,
    Color? glassBorder,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      gradientTop: gradientTop ?? this.gradientTop,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientBottom: gradientBottom ?? this.gradientBottom,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      iconTint: iconTint ?? this.iconTint,
      onGradient: onGradient ?? this.onGradient,
      onAccent: onAccent ?? this.onAccent,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      gradientTop: Color.lerp(gradientTop, other.gradientTop, t)!,
      gradientMid: Color.lerp(gradientMid, other.gradientMid, t)!,
      gradientBottom: Color.lerp(gradientBottom, other.gradientBottom, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      iconTint: Color.lerp(iconTint, other.iconTint, t)!,
      onGradient: Color.lerp(onGradient, other.onGradient, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

/// spacing tokens.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Backward-compatible aliases used across screens.
  static const double screen = md;
  static const double list = md;
  static const double field = md;
  static const double section = lg;
}
