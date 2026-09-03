import 'package:json_annotation/json_annotation.dart';

/// How an expense's amount is divided among its participants.
enum SplitType {
  /// Divide equally; leftover cents distributed deterministically.
  @JsonValue('equal')
  equal,

  /// Each participant owes an explicit amount (minor units). Must sum to total.
  @JsonValue('exact')
  exact,

  /// Each participant owes a percentage (basis points). Must sum to 100%.
  @JsonValue('percent')
  percent;

  String get label => switch (this) {
        SplitType.equal => 'Equally',
        SplitType.exact => 'Exact amounts',
        SplitType.percent => 'Percentages',
      };
}
