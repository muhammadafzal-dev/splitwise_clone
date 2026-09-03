import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../expenses/application/expense_providers.dart';
import '../../../expenses/domain/balance/balance.dart';
import '../../domain/entities/group.dart';

/// A group row showing its icon, name, members and the signed-in user's net
/// balance within that group.
class GroupTile extends ConsumerWidget {
  const GroupTile({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final directory = ref.watch(userDirectoryProvider);
    final balances = ref.watch(groupBalancesProvider(group.id));

    final members = [
      for (final id in group.memberIds)
        if (directory[id] != null) directory[id]!,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(AppRoutes.groupDetail(group.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _GroupEmoji(emoji: group.emoji),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AvatarStack(users: members),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _GroupBalanceLabel(
                balances: balances,
                currentUserId: currentUserId,
                currencyCode: group.currencyCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupEmoji extends StatelessWidget {
  const _GroupEmoji({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

class _GroupBalanceLabel extends StatelessWidget {
  const _GroupBalanceLabel({
    required this.balances,
    required this.currentUserId,
    required this.currencyCode,
  });

  final AsyncValue<List<Balance>> balances;
  final String? currentUserId;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return balances.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const Icon(Icons.error_outline, size: 18),
      data: (list) {
        final currency = Currency.fromCode(currencyCode);
        var mine = Money.zero(currency);
        for (final balance in list) {
          if (balance.userId == currentUserId) {
            mine = balance.amount;
            break;
          }
        }
        final label = mine.isZero
            ? 'settled up'
            : mine.isPositive
            ? 'you are owed'
            : 'you owe';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 2),
            if (!mine.isZero)
              AmountText(
                mine.abs,
                colored: true,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BalanceColors.forAmount(context, mine.minorUnits),
                ),
              )
            else
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: theme.colorScheme.outline,
              ),
          ],
        );
      },
    );
  }
}
