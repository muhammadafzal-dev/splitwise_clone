import '../../../data/mock/mock_store.dart';
import '../domain/auth_repository.dart';
import '../domain/entities/app_user.dart';

/// Mock [AuthRepository] backed by [MockStore]. Swapping in Firebase later means
/// writing a `FirebaseAuthRepository` with the same methods and overriding the
/// provider — nothing else changes.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._store);

  final MockStore _store;

  @override
  AppUser? get currentUser {
    final snap = _store.snapshot;
    return _userOrNull(snap.users, snap.currentUserId);
  }

  @override
  Stream<AppUser?> watchCurrentUser() =>
      _store.watch().map((s) => _userOrNull(s.users, s.currentUserId));

  @override
  Stream<List<AppUser>> watchSelectableUsers() =>
      _store.watch().map((s) => s.users);

  @override
  Stream<List<AppUser>> watchAllUsers() => _store.watch().map((s) => s.users);

  @override
  Future<void> signInAs(String userId) => _store.signInAs(userId);

  @override
  Future<void> signOut() => _store.signOut();

  @override
  Future<void> setPreferredCurrency(String userId, String currencyCode) =>
      _store.setPreferredCurrency(userId, currencyCode);

  AppUser? _userOrNull(List<AppUser> users, String? id) {
    if (id == null) return null;
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }
}
