import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../expenses/application/expense_providers.dart';

/// Header card summarising the signed-in user's overall net position across all
/// groups.
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
          data: (money) {
            final label = money.isZero
                ? 'You are all settled up'
                : money.isPositive
                    ? 'You are owed overall'
                    : 'You owe overall';
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      AmountText(
                        money.abs,
                        colored: true,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BalanceColors.forAmount(
                              context, money.minorUnits),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  money.isPositive
                      ? Icons.trending_up
                      : money.isNegative
                          ? Icons.trending_down
                          : Icons.check_circle_outline,
                  size: 40,
                  color: BalanceColors.forAmount(context, money.minorUnits),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
