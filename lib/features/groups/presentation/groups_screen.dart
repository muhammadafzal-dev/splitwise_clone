import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/user_switcher_sheet.dart';
import '../application/group_providers.dart';
import 'widgets/group_tile.dart';
import 'widgets/overall_summary_card.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => showUserSwitcher(context),
                child: UserAvatar(user: currentUser, radius: 18),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newGroup),
        icon: const Icon(Icons.add),
        label: const Text('New group'),
      ),
      body: AsyncValueView(
        value: groups,
        onRetry: () => ref.invalidate(groupsProvider),
        data: (list) {
          if (list.isEmpty) {
            return EmptyView(
              icon: Icons.groups_outlined,
              title: 'No groups yet',
              message: 'Create a group to start splitting expenses.',
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.newGroup),
                icon: const Icon(Icons.add),
                label: const Text('New group'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(groupsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                if (currentUser != null) ...[
                  Text(
                    'Hi, ${currentUser.name.split(' ').first} 👋',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                ],
                const OverallSummaryCard(),
                const SizedBox(height: 20),
                Text(
                  'Your groups',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (final group in list) GroupTile(group: group),
              ],
            ),
          );
        },
      ),
    );
  }
}
