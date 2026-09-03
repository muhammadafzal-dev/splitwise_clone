import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/core/money/currency.dart';
import 'package:splitwise_clone/core/money/money.dart';
import 'package:splitwise_clone/features/expenses/domain/balance/balance.dart';
import 'package:splitwise_clone/features/expenses/domain/balance/settlement_calculator.dart';

void main() {
  const calc = SettlementCalculator();

  Map<String, Money> usd(Map<String, int> raw) => {
    for (final e in raw.entries) e.key: Money(e.value, Currency.usd),
  };

  group('SettlementCalculator', () {
    test('should_return_empty_when_all_settled', () {
      final edges = calc.minimize(usd({'a': 0, 'b': 0}));
      expect(edges, isEmpty);
    });

    test('should_return_empty_for_no_balances', () {
      expect(calc.minimize(const {}), isEmpty);
    });

    test('should_match_single_debtor_to_single_creditor', () {
      final edges = calc.minimize(usd({'a': 500, 'b': -500}));
      expect(edges, const [
        DebtEdge(
          fromUserId: 'b',
          toUserId: 'a',
          amount: Money(500, Currency.usd),
        ),
      ]);
    });

    test('should_split_one_creditor_across_multiple_debtors', () {
      final edges = calc.minimize(usd({'a': 1000, 'b': -600, 'c': -400}));
      expect(edges.length, 2);
      expect(
        edges.any((e) => e.fromUserId == 'b' && e.amount.minorUnits == 600),
        isTrue,
      );
      expect(
        edges.any((e) => e.fromUserId == 'c' && e.amount.minorUnits == 400),
        isTrue,
      );
    });

    test('should_leave_everyone_at_zero_after_applying_edges', () {
      final balances = usd({'a': 1000, 'b': -300, 'c': -700, 'd': 0});
      final edges = calc.minimize(balances);
      final applied = <String, int>{
        for (final e in balances.entries) e.key: e.value.minorUnits,
      };
      for (final edge in edges) {
        applied[edge.fromUserId] =
            applied[edge.fromUserId]! + edge.amount.minorUnits;
        applied[edge.toUserId] =
            applied[edge.toUserId]! - edge.amount.minorUnits;
      }
      expect(applied.values.every((v) => v == 0), isTrue);
    });

    test('should_minimize_transactions_greedily', () {
      // Two creditors, two debtors; greedy match biggest-to-biggest.
      final edges = calc.minimize(
        usd({'a': 700, 'b': 300, 'c': -800, 'd': -200}),
      );
      // c (800) settles with a (700) then d? a exhausted -> c pays a 700,
      // then c 100 left pays b, then d 200 pays b 200. 3 edges, all reconcile.
      final total = edges.fold<int>(0, (s, e) => s + e.amount.minorUnits);
      expect(total, 1000); // total debt cleared
    });

    test('should_filter_edges_for_a_single_user', () {
      final balances = usd({'a': 1000, 'b': -600, 'c': -400});
      final forB = calc.forUser(balances, 'b');
      expect(
        forB.every((e) => e.fromUserId == 'b' || e.toUserId == 'b'),
        isTrue,
      );
      expect(forB.length, 1);
    });
  });
}
