import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/data/mock/mock_store.dart';
import 'package:splitwise_clone/features/expenses/data/mock_expense_repository.dart';
import 'package:splitwise_clone/features/groups/data/mock_group_repository.dart';

import '../support/expense_builders.dart';

/// Zero-latency store so the streams resolve immediately in tests.
MockStore seededStore() => MockStore(latency: Duration.zero)..seed();

void main() {
  group('MockGroupRepository', () {
    test('should_return_only_groups_the_user_is_a_member_of', () async {
      final repo = MockGroupRepository(seededStore());

      final groups = await repo.watchGroups('u_dave').first;

      // Dave is only in the Kyoto trip.
      expect(groups.map((g) => g.id), ['g_kyoto']);
    });

    test('should_emit_again_after_a_group_is_created', () async {
      final store = seededStore();
      final repo = MockGroupRepository(store);
      final emissions = <int>[];
      final sub = repo
          .watchGroups('u_alice')
          .listen((g) => emissions.add(g.length));

      await Future<void>.delayed(Duration.zero);
      await repo.createGroup(
        name: 'Ski',
        emoji: '⛷️',
        memberIds: const ['u_alice'],
        currencyCode: 'USD',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emissions.last, greaterThan(emissions.first));
      await sub.cancel();
    });
  });

  group('MockExpenseRepository', () {
    test('should_return_group_expenses_newest_first', () async {
      final repo = MockExpenseRepository(seededStore());

      final expenses = await repo.watchGroupExpenses('g_apartment').first;

      expect(expenses, isNotEmpty);
      for (var i = 1; i < expenses.length; i++) {
        expect(
          expenses[i - 1].createdAt.isAfter(expenses[i].createdAt) ||
              expenses[i - 1].createdAt == expenses[i].createdAt,
          isTrue,
        );
      }
    });

    test('should_persist_and_re_emit_a_new_expense', () async {
      final store = seededStore();
      final repo = MockExpenseRepository(store);

      await repo.addExpense(
        equalExpense(
          id: 'x_new',
          group: 'g_apartment',
          payer: 'u_alice',
          amount: 3000,
          participants: const ['u_alice', 'u_bob'],
        ),
      );
      final expenses = await repo.watchGroupExpenses('g_apartment').first;

      expect(expenses.any((e) => e.id == 'x_new'), isTrue);
    });

    test('should_scope_user_expenses_to_the_users_groups', () async {
      final repo = MockExpenseRepository(seededStore());

      final daveExpenses = await repo.watchUserExpenses('u_dave').first;

      // Dave only sees Kyoto expenses, never Apartment ones.
      expect(daveExpenses.every((e) => e.groupId == 'g_kyoto'), isTrue);
    });
  });
}
