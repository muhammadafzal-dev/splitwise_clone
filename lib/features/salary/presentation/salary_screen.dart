import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_providers.dart';
import '../application/salary_providers.dart';
import '../domain/entities/cycle_disposition.dart';
import '../domain/entities/salary_cycle.dart';

class SalaryScreen extends ConsumerWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCycleProvider);
    final spent = ref.watch(activeCycleSpentProvider);
    final savings = ref.watch(savingsTotalProvider);
    final cycles = ref.watch(salaryCyclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Salary & savings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSalary(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add salary'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _ActiveCycleCard(active: active, spent: spent),
          const SizedBox(height: 16),
          _SavingsCard(savings: savings),
          const SizedBox(height: 24),
          Text('History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AsyncValueView(
            value: cycles,
            data: (list) {
              final closed = list.where((c) => !c.isActive).toList();
              if (closed.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No past cycles yet.'),
                );
              }
              return Column(
                children: [for (final c in closed) _ClosedCycleTile(cycle: c)],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addSalary(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final active = ref.read(activeCycleProvider).value;
    final Currency defaultCurrency =
        active?.currency ?? ref.read(preferredCurrencyProvider);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(salaryRepositoryProvider);

    // 1) Ask for the new salary amount + currency.
    final entry = await showModalBottomSheet<_SalaryEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddSalarySheet(defaultCurrency: defaultCurrency),
    );
    if (entry == null) return;

    // 2) If a cycle is active, close it first (choose leftover disposition).
    if (active != null) {
      final spentMoney =
          ref.read(activeCycleSpentProvider).value ??
          Money.zero(active.currency);
      final leftover = active.income - spentMoney;
      if (!context.mounted) return;
      final disposition = await _askDisposition(context, leftover);
      if (disposition == null) return; // user cancelled the whole flow
      final saved =
          disposition == CycleDisposition.savings && leftover.isPositive
          ? leftover.minorUnits
          : 0;
      await repo.closeCycle(
        cycleId: active.id,
        savedMinorUnits: saved,
        disposition: disposition,
      );
    }

    // 3) Start the new cycle.
    await repo.startCycle(
      userId: userId,
      incomeMinorUnits: entry.amount.minorUnits,
      currencyCode: entry.amount.currency.code,
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('New salary cycle started')),
    );
  }

  Future<CycleDisposition?> _askDisposition(
    BuildContext context,
    Money leftover,
  ) {
    return showDialog<CycleDisposition>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close current cycle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              leftover.isNegative
                  ? 'You overspent this cycle by '
                        '${leftover.abs.currency.symbol}'
                        '${leftover.abs.asMajor.toStringAsFixed(2)}.'
                  : 'Leftover this cycle: '
                        '${leftover.currency.symbol}'
                        '${leftover.asMajor.toStringAsFixed(2)}.',
            ),
            const SizedBox(height: 8),
            const Text('What should happen to the leftover?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(CycleDisposition.spent),
            child: const Text('Used up'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(CycleDisposition.savings),
            child: const Text('Move to savings'),
          ),
        ],
      ),
    );
  }
}

class _ActiveCycleCard extends StatelessWidget {
  const _ActiveCycleCard({required this.active, required this.spent});

  final AsyncValue<SalaryCycle?> active;
  final AsyncValue<Money> spent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: active.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('Could not load salary'),
          data: (cycle) {
            if (cycle == null) {
              return const EmptyView(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No active salary',
                message: 'Add your salary to start tracking this cycle.',
              );
            }
            final spentMoney = spent.value ?? Money.zero(cycle.currency);
            final remaining = cycle.income - spentMoney;
            final ratio = cycle.incomeMinorUnits <= 0
                ? 0.0
                : (spentMoney.minorUnits / cycle.incomeMinorUnits).clamp(
                    0.0,
                    1.0,
                  );
            final over = remaining.isNegative;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('This cycle', style: theme.textTheme.titleMedium),
                    Text(
                      'since ${dateFormatter.medium(cycle.startedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _row(context, 'Salary', cycle.income, bold: true),
                const SizedBox(height: 6),
                _row(context, 'Spent', spentMoney),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: over
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      over ? 'Overspent by' : 'Remaining',
                      style: theme.textTheme.titleMedium,
                    ),
                    AmountText(
                      remaining.abs,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BalanceColors.forAmount(context, over ? -1 : 1),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    Money money, {
    bool bold = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        AmountText(
          money,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.savings});

  final AsyncValue<Money> savings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: BalanceColors.positive(context)
                  .withValues(alpha: 0.15),
              child: Icon(
                Icons.savings,
                color: BalanceColors.positive(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text('Total savings', style: theme.textTheme.titleMedium),
            ),
            savings.when(
              loading: () => const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const Text('—'),
              data: (money) => AmountText(
                money,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BalanceColors.positive(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosedCycleTile extends StatelessWidget {
  const _ClosedCycleTile({required this.cycle});

  final SalaryCycle cycle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toSavings = cycle.disposition == CycleDisposition.savings;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          toSavings ? Icons.savings : Icons.check_circle_outline,
          color: toSavings
              ? BalanceColors.positive(context)
              : theme.colorScheme.outline,
        ),
        title: AmountText(
          cycle.income,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${dateFormatter.medium(cycle.startedAt)} — '
          '${cycle.endedAt == null ? '' : dateFormatter.medium(cycle.endedAt!)}'
          '\n${cycle.disposition?.label ?? ''}',
        ),
        isThreeLine: true,
        trailing: toSavings
            ? AmountText(
                cycle.saved,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BalanceColors.positive(context),
                ),
              )
            : null,
      ),
    );
  }
}

/// The amount + currency picked in the add-salary sheet.
class _SalaryEntry {
  const _SalaryEntry(this.amount);
  final Money amount;
}

class _AddSalarySheet extends StatefulWidget {
  const _AddSalarySheet({required this.defaultCurrency});

  final Currency defaultCurrency;

  @override
  State<_AddSalarySheet> createState() => _AddSalarySheetState();
}

class _AddSalarySheetState extends State<_AddSalarySheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add salary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Starts a new tracking cycle. Any active cycle is closed first.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Salary amount',
                prefixText: '${widget.defaultCurrency.symbol} ',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Start cycle')),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final major = double.tryParse(_controller.text.trim());
    if (major == null || major <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    Navigator.of(context)
        .pop(_SalaryEntry(Money.fromMajor(major, widget.defaultCurrency)));
  }
}
