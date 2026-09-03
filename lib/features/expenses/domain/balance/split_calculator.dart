import '../entities/expense.dart';
import '../entities/split_type.dart';
import 'split_exception.dart';

/// Splits a single [Expense] into the exact minor-unit amount each participant
/// owes. Pure and deterministic: the returned shares always sum **exactly** to
/// the expense total, with no lost or invented cents.
class SplitCalculator {
  const SplitCalculator();

  /// Returns `userId -> owed minor units` for the expense's participants.
  ///
  /// Throws [SplitException] if the expense is malformed (no participants, or
  /// EXACT/PERCENT shares that don't reconcile).
  Map<String, int> computeShares(Expense expense) {
    final participants = expense.participantIds;
    if (participants.isEmpty) {
      throw const SplitException('An expense needs at least one participant.');
    }
    final total = expense.amountMinorUnits;
    if (total < 0) {
      throw const SplitException('Expense amount cannot be negative.');
    }

    return switch (expense.splitType) {
      SplitType.equal => _equal(participants, total),
      SplitType.exact => _exact(participants, total, expense.exactShares),
      SplitType.percent =>
        _percent(participants, total, expense.percentShares),
    };
  }

  /// Divide equally; hand out the leftover cents one at a time to the first
  /// participants (in list order) so the shares sum exactly to [total].
  Map<String, int> _equal(List<String> participants, int total) {
    final n = participants.length;
    final base = total ~/ n;
    var remainder = total - base * n; // 0 .. n-1
    final shares = <String, int>{};
    for (final id in participants) {
      var share = base;
      if (remainder > 0) {
        share += 1;
        remainder -= 1;
      }
      shares[id] = share;
    }
    return shares;
  }

  Map<String, int> _exact(
    List<String> participants,
    int total,
    Map<String, int>? exactShares,
  ) {
    if (exactShares == null) {
      throw const SplitException('EXACT split requires explicit shares.');
    }
    _assertSameParticipants(participants, exactShares.keys);
    var sum = 0;
    for (final value in exactShares.values) {
      if (value < 0) {
        throw const SplitException('EXACT shares cannot be negative.');
      }
      sum += value;
    }
    if (sum != total) {
      throw SplitException(
        'EXACT shares sum to $sum but total is $total.',
      );
    }
    // Copy in participant order for a stable result.
    return {for (final id in participants) id: exactShares[id]!};
  }

  /// PERCENT shares are basis points (10000 == 100%). Uses largest-remainder
  /// rounding so the cents sum exactly to [total].
  Map<String, int> _percent(
    List<String> participants,
    int total,
    Map<String, int>? percentShares,
  ) {
    if (percentShares == null) {
      throw const SplitException('PERCENT split requires explicit shares.');
    }
    _assertSameParticipants(participants, percentShares.keys);
    const fullScale = 10000;
    var bpSum = 0;
    for (final bp in percentShares.values) {
      if (bp < 0) {
        throw const SplitException('PERCENT shares cannot be negative.');
      }
      bpSum += bp;
    }
    if (bpSum != fullScale) {
      throw SplitException(
        'PERCENT shares sum to ${bpSum / 100}% but must be 100%.',
      );
    }

    // Floor each share, track fractional remainders for largest-remainder.
    final shares = <String, int>{};
    final remainders = <String, int>{};
    var distributed = 0;
    for (final id in participants) {
      final raw = total * percentShares[id]!; // total * bp
      final floor = raw ~/ fullScale;
      shares[id] = floor;
      remainders[id] = raw % fullScale;
      distributed += floor;
    }

    var leftover = total - distributed;
    if (leftover > 0) {
      // Order participants by remainder desc, breaking ties by list order.
      final order = [...participants]..sort((a, b) {
          final cmp = remainders[b]!.compareTo(remainders[a]!);
          if (cmp != 0) return cmp;
          return participants.indexOf(a).compareTo(participants.indexOf(b));
        });
      for (final id in order) {
        if (leftover == 0) break;
        shares[id] = shares[id]! + 1;
        leftover -= 1;
      }
    }
    return shares;
  }

  void _assertSameParticipants(
    List<String> participants,
    Iterable<String> shareKeys,
  ) {
    final expected = participants.toSet();
    final actual = shareKeys.toSet();
    if (expected.length != participants.length) {
      throw const SplitException('Duplicate participant in expense.');
    }
    if (!_setEquals(expected, actual)) {
      throw const SplitException(
        'Shares must be provided for exactly the participants.',
      );
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
