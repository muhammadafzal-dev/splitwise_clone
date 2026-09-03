import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/domain/entities/settlement.dart';
import '../../features/expenses/domain/entities/split_type.dart';
import '../../features/groups/domain/entities/group.dart';

/// Converts between domain entities and Firestore documents.
///
/// The domain entities stay Firebase-free; all the Firestore-specific concerns
/// (`Timestamp`, denormalised `involvedIds` for array-contains queries, the
/// document id living outside the field map) are handled here.
class FirestoreMappers {
  const FirestoreMappers._();

  // --- AppUser ---------------------------------------------------------------

  static AppUser userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      avatarColor: (data['avatarColor'] as num?)?.toInt() ?? 0xFF9E9E9E,
    );
  }

  static Map<String, dynamic> userToMap(AppUser user) => {
        'name': user.name,
        'email': user.email,
        'avatarColor': user.avatarColor,
      };

  // --- Group -----------------------------------------------------------------

  static Group groupFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Group(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: (data['emoji'] as String?) ?? '👥',
      memberIds: _stringList(data['memberIds']),
      currencyCode: (data['currencyCode'] as String?) ?? 'USD',
      createdAt: _dateTime(data['createdAt']),
    );
  }

  static Map<String, dynamic> groupToMap(Group group) => {
        'name': group.name,
        'emoji': group.emoji,
        'memberIds': group.memberIds,
        'currencyCode': group.currencyCode,
        'createdAt': Timestamp.fromDate(group.createdAt),
      };

  // --- Expense ---------------------------------------------------------------

  static Expense expenseFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Expense(
      id: doc.id,
      groupId: (data['groupId'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      payerId: (data['payerId'] as String?) ?? '',
      amountMinorUnits: (data['amountMinorUnits'] as num?)?.toInt() ?? 0,
      currencyCode: (data['currencyCode'] as String?) ?? 'USD',
      splitType: _splitType(data['splitType'] as String?),
      participantIds: _stringList(data['participantIds']),
      exactShares: _intMap(data['exactShares']),
      percentShares: _intMap(data['percentShares']),
      createdAt: _dateTime(data['createdAt']),
    );
  }

  static Map<String, dynamic> expenseToMap(Expense expense) => {
        'groupId': expense.groupId,
        'description': expense.description,
        'payerId': expense.payerId,
        'amountMinorUnits': expense.amountMinorUnits,
        'currencyCode': expense.currencyCode,
        'splitType': expense.splitType.name,
        'participantIds': expense.participantIds,
        if (expense.exactShares != null) 'exactShares': expense.exactShares,
        if (expense.percentShares != null)
          'percentShares': expense.percentShares,
        'createdAt': Timestamp.fromDate(expense.createdAt),
        // Denormalised so a single collection query can fetch everything that
        // affects a user's balance (payer + participants).
        'involvedIds': {expense.payerId, ...expense.participantIds}.toList(),
      };

  // --- Settlement ------------------------------------------------------------

  static Settlement settlementFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Settlement(
      id: doc.id,
      groupId: (data['groupId'] as String?) ?? '',
      fromUserId: (data['fromUserId'] as String?) ?? '',
      toUserId: (data['toUserId'] as String?) ?? '',
      amountMinorUnits: (data['amountMinorUnits'] as num?)?.toInt() ?? 0,
      currencyCode: (data['currencyCode'] as String?) ?? 'USD',
      createdAt: _dateTime(data['createdAt']),
    );
  }

  static Map<String, dynamic> settlementToMap(Settlement settlement) => {
        'groupId': settlement.groupId,
        'fromUserId': settlement.fromUserId,
        'toUserId': settlement.toUserId,
        'amountMinorUnits': settlement.amountMinorUnits,
        'currencyCode': settlement.currencyCode,
        'createdAt': Timestamp.fromDate(settlement.createdAt),
        'involvedIds': [settlement.fromUserId, settlement.toUserId],
      };

  // --- Primitives ------------------------------------------------------------

  static List<String> _stringList(Object? value) =>
      (value as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

  static Map<String, int>? _intMap(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries)
        entry.key as String: (entry.value as num).toInt(),
    };
  }

  static DateTime _dateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static SplitType _splitType(String? value) => switch (value) {
        'exact' => SplitType.exact,
        'percent' => SplitType.percent,
        _ => SplitType.equal,
      };
}
