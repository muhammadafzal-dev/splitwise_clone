import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../../auth/domain/entities/app_user.dart';
import '../domain/friend_repository.dart';

/// Firebase-backed [FriendRepository]. Friendship is stored as a `friendIds`
/// array on each `users/{uid}` document and kept symmetric.
class FirebaseFriendRepository implements FriendRepository {
  FirebaseFriendRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<List<AppUser>> watchFriends(String userId) {
    final controller = StreamController<List<AppUser>>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? friendsSub;

    final userSub = _users.doc(userId).snapshots().listen((doc) {
      final ids = (doc.data()?['friendIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [];
      friendsSub?.cancel();
      if (ids.isEmpty) {
        controller.add(const []);
        return;
      }
      // whereIn is capped at 30 ids; fine for a demo social graph.
      friendsSub = _users
          .where(FieldPath.documentId, whereIn: ids.take(30).toList())
          .snapshots()
          .listen((snap) {
        final friends =
            snap.docs.map(FirestoreMappers.userFromDoc).toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        controller.add(friends);
      }, onError: controller.addError);
    }, onError: controller.addError);

    controller.onCancel = () async {
      await friendsSub?.cancel();
      await userSub.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> addFriend(String userId, String friendId) async {
    final batch = _firestore.batch();
    batch.set(
      _users.doc(userId),
      {
        'friendIds': FieldValue.arrayUnion([friendId]),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _users.doc(friendId),
      {
        'friendIds': FieldValue.arrayUnion([userId]),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }
}
