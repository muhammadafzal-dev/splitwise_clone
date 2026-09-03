import 'entities/budget.dart';

/// Per-user monthly budgets by category.
abstract interface class BudgetRepository {
  /// The signed-in user's budgets, reactive.
  Stream<List<Budget>> watchBudgets(String userId);

  /// Create or replace the budget for a category (upsert).
  Future<void> setBudget(Budget budget);

  /// Remove a budget.
  Future<void> removeBudget(String budgetId);
}
