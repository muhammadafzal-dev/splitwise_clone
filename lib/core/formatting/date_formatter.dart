import 'package:intl/intl.dart';

/// Date/time formatting helpers used across the app.
class DateFormatter {
  const DateFormatter();

  /// e.g. `Sep 3, 2026`.
  String medium(DateTime date) => DateFormat.yMMMd().format(date.toLocal());

  /// e.g. `Sep 3`.
  String dayMonth(DateTime date) => DateFormat.MMMd().format(date.toLocal());

  /// Relative-ish label for activity feeds: "Today", "Yesterday" or a date.
  String relative(DateTime date, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final that = _dateOnly(date.toLocal());
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return medium(date);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

const dateFormatter = DateFormatter();
