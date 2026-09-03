import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/entities/app_user.dart';

/// Friends of the signed-in user.
final friendsProvider = StreamProvider<List<AppUser>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(const []);
  return ref.watch(friendRepositoryProvider).watchFriends(userId);
});
