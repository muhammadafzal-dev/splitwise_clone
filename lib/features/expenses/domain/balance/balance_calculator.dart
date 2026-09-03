import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';
import '../entities/expense.dart';
import '../entities/settlement.dart';
import 'balance.dart';
import 'split_calculator.dart';

/// Computes net balances from a set of expenses and settlements.
///
/// Pure: no I/O, no clocks. Assumes a single [currency] across the inputs (the
/// app groups by currency before calling this). Guarantees the net balances
/// always sum to zero — the money in the system is conserved.
class BalanceCalculator {
  const BalanceCalculator({SplitCalculator? splitCalculator})
      : _split = splitCalculator ?? const SplitCalculator();

  final SplitCalculator _split;

  /// `userId -> net Money`. Positive = owed money; negative = owes money.
  ///
  /// A user appears if they paid for, participated in, or settled anything.
  Map<String, Money> netBalances({
    required List<Expense> expenses,
    required List<Settlement> settlements,
    Currency? currency,
  }) {
    final ccy = currency ?? _inferCurrency(expenses, settlements);
    final net = <String, int>{}; // minor units

    void add(String userId, int delta) =>
        net[userId] = (net[userId] ?? 0) + delta;

    for (final expense in expenses) {
      // Payer fronted the whole amount.
      add(expense.payerId, expense.amountMinorUnits);
      // Each participant owes their share.
      final shares = _split.computeShares(expense);
      shares.forEach((userId, owed) => add(userId, -owed));
    }

    for (final s in settlements) {
      // Payer clears part of their debt (balance moves toward zero from below).
      add(s.fromUserId, s.amountMinorUnits);
      // Receiver is owed that much less.
      add(s.toUserId, -s.amountMinorUnits);
    }

    assert(
      net.values.fold<int>(0, (a, b) => a + b) == 0,
      'Net balances must sum to zero, got ${net.values}',
    );

    return {
      for (final entry in net.entries) entry.key: Money(entry.value, ccy),
    };
  }

  /// Net balances as a sorted list of [Balance] (creditors first, then
  /// debtors, settled last), stable by userId within each bucket.
  List<Balance> balances({
    required List<Expense> expenses,
    required List<Settlement> settlements,
    Currency? currency,
  }) {
    final net = netBalances(
      expenses: expenses,
      settlements: settlements,
      currency: currency,
    );
    final list = [
      for (final entry in net.entries)
        Balance(userId: entry.key, amount: entry.value),
    ]..sort((a, b) {
        final byAmount = b.amount.compareTo(a.amount);
        if (byAmount != 0) return byAmount;
        return a.userId.compareTo(b.userId);
      });
    return list;
  }

  Currency _inferCurrency(
    List<Expense> expenses,
    List<Settlement> settlements,
  ) {
    if (expenses.isNotEmpty) return expenses.first.currency;
    if (settlements.isNotEmpty) return settlements.first.currency;
    return Currency.usd;
  }
}
