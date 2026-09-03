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
    // Subscriptions are created lazily (onListen) and cleaned up (onCancel).
    // Firestore's `whereIn` allows at most 30 values, so friend ids are queried
    // in chunks of 30 and merged — no friend is silently dropped.
    final controller = StreamController<List<AppUser>>();
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? userSub;
    final chunkSubs =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
    final chunkResults = <int, List<AppUser>>{};

    void emitMerged() {
      final all = [for (final list in chunkResults.values) ...list]
        ..sort((a, b) => a.name.compareTo(b.name));
      if (!controller.isClosed) controller.add(all);
    }

    Future<void> cancelChunks() async {
      for (final sub in chunkSubs) {
        await sub.cancel();
      }
      chunkSubs.clear();
      chunkResults.clear();
    }

    controller.onListen = () {
      userSub = _users.doc(userId).snapshots().listen((doc) async {
        final ids =
            (doc.data()?['friendIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [];
        await cancelChunks();
        if (ids.isEmpty) {
          if (!controller.isClosed) controller.add(const []);
          return;
        }
        for (var i = 0; i < ids.length; i += 30) {
          final chunkIndex = i ~/ 30;
          final chunk = ids.sublist(
            i,
            i + 30 > ids.length ? ids.length : i + 30,
          );
          chunkSubs.add(
            _users
                .where(FieldPath.documentId, whereIn: chunk)
                .snapshots()
                .listen((snap) {
                  chunkResults[chunkIndex] = snap.docs
                      .map(FirestoreMappers.userFromDoc)
                      .toList();
                  emitMerged();
                }, onError: controller.addError),
          );
        }
      }, onError: controller.addError);
    };

    controller.onCancel = () async {
      await cancelChunks();
      await userSub?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> addFriend(String userId, String friendId) async {
    final batch = _firestore.batch();
    batch.set(_users.doc(userId), {
      'friendIds': FieldValue.arrayUnion([friendId]),
    }, SetOptions(merge: true));
    batch.set(_users.doc(friendId), {
      'friendIds': FieldValue.arrayUnion([userId]),
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
