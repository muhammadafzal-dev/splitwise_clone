import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/presentation/user_switcher_sheet.dart';
import '../../friends/application/friend_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final friends = ref.watch(friendsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncValueView(
        value: currentUser,
        data: (user) {
          if (user == null) {
            return EmptyView(
              icon: Icons.person_off_outlined,
              title: 'Signed out',
              action: FilledButton(
                onPressed: () => showUserSwitcher(context),
                child: const Text('Choose a user'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      UserAvatar(user: user, radius: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: theme.textTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => showUserSwitcher(context),
                icon: const Icon(Icons.switch_account),
                label: const Text('Switch demo user'),
              ),
              const SizedBox(height: 24),
              Text('Friends', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              AsyncValueView(
                value: friends,
                data: (list) {
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No friends yet.'),
                    );
                  }
                  return Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < list.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            leading: UserAvatar(user: list[i], radius: 18),
                            title: Text(list[i].name),
                            subtitle: Text(list[i].email),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Mock data · theme follows system',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
