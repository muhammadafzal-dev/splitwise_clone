import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/features/expenses/domain/balance/split_calculator.dart';
import 'package:splitwise_clone/features/expenses/domain/balance/split_exception.dart';

import '../support/expense_builders.dart';

void main() {
  const calc = SplitCalculator();

  int sum(Map<String, int> shares) => shares.values.fold(0, (a, b) => a + b);

  group('SplitCalculator EQUAL', () {
    test('should_distribute_remainder_cents_when_not_divisible', () {
      final shares = calc.computeShares(
        equalExpense(payer: 'a', amount: 1000, participants: ['a', 'b', 'c']),
      );
      // 1000 / 3 -> 334, 333, 333 (first participant gets the extra cent).
      expect(shares['a'], 334);
      expect(shares['b'], 333);
      expect(shares['c'], 333);
      expect(sum(shares), 1000);
    });

    test('should_sum_exactly_to_total_for_awkward_amounts', () {
      final shares = calc.computeShares(
        equalExpense(
          payer: 'a',
          amount: 10001,
          participants: ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
        ),
      );
      expect(sum(shares), 10001);
    });

    test('should_give_whole_amount_to_single_participant', () {
      final shares = calc.computeShares(
        equalExpense(payer: 'a', amount: 777, participants: ['a']),
      );
      expect(shares, {'a': 777});
    });

    test('should_throw_when_no_participants', () {
      expect(
        () => calc.computeShares(
          equalExpense(payer: 'a', amount: 100, participants: []),
        ),
        throwsA(isA<SplitException>()),
      );
    });

    test('should_handle_zero_amount', () {
      final shares = calc.computeShares(
        equalExpense(payer: 'a', amount: 0, participants: ['a', 'b']),
      );
      expect(sum(shares), 0);
    });
  });

  group('SplitCalculator EXACT', () {
    test('should_return_provided_shares_when_they_sum_to_total', () {
      final shares = calc.computeShares(
        exactExpense(payer: 'a', amount: 1000, shares: {'a': 600, 'b': 400}),
      );
      expect(shares, {'a': 600, 'b': 400});
    });

    test('should_throw_when_shares_over_total', () {
      expect(
        () => calc.computeShares(
          exactExpense(payer: 'a', amount: 1000, shares: {'a': 600, 'b': 500}),
        ),
        throwsA(isA<SplitException>()),
      );
    });

    test('should_throw_when_shares_under_total', () {
      expect(
        () => calc.computeShares(
          exactExpense(payer: 'a', amount: 1000, shares: {'a': 600, 'b': 300}),
        ),
        throwsA(isA<SplitException>()),
      );
    });

    test('should_throw_when_a_share_is_negative', () {
      expect(
        () => calc.computeShares(
          exactExpense(
            payer: 'a',
            amount: 1000,
            shares: {'a': 1200, 'b': -200},
          ),
        ),
        throwsA(isA<SplitException>()),
      );
    });
  });

  group('SplitCalculator PERCENT', () {
    test('should_apply_largest_remainder_rounding', () {
      final shares = calc.computeShares(
        percentExpense(
          payer: 'a',
          amount: 1000,
          basisPoints: {'a': 3333, 'b': 3333, 'c': 3334},
        ),
      );
      // c has the largest remainder, so it absorbs the leftover cent.
      expect(shares['a'], 333);
      expect(shares['b'], 333);
      expect(shares['c'], 334);
      expect(sum(shares), 1000);
    });

    test('should_break_remainder_ties_by_participant_order', () {
      final shares = calc.computeShares(
        percentExpense(
          payer: 'a',
          amount: 1001,
          basisPoints: {'a': 5000, 'b': 5000},
        ),
      );
      // Equal remainders -> first participant gets the extra cent.
      expect(shares['a'], 501);
      expect(shares['b'], 500);
      expect(sum(shares), 1001);
    });

    test('should_throw_when_percentages_do_not_sum_to_100', () {
      expect(
        () => calc.computeShares(
          percentExpense(
            payer: 'a',
            amount: 1000,
            basisPoints: {'a': 5000, 'b': 4000},
          ),
        ),
        throwsA(isA<SplitException>()),
      );
    });

    test('should_sum_exactly_for_three_equal_thirds', () {
      final shares = calc.computeShares(
        percentExpense(
          payer: 'a',
          amount: 100,
          basisPoints: {'a': 3333, 'b': 3333, 'c': 3334},
        ),
      );
      expect(sum(shares), 100);
    });
  });
}
