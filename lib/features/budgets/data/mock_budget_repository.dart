import '../../../data/mock/mock_store.dart';
import '../domain/budget_repository.dart';
import '../domain/entities/budget.dart';

class MockBudgetRepository implements BudgetRepository {
  MockBudgetRepository(this._store);

  final MockStore _store;

  @override
  Stream<List<Budget>> watchBudgets(String userId) {
    return _store.watch().map((s) {
      final budgets = s.budgets.where((b) => b.userId == userId).toList()
        ..sort((a, b) => a.category.label.compareTo(b.category.label));
      return budgets;
    });
  }

  @override
  Future<void> setBudget(Budget budget) => _store.setBudget(budget);

  @override
  Future<void> removeBudget(String budgetId) => _store.removeBudget(budgetId);
}
