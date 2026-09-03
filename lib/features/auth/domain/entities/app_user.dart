import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// A person in the system. Named `AppUser` (not `User`) so it never collides
/// with `firebase_auth`'s `User` when the Firebase layer is added later.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,

    /// ARGB colour used for the avatar when there is no photo.
    required int avatarColor,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
