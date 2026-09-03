import 'package:uuid/uuid.dart';

import '../../../data/mock/mock_store.dart';
import '../domain/entities/group.dart';
import '../domain/group_repository.dart';

class MockGroupRepository implements GroupRepository {
  MockGroupRepository(this._store, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final MockStore _store;
  final Uuid _uuid;

  @override
  Stream<List<Group>> watchGroups(String userId) {
    return _store.watch().map((s) {
      final groups =
          s.groups.where((g) => g.memberIds.contains(userId)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return groups;
    });
  }

  @override
  Stream<Group?> watchGroup(String groupId) {
    return _store.watch().map((s) {
      for (final group in s.groups) {
        if (group.id == groupId) return group;
      }
      return null;
    });
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String emoji,
    required List<String> memberIds,
    required String currencyCode,
  }) {
    final group = Group(
      id: 'g_${_uuid.v4()}',
      name: name,
      emoji: emoji,
      memberIds: memberIds,
      currencyCode: currencyCode,
      createdAt: DateTime.now(),
    );
    return _store.addGroup(group);
  }

  @override
  Future<void> addMember(String groupId, String userId) =>
      _store.addMember(groupId, userId);
}
