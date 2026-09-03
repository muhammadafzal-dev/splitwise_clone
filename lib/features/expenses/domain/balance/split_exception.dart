/// Thrown when a split is inconsistent — e.g. EXACT shares don't sum to the
/// total, or PERCENT shares don't sum to 100%.
class SplitException implements Exception {
  const SplitException(this.message);

  final String message;

  @override
  String toString() => 'SplitException: $message';
}
