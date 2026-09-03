import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_providers.dart';
import '../../expenses/application/expense_providers.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../expenses/presentation/widgets/expenses_section.dart';
import '../application/group_providers.dart';
import '../domain/entities/group.dart';
import 'widgets/balances_section.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupProvider(groupId));
    final expenses = ref.watch(groupExpensesProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: group.when(
          data: (g) => Text(g == null ? 'Group' : '${g.emoji}  ${g.name}'),
          loading: () => const Text('Group'),
          error: (_, _) => const Text('Group'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense(groupId)),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: AsyncValueView(
        value: expenses,
        onRetry: () => ref.invalidate(groupExpensesProvider(groupId)),
        data: (list) => RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(groupExpensesProvider(groupId))
              ..invalidate(groupSettlementsProvider(groupId));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (group.value != null) ...[
                _GroupHeader(group: group.value!, expenses: list),
                const SizedBox(height: 24),
              ],
              _SectionHeader(
                title: 'Balances',
                // A payment needs at least two members.
                trailing: (group.value?.memberIds.length ?? 0) >= 2
                    ? TextButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.settleUp(groupId)),
                        icon: const Icon(Icons.handshake_outlined, size: 18),
                        label: const Text('Settle up'),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              BalancesSection(groupId: groupId),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Expenses'),
              const SizedBox(height: 8),
              ExpensesSection(expenses: list),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends ConsumerWidget {
  const _GroupHeader({required this.group, required this.expenses});

  final Group group;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = Currency.fromCode(group.currencyCode);
    final directory = ref.watch(userDirectoryProvider);
    final members = [
      for (final id in group.memberIds)
        if (directory[id] != null) directory[id]!,
    ];
    var total = Money.zero(currency);
    for (final e in expenses) {
      if (e.currency == currency) total = total + e.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: theme.textTheme.titleLarge),
                      Text(
                        '${members.length} members',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (members.isNotEmpty) AvatarStack(users: members),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total spent', style: theme.textTheme.bodyMedium),
                Text(
                  moneyFormatter.format(total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        ?trailing,
      ],
    );
  }
}
