import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_store.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/budgets/data/mock_budget_repository.dart';
import '../features/budgets/domain/budget_repository.dart';
import '../features/expenses/data/mock_expense_repository.dart';
import '../features/expenses/domain/expense_repository.dart';
import '../features/friends/data/mock_friend_repository.dart';
import '../features/friends/domain/friend_repository.dart';
import '../features/groups/data/mock_group_repository.dart';
import '../features/groups/domain/group_repository.dart';
import '../features/salary/data/mock_salary_repository.dart';
import '../features/salary/domain/salary_repository.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// THE SWAP POINT.
///
/// Every repository is exposed here as its domain interface, built from the
/// in-memory [MockStore]. To move to Firebase later, write `Firebase*Repository`
/// implementations of the same interfaces and override these four providers in
/// `ProviderScope(overrides: [...])` — no UI or domain code changes.
/// ─────────────────────────────────────────────────────────────────────────

final mockStoreProvider = Provider<MockStore>((ref) {
  final store = MockStore()..seed();
  ref.onDispose(store.dispose);
  return store;
});

/// True when a real cloud backend (Firebase) is active — it has genuine offline
/// queueing + sync. Overridden to true in `firebase_backend.dart`; false (mock)
/// means everything is already local, so there is nothing to "sync".
final cloudBackendEnabledProvider = Provider<bool>((ref) => false);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(ref.watch(mockStoreProvider)),
);

final friendRepositoryProvider = Provider<FriendRepository>(
  (ref) => MockFriendRepository(ref.watch(mockStoreProvider)),
);

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => MockGroupRepository(ref.watch(mockStoreProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => MockExpenseRepository(ref.watch(mockStoreProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => MockBudgetRepository(ref.watch(mockStoreProvider)),
);

final salaryRepositoryProvider = Provider<SalaryRepository>(
  (ref) => MockSalaryRepository(ref.watch(mockStoreProvider)),
);
