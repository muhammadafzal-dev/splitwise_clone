import '../../../data/mock/mock_store.dart';
import '../../auth/domain/entities/app_user.dart';
import '../domain/friend_repository.dart';

class MockFriendRepository implements FriendRepository {
  MockFriendRepository(this._store);

  final MockStore _store;

  @override
  Stream<List<AppUser>> watchFriends(String userId) {
    return _store.watch().map((s) {
      final friendIds = s.friendships[userId] ?? const {};
      final friends =
          s.users.where((u) => friendIds.contains(u.id)).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return friends;
    });
  }

  @override
  Future<void> addFriend(String userId, String friendId) =>
      _store.addFriend(userId, friendId);
}
