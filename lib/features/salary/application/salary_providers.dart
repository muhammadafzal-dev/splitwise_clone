import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../analytics/domain/spending_analyzer.dart';
import '../../auth/application/auth_providers.dart';
import '../../expenses/application/expense_providers.dart';
import '../domain/entities/cycle_disposition.dart';
import '../domain/entities/salary_cycle.dart';

const _analyzer = SpendingAnalyzer();

/// All of the signed-in user's salary cycles (newest first).
final salaryCyclesProvider = StreamProvider<List<SalaryCycle>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(salaryRepositoryProvider).watchCycles(userId);
});

/// The currently active salary cycle, or null.
final activeCycleProvider = StreamProvider<SalaryCycle?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(salaryRepositoryProvider).watchActiveCycle(userId);
});

/// The user's spend since the active cycle started (their share of every
/// expense in the window). Zero when there is no active cycle.
final activeCycleSpentProvider = Provider<AsyncValue<Money>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final cycle = ref.watch(activeCycleProvider);
  final expenses = ref.watch(userExpensesProvider);

  if (cycle.hasError) return AsyncError(cycle.error!, cycle.stackTrace!);
  if (expenses.hasError) {
    return AsyncError(expenses.error!, expenses.stackTrace!);
  }
  if (!cycle.hasValue || !expenses.hasValue || userId == null) {
    return const AsyncLoading();
  }

  final active = cycle.requireValue;
  if (active == null) return const AsyncData(Money.zero(_fallbackCurrency));

  return AsyncData(
    _analyzer.totalSpentBetween(
      expenses: expenses.requireValue,
      userId: userId,
      currency: active.currency,
      from: active.startedAt,
    ),
  );
});

/// Total moved to savings across all closed cycles (disposition == savings).
final savingsTotalProvider = Provider<AsyncValue<Money>>((ref) {
  final cycles = ref.watch(salaryCyclesProvider);
  return cycles.whenData((list) {
    var total = 0;
    Money? sample;
    for (final c in list) {
      if (c.disposition == CycleDisposition.savings) {
        total += c.savedMinorUnits;
        sample = c.saved;
      }
    }
    return Money(total, sample?.currency ?? _fallbackCurrency);
  });
});

// Fallback currency for empty states.
const _fallbackCurrency = Currency.usd;
