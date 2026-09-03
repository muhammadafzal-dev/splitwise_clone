import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../domain/auth_repository.dart';
import '../domain/entities/app_user.dart';

/// Firebase-backed [AuthRepository]. Identity comes from `firebase_auth`; the
/// profile (name, avatar colour) lives in `users/{uid}` in Firestore.
///
/// Implements the exact same interface as [MockAuthRepository], so switching
/// backends is only a provider override (see `app/firebase/firebase_backend.dart`).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Best-effort synchronous snapshot from the auth token (the full profile
    // arrives via watchCurrentUser).
    return AppUser(
      id: user.uid,
      name: user.displayName ?? user.email ?? 'You',
      email: user.email ?? '',
      avatarColor: 0xFF6C5CE7,
    );
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    // switchMap: whenever auth state changes, resubscribe to that user's doc.
    // Subscriptions are created lazily in onListen and torn down in onCancel so
    // nothing leaks if the stream is built but never listened to.
    final controller = StreamController<AppUser?>();
    StreamSubscription<User?>? authSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? profileSub;

    controller.onListen = () {
      authSub = _auth.authStateChanges().listen((user) {
        profileSub?.cancel();
        if (user == null) {
          controller.add(null);
          return;
        }
        profileSub = _users.doc(user.uid).snapshots().listen((doc) {
          controller.add(
            doc.exists ? FirestoreMappers.userFromDoc(doc) : currentUser,
          );
        }, onError: controller.addError);
      }, onError: controller.addError);
    };
    controller.onCancel = () async {
      await profileSub?.cancel();
      await authSub?.cancel();
    };
    return controller.stream;
  }

  @override
  Stream<List<AppUser>> watchSelectableUsers() {
    // Real auth has no "pick a demo user" concept — sign-in is via Firebase.
    return Stream.value(const []);
  }

  @override
  Stream<List<AppUser>> watchAllUsers() {
    return _users.snapshots().map(
      (snap) => snap.docs.map(FirestoreMappers.userFromDoc).toList(),
    );
  }

  @override
  Future<void> signInAs(String userId) {
    throw UnsupportedError(
      'With Firebase, sign in through FirebaseAuth (e.g. email/Google), '
      'not by picking a user id.',
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> setPreferredCurrency(String userId, String currencyCode) {
    return _users.doc(userId).set({
      'preferredCurrencyCode': currencyCode,
    }, SetOptions(merge: true));
  }
}
