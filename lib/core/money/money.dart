import 'package:meta/meta.dart';

import 'currency.dart';

/// An immutable money value stored as an integer count of **minor units**
/// (cents), never a floating-point number.
///
/// All arithmetic in the balance/settlement engine goes through this type so
/// that rounding is explicit and totals always reconcile to the cent. Formatting
/// to a human string happens only at the UI edge (see `core/formatting`).
@immutable
class Money implements Comparable<Money> {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  /// Build from a major-unit amount (e.g. dollars) — used by the UI when a user
  /// types `12.34`. Rounds half-away-from-zero to the nearest minor unit.
  factory Money.fromMajor(num major, Currency currency) {
    final scaled = major * currency.minorUnitsPerMajor;
    return Money(scaled.round(), currency);
  }

  /// The raw integer amount in minor units (cents). Signed: negative means owed.
  final int minorUnits;
  final Currency currency;

  bool get isZero => minorUnits == 0;
  bool get isNegative => minorUnits < 0;
  bool get isPositive => minorUnits > 0;

  /// Value in major units as a double — **only** for display/formatting.
  double get asMajor => minorUnits / currency.minorUnitsPerMajor;

  Money get abs => Money(minorUnits.abs(), currency);
  Money operator -() => Money(-minorUnits, currency);

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency);
  }

  Money operator *(int factor) => Money(minorUnits * factor, currency);

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return minorUnits > other.minorUnits;
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return minorUnits < other.minorUnits;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return minorUnits <= other.minorUnits;
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _assertSameCurrency(Money other) {
    assert(
      currency == other.currency,
      'Cannot mix currencies: $currency vs ${other.currency}',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => 'Money($minorUnits ${currency.code})';
}
