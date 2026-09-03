import 'package:intl/intl.dart';

import '../money/money.dart';

/// Formats [Money] for display using `intl`. This is the single place where a
/// money value crosses from integer minor units into a human-readable string.
class MoneyFormatter {
  const MoneyFormatter({this.locale});

  final String? locale;

  String format(Money money) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: money.currency.symbol,
      decimalDigits: money.currency.decimalDigits,
    );
    return format.format(money.asMajor);
  }

  /// Absolute value with an explicit leading sign — handy for balance rows
  /// ("you are owed" vs "you owe").
  String formatSigned(Money money) {
    final sign = money.isNegative ? '-' : '';
    return '$sign${format(money.abs)}';
  }
}

/// Ambient default formatter (device locale).
const moneyFormatter = MoneyFormatter();
