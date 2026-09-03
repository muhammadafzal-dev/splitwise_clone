import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../auth/application/auth_providers.dart';
import '../../expenses/application/expense_providers.dart';
import '../../expenses/domain/entities/expense_category.dart';
import '../domain/spending_analyzer.dart';

const _analyzer = SpendingAnalyzer();

/// The currency most of the user's expenses are in (defaults to USD). Analytics
/// are shown for this currency.
final primaryCurrencyProvider = Provider<Currency>((ref) {
  final expenses = ref.watch(userExpensesProvider).value ?? const [];
  if (expenses.isEmpty) return Currency.usd;
  final counts = <Currency, int>{};
  for (final e in expenses) {
    counts[e.currency] = (counts[e.currency] ?? 0) + 1;
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
});

/// Total amount the signed-in user has spent (their share), in the primary
/// currency.
final totalSpentProvider = Provider<AsyncValue<Money>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final currency = ref.watch(primaryCurrencyProvider);
  return ref.watch(userExpensesProvider).whenData((expenses) {
    if (userId == null) return Money.zero(currency);
    return _analyzer.totalSpent(
      expenses: expenses,
      userId: userId,
      currency: currency,
    );
  });
});

/// The user's spend grouped by category (descending).
final spendByCategoryProvider =
    Provider<AsyncValue<Map<ExpenseCategory, Money>>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      final currency = ref.watch(primaryCurrencyProvider);
      return ref.watch(userExpensesProvider).whenData((expenses) {
        if (userId == null) return const {};
        return _analyzer.byCategory(
          expenses: expenses,
          userId: userId,
          currency: currency,
        );
      });
    });

/// The user's spend grouped by month (ascending).
final spendByMonthProvider = Provider<AsyncValue<Map<DateTime, Money>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final currency = ref.watch(primaryCurrencyProvider);
  return ref.watch(userExpensesProvider).whenData((expenses) {
    if (userId == null) return const {};
    return _analyzer.byMonth(
      expenses: expenses,
      userId: userId,
      currency: currency,
    );
  });
});
