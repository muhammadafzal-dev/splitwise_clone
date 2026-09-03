import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../domain/entities/app_user.dart';

/// The signed-in user (null while loading or signed out).
final currentUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchCurrentUser(),
);

/// Convenience: the current user's id, or null.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider).value?.id,
);

/// Demo users you can sign in as (mock-only concept).
final selectableUsersProvider = StreamProvider<List<AppUser>>(
  (ref) => ref.watch(authRepositoryProvider).watchSelectableUsers(),
);

/// Every user, for resolving ids to names/avatars.
final allUsersProvider = StreamProvider<List<AppUser>>(
  (ref) => ref.watch(authRepositoryProvider).watchAllUsers(),
);

/// A lookup map id -> user. Empty until [allUsersProvider] has data.
final userDirectoryProvider = Provider<Map<String, AppUser>>((ref) {
  final users = ref.watch(allUsersProvider).value ?? const [];
  return {for (final u in users) u.id: u};
});

/// The signed-in user's preferred/default currency (USD until loaded).
final preferredCurrencyProvider = Provider<Currency>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return Currency.fromCode(user?.preferredCurrencyCode ?? 'USD');
});
