import 'package:json_annotation/json_annotation.dart';

/// A spending category for an expense. Stored by [name] in JSON/Firestore.
///
/// This stays Flutter-free (domain layer); icon and colour for a category live
/// in a presentation helper (`expense_category_ui.dart`).
enum ExpenseCategory {
  @JsonValue('food')
  food('Food & Drink'),
  @JsonValue('groceries')
  groceries('Groceries'),
  @JsonValue('rent')
  rent('Rent & Housing'),
  @JsonValue('utilities')
  utilities('Utilities'),
  @JsonValue('transport')
  transport('Transport'),
  @JsonValue('entertainment')
  entertainment('Entertainment'),
  @JsonValue('travel')
  travel('Travel'),
  @JsonValue('shopping')
  shopping('Shopping'),
  @JsonValue('health')
  health('Health'),
  @JsonValue('other')
  other('Other');

  const ExpenseCategory(this.label);

  final String label;

  static ExpenseCategory fromName(String? name) => values.firstWhere(
    (c) => c.name == name,
    orElse: () => ExpenseCategory.other,
  );
}
