import 'entities/group.dart';

/// Helpers for a user's private "Personal" group — the container for solo
/// expenses that aren't split with anyone. Modelling personal spending as a
/// single-member group lets it reuse the whole expense/analytics pipeline while
/// always netting to zero in balances.
abstract final class PersonalGroup {
  static const emoji = '🧍';
  static const name = 'Personal';

  static String idFor(String userId) => 'g_personal_$userId';

  static bool isPersonal(String groupId) => groupId.startsWith('g_personal_');

  static Group create(String userId, {required DateTime createdAt}) => Group(
    id: idFor(userId),
    name: name,
    emoji: emoji,
    memberIds: [userId],
    currencyCode: 'USD',
    createdAt: createdAt,
  );
}
