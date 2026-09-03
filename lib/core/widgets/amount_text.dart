import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../formatting/money_formatter.dart';
import '../money/money.dart';

/// Displays a [Money] amount, optionally coloured by sign (green owed / red
/// owing / muted settled).
class AmountText extends StatelessWidget {
  const AmountText(
    this.money, {
    super.key,
    this.colored = false,
    this.signed = false,
    this.style,
  });

  final Money money;
  final bool colored;
  final bool signed;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = signed
        ? moneyFormatter.formatSigned(money)
        : moneyFormatter.format(money);
    final baseStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    return Text(
      text,
      style: baseStyle?.copyWith(
        color: colored
            ? BalanceColors.forAmount(context, money.minorUnits)
            : baseStyle.color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
