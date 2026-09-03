import 'package:json_annotation/json_annotation.dart';

/// What happened to the leftover money when a salary cycle was closed.
enum CycleDisposition {
  /// Leftover was moved to savings.
  @JsonValue('savings')
  savings,

  /// Leftover was treated as spent / used up.
  @JsonValue('spent')
  spent;

  String get label => switch (this) {
    CycleDisposition.savings => 'Moved to savings',
    CycleDisposition.spent => 'Used up',
  };

  static CycleDisposition fromName(String? name) => values.firstWhere(
    (d) => d.name == name,
    orElse: () => CycleDisposition.spent,
  );
}
