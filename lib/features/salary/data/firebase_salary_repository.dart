import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/firebase/firestore_mappers.dart';
import '../domain/entities/cycle_disposition.dart';
import '../domain/entities/salary_cycle.dart';
import '../domain/salary_repository.dart';

/// Firebase-backed [SalaryRepository]. Cycles live in a top-level
/// `salaryCycles` collection, scoped per user.
class FirebaseSalaryRepository implements SalaryRepository {
  FirebaseSalaryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _cycles =>
      _firestore.collection('salaryCycles');

  @override
  Stream<List<SalaryCycle>> watchCycles(String userId) {
    return _cycles
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(FirestoreMappers.salaryCycleFromDoc).toList(),
        );
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
  }) async {
    final ref = _cycles.doc();
    final cycle = SalaryCycle(
      id: ref.id,
      userId: userId,
      incomeMinorUnits: incomeMinorUnits,
      currencyCode: currencyCode,
      startedAt: DateTime.now(),
    );
    await ref.set(FirestoreMappers.salaryCycleToMap(cycle));
    return cycle;
  }

  @override
  Future<void> closeCycle({
    required String cycleId,
    required int savedMinorUnits,
    required CycleDisposition disposition,
  }) {
    return _cycles.doc(cycleId).update({
      'endedAt': Timestamp.fromDate(DateTime.now()),
      'savedMinorUnits': savedMinorUnits,
      'disposition': disposition.name,
    });
  }
}
