import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/application/expense_providers.dart';
import '../domain/activity_item.dart';

/// The signed-in user's activity feed across all groups: expenses and
/// settlements, newest first.
final activityFeedProvider = Provider<AsyncValue<List<ActivityItem>>>((ref) {
  final expenses = ref.watch(userExpensesProvider);
  final settlements = ref.watch(userSettlementsProvider);

  if (expenses.hasError) {
    return AsyncError(expenses.error!, expenses.stackTrace!);
  }
  if (settlements.hasError) {
    return AsyncError(settlements.error!, settlements.stackTrace!);
  }
  if (!expenses.hasValue || !settlements.hasValue) {
    return const AsyncLoading();
  }

  final items = <ActivityItem>[
    ...expenses.requireValue.map(ExpenseActivity.new),
    ...settlements.requireValue.map(SettlementActivity.new),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return AsyncData(items);
});
