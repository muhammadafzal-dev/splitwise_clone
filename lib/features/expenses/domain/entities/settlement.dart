import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';

part 'settlement.freezed.dart';
part 'settlement.g.dart';

/// A recorded payment from one member to another that reduces a debt.
@freezed
abstract class Settlement with _$Settlement {
  const Settlement._();

  const factory Settlement({
    required String id,
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required int amountMinorUnits,
    required String currencyCode,
    required DateTime createdAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);

  Currency get currency => Currency.fromCode(currencyCode);

  Money get amount => Money(amountMinorUnits, currency);
}
