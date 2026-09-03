import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/core/money/currency.dart';
import 'package:splitwise_clone/core/money/money.dart';

void main() {
  group('Money', () {
    test('should_build_from_major_units_when_given_decimal_dollars', () {
      final money = Money.fromMajor(12.34, Currency.usd);
      expect(money.minorUnits, 1234);
    });

    test('should_round_half_away_from_zero_when_converting_major', () {
      expect(Money.fromMajor(0.005, Currency.usd).minorUnits, 1);
      expect(Money.fromMajor(-0.005, Currency.usd).minorUnits, -1);
    });

    test('should_handle_zero_decimal_currency_like_jpy', () {
      final money = Money.fromMajor(500, Currency.jpy);
      expect(money.minorUnits, 500);
      expect(money.currency.decimalDigits, 0);
    });

    test('should_add_and_subtract_without_float_drift', () {
      var sum = const Money.zero(Currency.usd);
      for (var i = 0; i < 10; i++) {
        sum = sum + Money.fromMajor(0.10, Currency.usd);
      }
      // 0.10 * 10 in doubles drifts; integer cents does not.
      expect(sum.minorUnits, 100);
    });

    test('should_expose_sign_helpers', () {
      expect(const Money(-5, Currency.usd).isNegative, isTrue);
      expect(const Money(5, Currency.usd).isPositive, isTrue);
      expect(const Money.zero(Currency.usd).isZero, isTrue);
    });

    test('should_negate_and_abs', () {
      const m = Money(-250, Currency.usd);
      expect((-m).minorUnits, 250);
      expect(m.abs.minorUnits, 250);
    });

    test('should_compare_and_be_value_equal', () {
      expect(const Money(100, Currency.usd) == const Money(100, Currency.usd),
          isTrue);
      expect(const Money(100, Currency.usd) > const Money(50, Currency.usd),
          isTrue);
    });
  });
}
