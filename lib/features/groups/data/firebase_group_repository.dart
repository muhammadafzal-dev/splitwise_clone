import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../domain/entities/group.dart';
import '../domain/group_repository.dart';

/// Firebase-backed [GroupRepository]. Groups live in the top-level `groups`
/// collection; membership is a `memberIds` array queried with array-contains.
class FirebaseGroupRepository implements GroupRepository {
  FirebaseGroupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');

  @override
  Stream<List<Group>> watchGroups(String userId) {
    return _groups
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FirestoreMappers.groupFromDoc).toList());
  }

  @override
  Stream<Group?> watchGroup(String groupId) {
    return _groups
        .doc(groupId)
        .snapshots()
        .map((doc) => doc.exists ? FirestoreMappers.groupFromDoc(doc) : null);
  }

  @override
  Future<Group> createGroup({
    required String name,
    required String emoji,
    required List<String> memberIds,
    required String currencyCode,
  }) async {
    final ref = _groups.doc();
    final group = Group(
      id: ref.id,
      name: name,
      emoji: emoji,
      memberIds: memberIds,
      currencyCode: currencyCode,
      createdAt: DateTime.now(),
    );
    await ref.set(FirestoreMappers.groupToMap(group));
    return group;
  }

  @override
  Future<void> addMember(String groupId, String userId) {
    return _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }
}
