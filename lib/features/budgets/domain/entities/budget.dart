import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';
import '../../../expenses/domain/entities/expense_category.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// A user's monthly spending limit for one category.
@freezed
abstract class Budget with _$Budget {
  const Budget._();

  const factory Budget({
    required String id,
    required String userId,
    required ExpenseCategory category,
    required int monthlyLimitMinorUnits,
    required String currencyCode,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  Currency get currency => Currency.fromCode(currencyCode);

  Money get limit => Money(monthlyLimitMinorUnits, currency);
}
