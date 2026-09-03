import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/money/money.dart';

/// A simple monthly spending bar chart. Each bar is scaled to the max month.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({super.key, required this.data, this.height = 140});

  /// month (first day) -> spend, ascending by month.
  final Map<DateTime, Money> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No spending yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }
    final entries = data.entries.toList();
    final maxValue = entries
        .map((e) => e.value.minorUnits)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final entry in entries)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      entry.value.minorUnits == 0 ? '' : _short(entry.value),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: (entry.value.minorUnits / maxValue).clamp(
                          0.02,
                          1.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat.MMM().format(entry.key),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _short(Money money) {
    final major = money.asMajor;
    if (major >= 1000) return '${(major / 1000).toStringAsFixed(1)}k';
    return major.toStringAsFixed(0);
  }
}
