import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/settlement.dart';
import '../domain/expense_repository.dart';

/// Firebase-backed [ExpenseRepository].
///
/// Expenses and settlements live in flat top-level collections, each carrying a
/// `groupId` (for the group view) and a denormalised `involvedIds` array (for
/// the per-user overall view). Both queries are single array/field lookups, so
/// no fan-out over groups is needed.
class FirebaseExpenseRepository implements ExpenseRepository {
  FirebaseExpenseRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  CollectionReference<Map<String, dynamic>> get _settlements =>
      _firestore.collection('settlements');

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return _expenses
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreMappers.expenseFromDoc).toList());
  }

  @override
  Stream<List<Settlement>> watchGroupSettlements(String groupId) {
    return _settlements
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(FirestoreMappers.settlementFromDoc).toList(),
        );
  }

  @override
  Stream<List<Expense>> watchUserExpenses(String userId) {
    return _expenses
        .where('involvedIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreMappers.expenseFromDoc).toList());
  }

  @override
  Stream<List<Settlement>> watchUserSettlements(String userId) {
    return _settlements
        .where('involvedIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(FirestoreMappers.settlementFromDoc).toList(),
        );
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    final ref = _expenses.doc(expense.id.isEmpty ? null : expense.id);
    final stored = expense.copyWith(id: ref.id);
    await ref.set(FirestoreMappers.expenseToMap(stored));
    return stored;
  }

  @override
  Future<Settlement> addSettlement(Settlement settlement) async {
    final ref = _settlements.doc(settlement.id.isEmpty ? null : settlement.id);
    final stored = settlement.copyWith(id: ref.id);
    await ref.set(FirestoreMappers.settlementToMap(stored));
    return stored;
  }
}
