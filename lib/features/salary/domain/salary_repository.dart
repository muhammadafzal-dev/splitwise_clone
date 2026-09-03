import 'entities/cycle_disposition.dart';
import 'entities/salary_cycle.dart';

/// Salary cycles: the user's pay periods and their close-out.
abstract interface class SalaryRepository {
  /// All of the user's cycles, newest first.
  Stream<List<SalaryCycle>> watchCycles(String userId);

  /// The currently active cycle, or null if none.
  Stream<SalaryCycle?> watchActiveCycle(String userId);

  /// Start a new active cycle for the user with the given income.
  Future<SalaryCycle> startCycle({
    required String userId,
    required int incomeMinorUnits,
    required String currencyCode,
  });

  /// Close a cycle, recording how the leftover was handled.
  Future<void> closeCycle({
    required String cycleId,
    required int savedMinorUnits,
    required CycleDisposition disposition,
  });
}
