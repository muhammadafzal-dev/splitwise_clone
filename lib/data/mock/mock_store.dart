import 'dart:async';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/entities/settlement.dart';
import '../../features/groups/domain/entities/group.dart';
import 'seed_data.dart';

/// Immutable snapshot of everything in the mock backend at one instant.
class MockSnapshot {
  const MockSnapshot({
    required this.currentUserId,
    required this.users,
    required this.groups,
    required this.expenses,
    required this.settlements,
    required this.friendships,
  });

  final String? currentUserId;
  final List<AppUser> users;
  final List<Group> groups;
  final List<Expense> expenses;
  final List<Settlement> settlements;

  /// userId -> set of friend userIds (symmetric).
  final Map<String, Set<String>> friendships;
}

/// A single in-memory source of truth that stands in for Firestore.
///
/// It exposes one reactive [watch] stream that replays the current snapshot to
/// each new listener and then pushes a fresh snapshot on every mutation — the
/// same shape a Firestore snapshot listener has, so the mock repositories read
/// almost identically to the future Firestore ones.
class MockStore {
  MockStore({this.latency = const Duration(milliseconds: 350)});

  /// Simulated network latency so the UI's loading states are actually visible.
  final Duration latency;

  String? _currentUserId;
  final List<AppUser> _users = [];
  final List<Group> _groups = [];
  final List<Expense> _expenses = [];
  final List<Settlement> _settlements = [];
  final Map<String, Set<String>> _friendships = {};

  final StreamController<MockSnapshot> _controller =
      StreamController<MockSnapshot>.broadcast();
  bool _seeded = false;

  /// Load demo data. Idempotent.
  void seed() {
    if (_seeded) return;
    _seeded = true;
    _users.addAll(seedUsers);
    _groups.addAll(seedGroups);
    _expenses.addAll(seedExpenses);
    _settlements.addAll(seedSettlements);
    _friendships.addAll(buildSeedFriendships());
    _currentUserId = seedUsers.first.id;
  }

  MockSnapshot get snapshot => MockSnapshot(
    currentUserId: _currentUserId,
    users: List.unmodifiable(_users),
    groups: List.unmodifiable(_groups),
    expenses: List.unmodifiable(_expenses),
    settlements: List.unmodifiable(_settlements),
    friendships: {
      for (final e in _friendships.entries) e.key: Set.unmodifiable(e.value),
    },
  );

  /// Replays the current snapshot (after [latency]) then streams every change.
  ///
  /// The live subscription is attached *before* the initial snapshot is emitted,
  /// so a mutation happening during the latency window can't be missed.
  Stream<MockSnapshot> watch() {
    final controller = StreamController<MockSnapshot>();
    StreamSubscription<MockSnapshot>? sub;

    controller.onListen = () async {
      sub = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      await Future<void>.delayed(latency);
      if (!controller.isClosed) controller.add(snapshot);
    };
    controller.onCancel = () async {
      await sub?.cancel();
    };
    return controller.stream;
  }

  void _emit() => _controller.add(snapshot);

  // --- Mutations -----------------------------------------------------------

  Future<void> signInAs(String userId) async {
    await Future<void>.delayed(latency);
    _currentUserId = userId;
    _emit();
  }

  Future<void> signOut() async {
    await Future<void>.delayed(latency);
    _currentUserId = null;
    _emit();
  }

  Future<void> addFriend(String userId, String friendId) async {
    await Future<void>.delayed(latency);
    _friendships.putIfAbsent(userId, () => {}).add(friendId);
    _friendships.putIfAbsent(friendId, () => {}).add(userId);
    _emit();
  }

  Future<Group> addGroup(Group group) async {
    await Future<void>.delayed(latency);
    _groups.add(group);
    _emit();
    return group;
  }

  Future<void> addMember(String groupId, String userId) async {
    await Future<void>.delayed(latency);
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    final group = _groups[index];
    if (group.memberIds.contains(userId)) return;
    _groups[index] = group.copyWith(memberIds: [...group.memberIds, userId]);
    _emit();
  }

  Future<Expense> addExpense(Expense expense) async {
    await Future<void>.delayed(latency);
    _expenses.add(expense);
    _emit();
    return expense;
  }

  Future<Settlement> addSettlement(Settlement settlement) async {
    await Future<void>.delayed(latency);
    _settlements.add(settlement);
    _emit();
    return settlement;
  }

  Future<void> dispose() => _controller.close();
}
