import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';
import 'split_type.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// A single expense paid by one member and shared among participants.
///
/// The amount is stored as integer [amountMinorUnits] plus a [currencyCode]
/// string so the map serialises cleanly to Firestore. Use [amount] to get a
/// typed [Money] in domain code.
@freezed
abstract class Expense with _$Expense {
  const Expense._();

  const factory Expense({
    required String id,
    required String groupId,
    required String description,
    required String payerId,
    required int amountMinorUnits,
    required String currencyCode,
    required SplitType splitType,
    /// Everyone who shares this expense (may include the payer).
    required List<String> participantIds,
    required DateTime createdAt,

    /// EXACT split: userId -> owed minor units. Null for other split types.
    Map<String, int>? exactShares,

    /// PERCENT split: userId -> basis points (10000 == 100%). Null otherwise.
    Map<String, int>? percentShares,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Currency get currency => Currency.fromCode(currencyCode);

  Money get amount => Money(amountMinorUnits, currency);
}
