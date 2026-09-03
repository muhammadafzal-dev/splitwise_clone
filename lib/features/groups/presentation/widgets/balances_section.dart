import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../expenses/application/expense_providers.dart';
import '../../../expenses/domain/balance/balance.dart';

/// The simplified "who pays whom" list for a group, one row per suggested
/// payment. Shows a settled state when everyone is square.
class BalancesSection extends ConsumerWidget {
  const BalancesSection({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(groupSettlementPlanProvider(groupId));
    final directory = ref.watch(userDirectoryProvider);
    final theme = Theme.of(context);

    return plan.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Could not compute balances: $e'),
      ),
      data: (edges) {
        if (edges.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: BalanceColors.positive(context),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Everyone is settled up',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }
        return Card(
          child: Column(
            children: [
              for (var i = 0; i < edges.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _DebtRow(edge: edges[i], directory: directory),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.edge, required this.directory});

  final DebtEdge edge;
  final Map<String, AppUser> directory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = directory[edge.fromUserId];
    final to = directory[edge.toUserId];
    final fromName = from?.name ?? 'Someone';
    final toName = to?.name ?? 'someone';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (from != null) UserAvatar(user: from, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: fromName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' owes '),
                  TextSpan(
                    text: toName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          AmountText(
            edge.amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: BalanceColors.negative(context),
            ),
          ),
        ],
      ),
    );
  }
}
