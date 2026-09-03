import 'package:flutter/material.dart';

import '../money/currency.dart';

/// Shows a bottom sheet to choose a [Currency]. Returns the picked currency, or
/// null if dismissed.
Future<Currency?> showCurrencyPicker(
  BuildContext context, {
  Currency? selected,
}) {
  return showModalBottomSheet<Currency>(
    context: context,
    showDragHandle: true,
    builder: (_) => _CurrencyPicker(selected: selected),
  );
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({this.selected});

  final Currency? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Choose currency', style: theme.textTheme.titleLarge),
          ),
          for (final currency in Currency.values)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  currency.symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              title: Text(currency.displayName),
              subtitle: Text(currency.code),
              trailing: currency == selected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(currency),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
