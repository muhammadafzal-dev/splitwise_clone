import 'package:cloud_firestore/cloud_firestore.dart';

import '../mock/seed_data.dart';
import 'firestore_mappers.dart';

/// One-shot helper to populate Firestore with the same demo data the mock uses,
/// so the Firebase backend has something to show. Safe to run repeatedly — it
/// writes the same fixed document ids (idempotent upsert).
///
/// Usage (e.g. from a debug button or a `main` variant):
/// ```dart
/// await FirebaseSeeder(FirebaseFirestore.instance).seed();
/// ```
///
/// Note: this writes user/group/expense docs. Your `users/{uid}` ids should
/// match your real Firebase Auth uids if you want the signed-in user to line
/// up with the demo data; otherwise treat it as sample content.
class FirebaseSeeder {
  FirebaseSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> seed() async {
    final batch = _firestore.batch();
    final friendships = buildSeedFriendships();

    for (final user in seedUsers) {
      batch.set(
        _firestore.collection('users').doc(user.id),
        {
          ...FirestoreMappers.userToMap(user),
          'friendIds': friendships[user.id]?.toList() ?? const [],
        },
      );
    }
    for (final group in seedGroups) {
      batch.set(
        _firestore.collection('groups').doc(group.id),
        FirestoreMappers.groupToMap(group),
      );
    }
    for (final expense in seedExpenses) {
      batch.set(
        _firestore.collection('expenses').doc(expense.id),
        FirestoreMappers.expenseToMap(expense),
      );
    }
    for (final settlement in seedSettlements) {
      batch.set(
        _firestore.collection('settlements').doc(settlement.id),
        FirestoreMappers.settlementToMap(settlement),
      );
    }

    await batch.commit();
  }
}
