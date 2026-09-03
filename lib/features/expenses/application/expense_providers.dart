import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/balance/balance.dart';
import '../domain/balance/balance_calculator.dart';
import '../domain/balance/settlement_calculator.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/settlement.dart';

const _balanceCalculator = BalanceCalculator();
const _settlementCalculator = SettlementCalculator();

// --- Raw streams ------------------------------------------------------------

final groupExpensesProvider = StreamProvider.family<List<Expense>, String>((
  ref,
  groupId,
) {
  return ref.watch(expenseRepositoryProvider).watchGroupExpenses(groupId);
});

final groupSettlementsProvider =
    StreamProvider.family<List<Settlement>, String>((ref, groupId) {
      return ref
          .watch(expenseRepositoryProvider)
          .watchGroupSettlements(groupId);
    });

final userExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(expenseRepositoryProvider).watchUserExpenses(userId);
});

final userSettlementsProvider = StreamProvider<List<Settlement>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(expenseRepositoryProvider).watchUserSettlements(userId);
});

// --- Derived balances -------------------------------------------------------

/// Net balances for one group as a sorted list (creditors first).
final groupBalancesProvider =
    Provider.family<AsyncValue<List<Balance>>, String>((ref, groupId) {
      final expenses = ref.watch(groupExpensesProvider(groupId));
      final settlements = ref.watch(groupSettlementsProvider(groupId));
      return _combine(expenses, settlements, (ex, st) {
        return _balanceCalculator.balances(expenses: ex, settlements: st);
      });
    });

/// Minimal "who pays whom" transactions for one group.
final groupSettlementPlanProvider =
    Provider.family<AsyncValue<List<DebtEdge>>, String>((ref, groupId) {
      final expenses = ref.watch(groupExpensesProvider(groupId));
      final settlements = ref.watch(groupSettlementsProvider(groupId));
      return _combine(expenses, settlements, (ex, st) {
        final net = _balanceCalculator.netBalances(
          expenses: ex,
          settlements: st,
        );
        return _settlementCalculator.minimize(net);
      });
    });

/// The signed-in user's overall net position across all groups, **grouped by
/// currency**. Balances in different currencies can't be summed, so each
/// currency is computed independently. Usually there's just one entry.
final overallNetProvider = Provider<AsyncValue<Map<Currency, Money>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final expenses = ref.watch(userExpensesProvider);
  final settlements = ref.watch(userSettlementsProvider);
  return _combine(expenses, settlements, (ex, st) {
    if (userId == null) return const {};

    final currencies = <Currency>{
      ...ex.map((e) => e.currency),
      ...st.map((s) => s.currency),
    };

    final result = <Currency, Money>{};
    for (final currency in currencies) {
      final currencyExpenses = ex.where((e) => e.currency == currency).toList();
      final currencySettlements = st
          .where((s) => s.currency == currency)
          .toList();
      final net = _balanceCalculator.netBalances(
        expenses: currencyExpenses,
        settlements: currencySettlements,
        currency: currency,
      );
      final mine = net[userId];
      if (mine != null && !mine.isZero) result[currency] = mine;
    }
    return result;
  });
});

/// Combines two [AsyncValue]s into one, applying [build] once both have data.
AsyncValue<R> _combine<A, B, R>(
  AsyncValue<A> a,
  AsyncValue<B> b,
  R Function(A a, B b) build,
) {
  if (a.hasError) return AsyncError(a.error!, a.stackTrace!);
  if (b.hasError) return AsyncError(b.error!, b.stackTrace!);
  if (!a.hasValue || !b.hasValue) return const AsyncLoading();
  return AsyncData(build(a.requireValue, b.requireValue));
}
