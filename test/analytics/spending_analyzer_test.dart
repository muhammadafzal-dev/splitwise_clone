import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/core/money/currency.dart';
import 'package:splitwise_clone/features/analytics/domain/spending_analyzer.dart';
import 'package:splitwise_clone/features/expenses/domain/entities/expense_category.dart';

import '../support/expense_builders.dart';

void main() {
  const analyzer = SpendingAnalyzer();
  const usd = Currency.usd;

  group('SpendingAnalyzer.shareOf', () {
    test('should_return_only_the_users_split_share_not_the_total', () {
      final e = equalExpense(
        payer: 'a',
        amount: 900,
        participants: ['a', 'b', 'c'],
      );
      expect(analyzer.shareOf(e, 'a'), 300);
    });

    test('should_return_zero_when_user_not_involved', () {
      final e = equalExpense(payer: 'a', amount: 900, participants: ['b', 'c']);
      expect(analyzer.shareOf(e, 'z'), 0);
    });
  });

  group('SpendingAnalyzer.totalSpent', () {
    test('should_sum_only_the_users_shares', () {
      final total = analyzer.totalSpent(
        expenses: [
          equalExpense(payer: 'a', amount: 900, participants: ['a', 'b', 'c']),
          equalExpense(payer: 'b', amount: 1000, participants: ['a', 'b']),
        ],
        userId: 'a',
        currency: usd,
      );
      // 300 + 500
      expect(total.minorUnits, 800);
    });

    test('should_ignore_expenses_in_other_currencies', () {
      final total = analyzer.totalSpent(
        expenses: [
          equalExpense(payer: 'a', amount: 900, participants: ['a']),
          equalExpense(
            payer: 'a',
            amount: 500,
            participants: ['a'],
            currency: 'EUR',
          ),
        ],
        userId: 'a',
        currency: usd,
      );
      expect(total.minorUnits, 900);
    });
  });

  group('SpendingAnalyzer.byCategory', () {
    test('should_bucket_shares_by_category_descending', () {
      final byCat = analyzer.byCategory(
        expenses: [
          equalExpense(
            payer: 'a',
            amount: 1000,
            participants: ['a'],
            category: ExpenseCategory.food,
          ),
          equalExpense(
            id: 'e2',
            payer: 'a',
            amount: 400,
            participants: ['a'],
            category: ExpenseCategory.transport,
          ),
          equalExpense(
            id: 'e3',
            payer: 'a',
            amount: 200,
            participants: ['a'],
            category: ExpenseCategory.food,
          ),
        ],
        userId: 'a',
        currency: usd,
      );
      expect(byCat[ExpenseCategory.food]!.minorUnits, 1200);
      expect(byCat[ExpenseCategory.transport]!.minorUnits, 400);
      // Descending: food first.
      expect(byCat.keys.first, ExpenseCategory.food);
    });
  });

  group('SpendingAnalyzer.byMonth', () {
    test('should_bucket_shares_by_month_ascending', () {
      final byMonth = analyzer.byMonth(
        expenses: [
          equalExpense(
            payer: 'a',
            amount: 500,
            participants: ['a'],
            createdAt: DateTime(2026, 7, 10),
          ),
          equalExpense(
            id: 'e2',
            payer: 'a',
            amount: 300,
            participants: ['a'],
            createdAt: DateTime(2026, 8, 2),
          ),
          equalExpense(
            id: 'e3',
            payer: 'a',
            amount: 100,
            participants: ['a'],
            createdAt: DateTime(2026, 8, 20),
          ),
        ],
        userId: 'a',
        currency: usd,
      );
      final keys = byMonth.keys.toList();
      expect(keys.first, DateTime(2026, 7));
      expect(byMonth[DateTime(2026, 8)]!.minorUnits, 400);
    });
  });

  group('SpendingAnalyzer.spentInCategory', () {
    test('should_sum_only_matching_category_and_month', () {
      final spent = analyzer.spentInCategory(
        expenses: [
          equalExpense(
            payer: 'a',
            amount: 500,
            participants: ['a'],
            category: ExpenseCategory.food,
            createdAt: DateTime(2026, 8, 5),
          ),
          equalExpense(
            id: 'e2',
            payer: 'a',
            amount: 900,
            participants: ['a'],
            category: ExpenseCategory.food,
            createdAt: DateTime(2026, 7, 5), // different month
          ),
          equalExpense(
            id: 'e3',
            payer: 'a',
            amount: 100,
            participants: ['a'],
            category: ExpenseCategory.transport,
            createdAt: DateTime(2026, 8, 6), // different category
          ),
        ],
        userId: 'a',
        category: ExpenseCategory.food,
        month: DateTime(2026, 8),
        currency: usd,
      );
      expect(spent.minorUnits, 500);
    });
  });
}
