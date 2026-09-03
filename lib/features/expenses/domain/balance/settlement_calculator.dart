import '../../../../core/money/money.dart';
import 'balance.dart';

/// Reduces a set of net balances to a minimal list of "who pays whom"
/// transactions using a greedy min-cash-flow match: repeatedly settle the
/// biggest debtor against the biggest creditor.
///
/// This does not always find the theoretical minimum number of transactions
/// (that problem is NP-hard), but the greedy result is what Splitwise-style
/// apps use and is optimal for the common cases. Guarantees: after applying the
/// returned edges, everyone nets to zero.
class SettlementCalculator {
  const SettlementCalculator();

  /// [netBalances] maps `userId -> net Money` (positive = owed, negative =
  /// owes). Returns the payments the debtors should make to the creditors.
  List<DebtEdge> minimize(Map<String, Money> netBalances) {
    if (netBalances.isEmpty) return const [];
    final currency = netBalances.values.first.currency;

    // Work in signed minor units. Skip anyone already settled.
    final creditors = <_Node>[]; // positive
    final debtors = <_Node>[]; // negative
    for (final entry in netBalances.entries) {
      final amount = entry.value.minorUnits;
      if (amount > 0) {
        creditors.add(_Node(entry.key, amount));
      } else if (amount < 0) {
        debtors.add(_Node(entry.key, -amount)); // store as positive owed
      }
    }
    if (creditors.isEmpty || debtors.isEmpty) return const [];

    // Largest first for a stable, tight matching. Tie-break by id.
    int byAmountThenId(_Node a, _Node b) {
      final cmp = b.amount.compareTo(a.amount);
      return cmp != 0 ? cmp : a.userId.compareTo(b.userId);
    }

    creditors.sort(byAmountThenId);
    debtors.sort(byAmountThenId);

    final edges = <DebtEdge>[];
    var ci = 0;
    var di = 0;
    while (ci < creditors.length && di < debtors.length) {
      final creditor = creditors[ci];
      final debtor = debtors[di];
      final pay = creditor.amount < debtor.amount
          ? creditor.amount
          : debtor.amount;

      edges.add(DebtEdge(
        fromUserId: debtor.userId,
        toUserId: creditor.userId,
        amount: Money(pay, currency),
      ));

      creditor.amount -= pay;
      debtor.amount -= pay;
      if (creditor.amount == 0) ci++;
      if (debtor.amount == 0) di++;
    }

    return edges;
  }

  /// Convenience: the subset of [minimize] involving [userId], from their
  /// point of view (what they owe and what they're owed).
  List<DebtEdge> forUser(Map<String, Money> netBalances, String userId) {
    return minimize(netBalances)
        .where((e) => e.fromUserId == userId || e.toUserId == userId)
        .toList();
  }
}

class _Node {
  _Node(this.userId, this.amount);

  final String userId;
  int amount;
}
