import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/money/currency.dart';
import '../../../../core/money/money.dart';
import 'cycle_disposition.dart';

part 'salary_cycle.freezed.dart';
part 'salary_cycle.g.dart';

/// One salary/pay period. Starts when a salary is added and stays **active**
/// until the next salary arrives, at which point it is closed and its leftover
/// is either moved to savings or marked as used.
@freezed
abstract class SalaryCycle with _$SalaryCycle {
  const SalaryCycle._();

  const factory SalaryCycle({
    required String id,
    required String userId,
    required int incomeMinorUnits,
    required String currencyCode,
    required DateTime startedAt,

    /// Null while the cycle is active; set when closed.
    DateTime? endedAt,

    /// Amount moved to savings when closed (0 if used up).
    @Default(0) int savedMinorUnits,

    /// How the leftover was handled (null while active).
    CycleDisposition? disposition,
  }) = _SalaryCycle;

  factory SalaryCycle.fromJson(Map<String, dynamic> json) =>
      _$SalaryCycleFromJson(json);

  bool get isActive => endedAt == null;

  Currency get currency => Currency.fromCode(currencyCode);

  Money get income => Money(incomeMinorUnits, currency);

  Money get saved => Money(savedMinorUnits, currency);
}
