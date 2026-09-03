import 'package:splitwise_clone/features/expenses/domain/entities/expense.dart';
import 'package:splitwise_clone/features/expenses/domain/entities/settlement.dart';
import 'package:splitwise_clone/features/expenses/domain/entities/split_type.dart';

/// Test factories so specs read cleanly. Amounts are minor units (cents).
Expense equalExpense({
  String id = 'e',
  String group = 'g',
  required String payer,
  required int amount,
  required List<String> participants,
  String currency = 'USD',
}) => Expense(
  id: id,
  groupId: group,
  description: 'test',
  payerId: payer,
  amountMinorUnits: amount,
  currencyCode: currency,
  splitType: SplitType.equal,
  participantIds: participants,
  createdAt: DateTime(2026),
);

Expense exactExpense({
  String id = 'e',
  String group = 'g',
  required String payer,
  required int amount,
  required Map<String, int> shares,
  String currency = 'USD',
}) => Expense(
  id: id,
  groupId: group,
  description: 'test',
  payerId: payer,
  amountMinorUnits: amount,
  currencyCode: currency,
  splitType: SplitType.exact,
  participantIds: shares.keys.toList(),
  exactShares: shares,
  createdAt: DateTime(2026),
);

Expense percentExpense({
  String id = 'e',
  String group = 'g',
  required String payer,
  required int amount,
  required Map<String, int> basisPoints,
  String currency = 'USD',
}) => Expense(
  id: id,
  groupId: group,
  description: 'test',
  payerId: payer,
  amountMinorUnits: amount,
  currencyCode: currency,
  splitType: SplitType.percent,
  participantIds: basisPoints.keys.toList(),
  percentShares: basisPoints,
  createdAt: DateTime(2026),
);

Settlement settlement({
  String id = 's',
  String group = 'g',
  required String from,
  required String to,
  required int amount,
  String currency = 'USD',
}) => Settlement(
  id: id,
  groupId: group,
  fromUserId: from,
  toUserId: to,
  amountMinorUnits: amount,
  currencyCode: currency,
  createdAt: DateTime(2026),
);
