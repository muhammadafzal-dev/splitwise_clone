import 'package:flutter/material.dart';

/// Material 3 light and dark themes built from a single brand seed colour.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1CC29F); // Splitwise-ish teal/green.

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        centerTitle: false,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }
}

/// Semantic colours for balances (positive = owed to you, negative = you owe).
/// Not part of [ColorScheme] because they carry meaning, not brand.
class BalanceColors {
  const BalanceColors._();

  static Color positive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF4ADE80)
          : const Color(0xFF15803D);

  static Color negative(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFB7185)
          : const Color(0xFFBE123C);

  /// Colour for a signed amount: green if owed to you, red if you owe, muted if
  /// settled.
  static Color forAmount(BuildContext context, int minorUnits) {
    if (minorUnits > 0) return positive(context);
    if (minorUnits < 0) return negative(context);
    return Theme.of(context).colorScheme.outline;
  }
}
