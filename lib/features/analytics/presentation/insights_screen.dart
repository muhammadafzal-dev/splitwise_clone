import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_providers.dart';
import '../../budgets/application/budget_providers.dart';
import '../../expenses/domain/entities/expense_category.dart';
import '../../expenses/presentation/widgets/expense_category_ui.dart';
import '../../groups/application/group_providers.dart';
import '../../groups/domain/personal_group.dart';
import '../application/analytics_providers.dart';
import 'widgets/category_donut.dart';
import 'widgets/monthly_bars.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalSpentProvider);
    final byCategory = ref.watch(spendByCategoryProvider);
    final byMonth = ref.watch(spendByMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            tooltip: 'Budgets',
            onPressed: () => context.push(AppRoutes.budgets),
            icon: const Icon(Icons.savings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPersonalExpense(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Personal expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _TotalCard(total: total),
          const SizedBox(height: 20),
          Text('By category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _CategoryCard(byCategory: byCategory, total: total),
          const SizedBox(height: 20),
          Text(
            'Monthly spending',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: byMonth.when(
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Text('Could not load'),
                data: (data) => MonthlyBars(data: data),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _BudgetSummary(),
        ],
      ),
    );
  }

  Future<void> _addPersonalExpense(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final router = GoRouter.of(context);

    final groups = ref.read(groupsProvider).value ?? const [];
    String? personalId;
    for (final g in groups) {
      if (g.name == PersonalGroup.name &&
          g.memberIds.length == 1 &&
          g.memberIds.first == userId) {
        personalId = g.id;
        break;
      }
    }
    personalId ??=
        (await ref
                .read(groupRepositoryProvider)
                .createGroup(
                  name: PersonalGroup.name,
                  emoji: PersonalGroup.emoji,
                  memberIds: [userId],
                  currencyCode: ref.read(preferredCurrencyProvider).code,
                ))
            .id;

    await router.push(AppRoutes.addExpense(personalId));
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final AsyncValue<Money> total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total spent (your share)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  total.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, _) => const Text('—'),
                    data: (money) => AmountText(
                      money,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.insights, size: 40, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.byCategory, required this.total});

  final AsyncValue<Map<ExpenseCategory, Money>> byCategory;
  final AsyncValue<Money> total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: byCategory.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('Could not load'),
          data: (data) {
            if (data.isEmpty) {
              return const EmptyView(
                icon: Icons.pie_chart_outline,
                title: 'No spending yet',
                message: 'Add expenses to see your breakdown.',
              );
            }
            final slices = [
              for (final entry in data.entries)
                DonutSlice(
                  value: entry.value.minorUnits.toDouble(),
                  color: entry.key.color,
                ),
            ];
            return Column(
              children: [
                Center(
                  child: CategoryDonut(
                    slices: slices,
                    center: total.maybeWhen(
                      data: (m) => Text(
                        m.currency.symbol,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      orElse: () => null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final entry in data.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: entry.key.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(entry.key.icon, size: 18, color: entry.key.color),
                        const SizedBox(width: 8),
                        Expanded(child: Text(entry.key.label)),
                        AmountText(
                          entry.value,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BudgetSummary extends ConsumerWidget {
  const _BudgetSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(budgetProgressProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budgets', style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () => context.push(AppRoutes.budgets),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        progress.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (list) {
            if (list.isEmpty) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Set a monthly budget'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.budgets),
                ),
              );
            }
            final overCount = list.where((p) => p.isOver).length;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overCount == 0
                          ? 'All ${list.length} budgets on track'
                          : '$overCount of ${list.length} over budget',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: overCount == 0
                            ? theme.colorScheme.outline
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final p in list.take(3)) ...[
                      _MiniBudgetRow(progress: p),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniBudgetRow extends StatelessWidget {
  const _MiniBudgetRow({required this.progress});

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progress.isOver
        ? theme.colorScheme.error
        : progress.budget.category.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(progress.budget.category.icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(progress.budget.category.label)),
            AmountText(progress.spent, style: theme.textTheme.labelLarge),
            Text(
              ' / ${progress.budget.limit.currency.symbol}'
              '${progress.budget.limit.asMajor.toStringAsFixed(0)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: color,
          ),
        ),
      ],
    );
  }
}
