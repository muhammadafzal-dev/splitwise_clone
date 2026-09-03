import '../../auth/domain/entities/app_user.dart';

/// A user's friends — people they can add to groups or split with directly.
abstract interface class FriendRepository {
  /// Friends of [userId], reactive.
  Stream<List<AppUser>> watchFriends(String userId);

  /// Connect [userId] and [friendId] as friends.
  Future<void> addFriend(String userId, String friendId);
}
