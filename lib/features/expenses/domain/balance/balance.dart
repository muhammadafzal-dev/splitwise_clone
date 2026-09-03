import 'package:meta/meta.dart';

import '../../../../core/money/money.dart';

/// A user's net position in a set of expenses.
///
/// Positive [amount] = the user is owed money (creditor); negative = the user
/// owes money (debtor).
@immutable
class Balance {
  const Balance({required this.userId, required this.amount});

  final String userId;
  final Money amount;

  bool get isSettled => amount.isZero;
  bool get isOwed => amount.isPositive;
  bool get owes => amount.isNegative;

  @override
  bool operator ==(Object other) =>
      other is Balance && other.userId == userId && other.amount == amount;

  @override
  int get hashCode => Object.hash(userId, amount);

  @override
  String toString() => 'Balance($userId: $amount)';
}

/// A directed debt: [fromUserId] owes [toUserId] the given [amount] (always
/// positive).
@immutable
class DebtEdge {
  const DebtEdge({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  final String fromUserId;
  final String toUserId;
  final Money amount;

  @override
  bool operator ==(Object other) =>
      other is DebtEdge &&
      other.fromUserId == fromUserId &&
      other.toUserId == toUserId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(fromUserId, toUserId, amount);

  @override
  String toString() => 'DebtEdge($fromUserId -> $toUserId: $amount)';
}
