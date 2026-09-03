import 'entities/group.dart';

/// Groups the user belongs to and group membership management.
abstract interface class GroupRepository {
  /// Groups that [userId] is a member of, reactive.
  Stream<List<Group>> watchGroups(String userId);

  /// A single group by id (null if it does not exist).
  Stream<Group?> watchGroup(String groupId);

  /// Create a group. [memberIds] should already include the creator.
  Future<Group> createGroup({
    required String name,
    required String emoji,
    required List<String> memberIds,
    required String currencyCode,
  });

  Future<void> addMember(String groupId, String userId);
}
