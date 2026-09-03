import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../groups/application/group_providers.dart';
import '../../groups/domain/entities/group.dart';
import '../application/activity_providers.dart';
import '../domain/activity_item.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(activityFeedProvider);
    final directory = ref.watch(userDirectoryProvider);
    final groups = ref.watch(groupsProvider).value ?? const <Group>[];
    final groupsById = {for (final g in groups) g.id: g};

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: AsyncValueView(
        value: feed,
        onRetry: () => ref.invalidate(activityFeedProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No activity yet',
              message: 'Expenses and payments will show up here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _ActivityRow(
              item: items[i],
              directory: directory,
              groupsById: groupsById,
            ),
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.item,
    required this.directory,
    required this.groupsById,
  });

  final ActivityItem item;
  final Map<String, AppUser> directory;
  final Map<String, Group> groupsById;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, text) = _describe();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: text,
      subtitle: Text(
        dateFormatter.relative(item.timestamp),
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }

  (IconData, Widget) _describe() {
    switch (item) {
      case ExpenseActivity(:final expense):
        final payer = directory[expense.payerId]?.name ?? 'Someone';
        final group = groupsById[expense.groupId]?.name ?? 'a group';
        return (
          Icons.receipt_long,
          _RichLine(
            spans: [
              _b(payer),
              const TextSpan(text: ' added '),
              _b(expense.description),
              TextSpan(text: ' · ${moneyFormatter.format(expense.amount)}'),
              TextSpan(text: '  in $group'),
            ],
          ),
        );
      case SettlementActivity(:final settlement):
        final from = directory[settlement.fromUserId]?.name ?? 'Someone';
        final to = directory[settlement.toUserId]?.name ?? 'someone';
        return (
          Icons.handshake_outlined,
          _RichLine(
            spans: [
              _b(from),
              const TextSpan(text: ' paid '),
              _b(to),
              TextSpan(
                  text: ' · ${moneyFormatter.format(settlement.amount)}'),
            ],
          ),
        );
    }
  }

  TextSpan _b(String text) =>
      TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w600));
}

class _RichLine extends StatelessWidget {
  const _RichLine({required this.spans});

  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: spans,
      ),
    );
  }
}
