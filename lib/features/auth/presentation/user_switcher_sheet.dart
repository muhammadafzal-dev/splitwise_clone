import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/user_avatar.dart';
import '../application/auth_providers.dart';

/// Bottom sheet to switch between demo users. This is the mock stand-in for a
/// real sign-in screen; the Firebase version replaces it, the rest of the app
/// is unaffected.
Future<void> showUserSwitcher(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _UserSwitcherSheet(),
  );
}

class _UserSwitcherSheet extends ConsumerWidget {
  const _UserSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(selectableUsersProvider);
    final currentId = ref.watch(currentUserIdProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Switch demo user',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: AsyncValueView(
              value: users,
              data: (list) => ListView(
                shrinkWrap: true,
                children: [
                  for (final user in list)
                    ListTile(
                      leading: UserAvatar(user: user),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: user.id == currentId
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () async {
                        await ref
                            .read(authRepositoryProvider)
                            .signInAs(user.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
