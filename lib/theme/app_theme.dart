import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single selectable Material You accent option.
class AppAccent {
  final String name;
  final Color seed;
  const AppAccent(this.name, this.seed);
}

/// The palette of seed colors the user can choose from. Material 3 derives the
/// entire tonal color scheme (primary, secondary, surfaces, etc.) from each seed
/// for both light and dark modes.
const List<AppAccent> kAppAccents = [
  AppAccent('Emerald', Color(0xFF2E7D6B)),
  AppAccent('Indigo', Color(0xFF4255A4)),
  AppAccent('Violet', Color(0xFF7E57C2)),
  AppAccent('Rose', Color(0xFFB5446E)),
  AppAccent('Amber', Color(0xFFC07A2E)),
  AppAccent('Ocean', Color(0xFF1E88A8)),
  AppAccent('Crimson', Color(0xFFC0392B)),
  AppAccent('Forest', Color(0xFF4E7A3A)),
];

class AppTheme {
  static ThemeData _build(Color seed, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.interTextTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData light(Color seed) => _build(seed, Brightness.light);
  static ThemeData dark(Color seed) => _build(seed, Brightness.dark);
}
