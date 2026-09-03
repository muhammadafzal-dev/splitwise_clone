import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/money.dart';
import '../../analytics/domain/spending_analyzer.dart';
import '../../auth/application/auth_providers.dart';
import '../../expenses/application/expense_providers.dart';
import '../domain/entities/budget.dart';

const _analyzer = SpendingAnalyzer();

/// The signed-in user's budgets.
final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(budgetRepositoryProvider).watchBudgets(userId);
});

/// A budget paired with how much of it has been spent this month.
@immutable
class BudgetProgress {
  const BudgetProgress({required this.budget, required this.spent});

  final Budget budget;
  final Money spent;

  /// 0.0–∞ (can exceed 1 when over budget).
  double get ratio {
    final limit = budget.monthlyLimitMinorUnits;
    if (limit <= 0) return 0;
    return spent.minorUnits / limit;
  }

  bool get isOver => spent.minorUnits > budget.monthlyLimitMinorUnits;

  Money get remaining =>
      Money(budget.monthlyLimitMinorUnits - spent.minorUnits, budget.currency);
}

/// Budgets with this month's spending progress, computed from the user's
/// expenses. Recomputes reactively as expenses or budgets change.
final budgetProgressProvider = Provider<AsyncValue<List<BudgetProgress>>>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  final budgets = ref.watch(budgetsProvider);
  final expenses = ref.watch(userExpensesProvider);

  if (budgets.hasError) {
    return AsyncError(budgets.error!, budgets.stackTrace!);
  }
  if (expenses.hasError) {
    return AsyncError(expenses.error!, expenses.stackTrace!);
  }
  if (!budgets.hasValue || !expenses.hasValue || userId == null) {
    return const AsyncLoading();
  }

  final now = DateTime.now();
  final month = DateTime(now.year, now.month);
  final result = [
    for (final budget in budgets.requireValue)
      BudgetProgress(
        budget: budget,
        spent: _analyzer.spentInCategory(
          expenses: expenses.requireValue,
          userId: userId,
          category: budget.category,
          month: month,
          currency: budget.currency,
        ),
      ),
  ];
  return AsyncData(result);
});
