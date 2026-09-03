import 'package:uuid/uuid.dart';

import '../../../data/mock/mock_store.dart';
import '../domain/entities/cycle_disposition.dart';
import '../domain/entities/salary_cycle.dart';
import '../domain/salary_repository.dart';

class MockSalaryRepository implements SalaryRepository {
  MockSalaryRepository(this._store, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final MockStore _store;
  final Uuid _uuid;

  @override
  Stream<List<SalaryCycle>> watchCycles(String userId) {
    return _store.watch().map((s) {
      final cycles = s.salaryCycles.where((c) => c.userId == userId).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return cycles;
    });
  }

  @override
  Stream<SalaryCycle?> watchActiveCycle(String userId) {
    return watchCycles(userId).map((cycles) {
      for (final cycle in cycles) {
        if (cycle.isActive) return cycle;
      }
      return null;
    });
  }

  @override
  Future<SalaryCycle> startCycle({
    required String userId,
    required int incomeMinorUnits,
    required String currencyCode,
  }) {
    final cycle = SalaryCycle(
      id: 'sc_${_uuid.v4()}',
      userId: userId,
      incomeMinorUnits: incomeMinorUnits,
      currencyCode: currencyCode,
      startedAt: DateTime.now(),
    );
    return _store.startSalaryCycle(cycle);
  }

  @override
  Future<void> closeCycle({
    required String cycleId,
    required int savedMinorUnits,
    required CycleDisposition disposition,
  }) {
    return _store.closeSalaryCycle(
      cycleId,
      savedMinorUnits: savedMinorUnits,
      disposition: disposition,
      endedAt: DateTime.now(),
    );
  }
}
