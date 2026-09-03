import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../domain/budget_repository.dart';
import '../domain/entities/budget.dart';

/// Firebase-backed [BudgetRepository]. Budgets live in a top-level `budgets`
/// collection keyed by document id, scoped per user.
class FirebaseBudgetRepository implements BudgetRepository {
  FirebaseBudgetRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _budgets =>
      _firestore.collection('budgets');

  @override
  Stream<List<Budget>> watchBudgets(String userId) {
    return _budgets.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final budgets = snap.docs.map(FirestoreMappers.budgetFromDoc).toList()
        ..sort((a, b) => a.category.label.compareTo(b.category.label));
      return budgets;
    });
  }

  @override
  Future<void> setBudget(Budget budget) {
    return _budgets.doc(budget.id).set(FirestoreMappers.budgetToMap(budget));
  }

  @override
  Future<void> removeBudget(String budgetId) => _budgets.doc(budgetId).delete();
}
