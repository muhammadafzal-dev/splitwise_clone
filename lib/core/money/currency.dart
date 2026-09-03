/// Supported currencies for the app.
///
/// Kept tiny on purpose — a real app would source this from a service, but the
/// value type below only needs the ISO code plus how many minor units make one
/// major unit (2 for USD/EUR, 0 for JPY, 3 for BHD).
enum Currency {
  usd('USD', r'$', 2),
  eur('EUR', '€', 2),
  gbp('GBP', '£', 2),
  jpy('JPY', '¥', 0);

  const Currency(this.code, this.symbol, this.decimalDigits);

  /// ISO 4217 code, e.g. `USD`.
  final String code;

  /// Display symbol, e.g. `$`.
  final String symbol;

  /// Number of minor units in one major unit (cents in a dollar).
  final int decimalDigits;

  /// 10^decimalDigits — the number of minor units per major unit.
  int get minorUnitsPerMajor {
    var factor = 1;
    for (var i = 0; i < decimalDigits; i++) {
      factor *= 10;
    }
    return factor;
  }

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code,
    orElse: () => Currency.usd,
  );
}
