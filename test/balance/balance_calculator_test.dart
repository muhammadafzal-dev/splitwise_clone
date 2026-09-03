import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/core/money/currency.dart';
import 'package:splitwise_clone/features/expenses/domain/balance/balance_calculator.dart';

import '../support/expense_builders.dart';

void main() {
  const calc = BalanceCalculator();

  group('BalanceCalculator', () {
    test('should_credit_payer_and_debit_participants', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(payer: 'a', amount: 900, participants: ['a', 'b', 'c']),
        ],
        settlements: const [],
      );
      // a paid 900, owes own 300 -> net +600; b and c each owe 300.
      expect(balances['a']!.minorUnits, 600);
      expect(balances['b']!.minorUnits, -300);
      expect(balances['c']!.minorUnits, -300);
    });

    test('should_conserve_money_sum_to_zero', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(payer: 'a', amount: 1000, participants: ['a', 'b', 'c']),
          equalExpense(payer: 'b', amount: 550, participants: ['a', 'b']),
        ],
        settlements: const [],
      );
      final total =
          balances.values.fold<int>(0, (s, m) => s + m.minorUnits);
      expect(total, 0);
    });

    test('should_handle_payer_not_being_a_participant', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(payer: 'a', amount: 600, participants: ['b', 'c']),
        ],
        settlements: const [],
      );
      expect(balances['a']!.minorUnits, 600);
      expect(balances['b']!.minorUnits, -300);
      expect(balances['c']!.minorUnits, -300);
    });

    test('should_reduce_debt_when_settlement_recorded', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(payer: 'a', amount: 1000, participants: ['a', 'b']),
        ],
        settlements: [
          // b owes 500; pays a 500 -> both settled.
          settlement(from: 'b', to: 'a', amount: 500),
        ],
      );
      expect(balances['a']!.minorUnits, 0);
      expect(balances['b']!.minorUnits, 0);
    });

    test('should_apply_partial_settlement', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(payer: 'a', amount: 1000, participants: ['a', 'b']),
        ],
        settlements: [
          settlement(from: 'b', to: 'a', amount: 200),
        ],
      );
      expect(balances['a']!.minorUnits, 300);
      expect(balances['b']!.minorUnits, -300);
    });

    test('should_return_empty_for_no_activity', () {
      final balances = calc.netBalances(expenses: const [], settlements: const []);
      expect(balances, isEmpty);
    });

    test('should_carry_currency_through', () {
      final balances = calc.netBalances(
        expenses: [
          equalExpense(
            payer: 'a',
            amount: 1000,
            participants: ['a', 'b'],
            currency: 'EUR',
          ),
        ],
        settlements: const [],
      );
      expect(balances['a']!.currency, Currency.eur);
    });

    test('should_sort_balances_creditors_first', () {
      final list = calc.balances(
        expenses: [
          equalExpense(payer: 'a', amount: 900, participants: ['a', 'b', 'c']),
        ],
        settlements: const [],
      );
      expect(list.first.userId, 'a');
      expect(list.first.isOwed, isTrue);
      expect(list.last.owes, isTrue);
    });
  });
}
