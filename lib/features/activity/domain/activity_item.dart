import '../../expenses/domain/entities/expense.dart';
import '../../expenses/domain/entities/settlement.dart';

/// One entry in the activity feed — either an expense was added or a payment was
/// recorded. A sealed type so the UI can switch exhaustively.
sealed class ActivityItem {
  const ActivityItem();

  DateTime get timestamp;
}

class ExpenseActivity extends ActivityItem {
  const ExpenseActivity(this.expense);

  final Expense expense;

  @override
  DateTime get timestamp => expense.createdAt;
}

class SettlementActivity extends ActivityItem {
  const SettlementActivity(this.settlement);

  final Settlement settlement;

  @override
  DateTime get timestamp => settlement.createdAt;
}
