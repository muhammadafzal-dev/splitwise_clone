import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../expenses/application/expense_providers.dart';
import '../../expenses/presentation/widgets/expense_tile.dart';
import '../application/group_providers.dart';
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
              _SectionHeader(
                title: 'Balances',
                trailing: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.settleUp(groupId)),
                  icon: const Icon(Icons.handshake_outlined, size: 18),
                  label: const Text('Settle up'),
                ),
              ),
              const SizedBox(height: 8),
              BalancesSection(groupId: groupId),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Expenses'),
              const SizedBox(height: 8),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No expenses yet',
                    message: 'Add the first expense for this group.',
                  ),
                )
              else
                for (final expense in list) ExpenseTile(expense: expense),
            ],
          ),
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
