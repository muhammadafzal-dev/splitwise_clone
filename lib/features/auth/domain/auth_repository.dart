import 'entities/app_user.dart';

/// Authentication + current-user session.
///
/// The mock implementation lets you switch between demo users; the future
/// Firebase implementation will back this with `firebase_auth`. The interface
/// stays identical so nothing above the data layer changes.
abstract interface class AuthRepository {
  /// The signed-in user, or null when signed out. Emits on every switch.
  Stream<AppUser?> watchCurrentUser();

  /// Snapshot of the current user (null if signed out).
  AppUser? get currentUser;

  /// Demo users available to sign in as (mock only; Firebase drops this).
  Stream<List<AppUser>> watchSelectableUsers();

  /// Directory of all users, for resolving ids to names/avatars.
  Stream<List<AppUser>> watchAllUsers();

  /// Sign in as (or switch to) the given user.
  Future<void> signInAs(String userId);

  Future<void> signOut();
}
