import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../expenses/application/expense_providers.dart';

/// Header card summarising the signed-in user's overall net position across all
/// groups. Balances are grouped by currency (usually one).
class OverallSummaryCard extends ConsumerWidget {
  const OverallSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final net = ref.watch(overallNetProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: net.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('Could not load balance'),
          data: (byCurrency) {
            if (byCurrency.isEmpty) {
              return _SettledRow(theme: theme);
            }
            // Primary line = the first/only currency; extras listed below.
            final entries = byCurrency.entries.toList();
            final primary = entries.first.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NetRow(money: primary),
                for (final entry in entries.skip(1)) ...[
                  const SizedBox(height: 12),
                  _NetRow(money: entry.value),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettledRow extends StatelessWidget {
  const _SettledRow({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'You are all settled up',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Icon(
          Icons.check_circle_outline,
          size: 40,
          color: theme.colorScheme.outline,
        ),
      ],
    );
  }
}

class _NetRow extends StatelessWidget {
  const _NetRow({required this.money});

  final Money money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = money.isPositive ? 'You are owed overall' : 'You owe overall';
    final color = BalanceColors.forAmount(context, money.minorUnits);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label · ${money.currency.code}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              AmountText(
                money.abs,
                colored: true,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Icon(
          money.isPositive ? Icons.trending_up : Icons.trending_down,
          size: 40,
          color: color,
        ),
      ],
    );
  }
}
