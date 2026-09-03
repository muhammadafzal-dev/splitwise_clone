import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/date_formatter.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../auth/application/auth_providers.dart';
import '../../domain/balance/split_calculator.dart';
import '../../domain/entities/expense.dart';
import 'expense_detail_sheet.dart';

const _splitCalculator = SplitCalculator();

/// A single expense row: what it was, who paid, and how it affects the
/// signed-in user (they lent or borrowed).
class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final directory = ref.watch(userDirectoryProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final payerName = directory[expense.payerId]?.name ?? 'Someone';

    final impact = _impactForUser(currentUserId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      onTap: () => showExpenseDetail(context, expense),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
      ),
      title: Text(
        expense.description,
        style: theme.textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$payerName paid ${moneyFormatter.format(expense.amount)} · '
        '${dateFormatter.dayMonth(expense.createdAt)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: impact == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  impact.isPositive
                      ? 'you lent'
                      : impact.isNegative
                      ? 'you borrowed'
                      : 'not involved',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                if (!impact.isZero)
                  AmountText(
                    impact.abs,
                    colored: true,
                    style: theme.textTheme.titleSmall,
                  ),
              ],
            ),
    );
  }

  /// The signed-in user's net effect from this one expense: positive if they
  /// paid more than their share (lent), negative if less (borrowed).
  Money? _impactForUser(String? userId) {
    if (userId == null) return null;
    try {
      final shares = _splitCalculator.computeShares(expense);
      final owed = shares[userId] ?? 0;
      final paid = expense.payerId == userId ? expense.amountMinorUnits : 0;
      return Money(paid - owed, expense.currency);
    } on Object {
      return null;
    }
  }
}
