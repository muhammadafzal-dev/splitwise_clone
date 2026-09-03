import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/date_formatter.dart';
import '../../../../core/formatting/money_formatter.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/balance/split_calculator.dart';
import '../../domain/entities/expense.dart';

/// Bottom sheet showing an expense's full breakdown: who paid, and exactly what
/// each participant owes (computed by the same [SplitCalculator] the balances
/// use, so the sheet can never disagree with the totals).
Future<void> showExpenseDetail(BuildContext context, Expense expense) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ExpenseDetailSheet(expense: expense),
  );
}

class _ExpenseDetailSheet extends ConsumerWidget {
  const _ExpenseDetailSheet({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final directory = ref.watch(userDirectoryProvider);
    final payerName = directory[expense.payerId]?.name ?? 'Someone';

    Map<String, int> shares;
    try {
      shares = const SplitCalculator().computeShares(expense);
    } on Object {
      shares = const {};
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        '${dateFormatter.medium(expense.createdAt)} · '
                        '${expense.splitType.label}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$payerName paid', style: theme.textTheme.bodyLarge),
                  Text(
                    moneyFormatter.format(expense.amount),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Split breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in shares.entries)
              _ShareRow(
                name: directory[entry.key]?.name ?? entry.key,
                user: directory[entry.key],
                amount: Money(entry.value, expense.currency),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.name,
    required this.user,
    required this.amount,
  });

  final String name;
  final AppUser? user;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    final avatarUser = user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (avatarUser != null) UserAvatar(user: avatarUser, radius: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          AmountText(
            amount,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
