import '../../../data/mock/mock_store.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/settlement.dart';
import '../domain/expense_repository.dart';

class MockExpenseRepository implements ExpenseRepository {
  MockExpenseRepository(this._store);

  final MockStore _store;

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return _store.watch().map(
      (s) => _sortedExpenses(s.expenses.where((e) => e.groupId == groupId)),
    );
  }

  @override
  Stream<List<Settlement>> watchGroupSettlements(String groupId) {
    return _store.watch().map(
      (s) =>
          _sortedSettlements(s.settlements.where((x) => x.groupId == groupId)),
    );
  }

  @override
  Stream<List<Expense>> watchUserExpenses(String userId) {
    return _store.watch().map((s) {
      final groupIds = _groupIdsFor(s, userId);
      return _sortedExpenses(
        s.expenses.where((e) => groupIds.contains(e.groupId)),
      );
    });
  }

  @override
  Stream<List<Settlement>> watchUserSettlements(String userId) {
    return _store.watch().map((s) {
      final groupIds = _groupIdsFor(s, userId);
      return _sortedSettlements(
        s.settlements.where((x) => groupIds.contains(x.groupId)),
      );
    });
  }

  @override
  Future<Expense> addExpense(Expense expense) => _store.addExpense(expense);

  @override
  Future<Settlement> addSettlement(Settlement settlement) =>
      _store.addSettlement(settlement);

  Set<String> _groupIdsFor(MockSnapshot s, String userId) => s.groups
      .where((g) => g.memberIds.contains(userId))
      .map((g) => g.id)
      .toSet();

  List<Expense> _sortedExpenses(Iterable<Expense> expenses) =>
      expenses.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Settlement> _sortedSettlements(Iterable<Settlement> settlements) =>
      settlements.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
