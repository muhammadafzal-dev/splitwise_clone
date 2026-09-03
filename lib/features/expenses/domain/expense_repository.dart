import 'entities/expense.dart';
import 'entities/settlement.dart';

/// Expenses and settlements. Provides both per-group streams (group detail) and
/// per-user streams across all groups (overall balances / activity feed).
abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchGroupExpenses(String groupId);

  Stream<List<Settlement>> watchGroupSettlements(String groupId);

  /// All expenses in any group [userId] participates in — for overall balances.
  Stream<List<Expense>> watchUserExpenses(String userId);

  /// All settlements in any group [userId] belongs to.
  Stream<List<Settlement>> watchUserSettlements(String userId);

  Future<Expense> addExpense(Expense expense);

  Future<Settlement> addSettlement(Settlement settlement);
}
