import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/entities/group.dart';

/// Groups the signed-in user belongs to. Empty while signed out.
final groupsProvider = StreamProvider<List<Group>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(groupRepositoryProvider).watchGroups(userId);
});

/// A single group by id.
final groupProvider = StreamProvider.family<Group?, String>(
  (ref, groupId) => ref.watch(groupRepositoryProvider).watchGroup(groupId),
);
