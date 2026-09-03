import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../expenses/domain/balance/split_calculator.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../expenses/domain/entities/expense_category.dart';

/// Aggregates a user's *own share* of spending across expenses — pure Dart,
/// no I/O or clock, so it is unit-tested in isolation (like the balance engine).
///
/// "Spending" = the portion of each expense the user is responsible for (their
/// split share), not the full expense amount. All methods work in a single
/// [Currency]; callers filter/​group by currency first.
class SpendingAnalyzer {
  const SpendingAnalyzer({SplitCalculator? splitCalculator})
    : _split = splitCalculator ?? const SplitCalculator();

  final SplitCalculator _split;

  /// The user's share of one expense in minor units (0 if not involved or the
  /// split is malformed).
  int shareOf(Expense expense, String userId) {
    try {
      return _split.computeShares(expense)[userId] ?? 0;
    } on Object {
      return 0;
    }
  }

  /// Total the user spent across [expenses] in [currency].
  Money totalSpent({
    required List<Expense> expenses,
    required String userId,
    required Currency currency,
  }) {
    var total = 0;
    for (final e in expenses) {
      if (e.currency == currency) total += shareOf(e, userId);
    }
    return Money(total, currency);
  }

  /// The user's spend grouped by category (only non-zero categories),
  /// descending by amount.
  Map<ExpenseCategory, Money> byCategory({
    required List<Expense> expenses,
    required String userId,
    required Currency currency,
  }) {
    final totals = <ExpenseCategory, int>{};
    for (final e in expenses) {
      if (e.currency != currency) continue;
      final share = shareOf(e, userId);
      if (share == 0) continue;
      totals[e.category] = (totals[e.category] ?? 0) + share;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {
      for (final entry in entries) entry.key: Money(entry.value, currency),
    };
  }

  /// The user's spend grouped by month (key = first day of that month),
  /// ascending by date.
  Map<DateTime, Money> byMonth({
    required List<Expense> expenses,
    required String userId,
    required Currency currency,
  }) {
    final totals = <DateTime, int>{};
    for (final e in expenses) {
      if (e.currency != currency) continue;
      final share = shareOf(e, userId);
      if (share == 0) continue;
      final month = DateTime(e.createdAt.year, e.createdAt.month);
      totals[month] = (totals[month] ?? 0) + share;
    }
    final keys = totals.keys.toList()..sort();
    return {for (final k in keys) k: Money(totals[k]!, currency)};
  }

  /// The user's spend in [category] during the month containing [month].
  Money spentInCategory({
    required List<Expense> expenses,
    required String userId,
    required ExpenseCategory category,
    required DateTime month,
    required Currency currency,
  }) {
    var total = 0;
    for (final e in expenses) {
      if (e.currency != currency || e.category != category) continue;
      if (e.createdAt.year != month.year || e.createdAt.month != month.month) {
        continue;
      }
      total += shareOf(e, userId);
    }
    return Money(total, currency);
  }
}
