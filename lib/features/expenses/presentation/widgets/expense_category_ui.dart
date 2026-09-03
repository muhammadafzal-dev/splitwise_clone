import 'package:flutter/material.dart';

import '../../domain/entities/expense_category.dart';

/// Presentation-layer icon + colour for each [ExpenseCategory]. Kept out of the
/// domain enum so the domain stays Flutter-free.
extension ExpenseCategoryUi on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.food => Icons.restaurant,
    ExpenseCategory.groceries => Icons.shopping_cart,
    ExpenseCategory.rent => Icons.home,
    ExpenseCategory.utilities => Icons.bolt,
    ExpenseCategory.transport => Icons.directions_car,
    ExpenseCategory.entertainment => Icons.movie,
    ExpenseCategory.travel => Icons.flight,
    ExpenseCategory.shopping => Icons.shopping_bag,
    ExpenseCategory.health => Icons.favorite,
    ExpenseCategory.other => Icons.category,
  };

  Color get color => switch (this) {
    ExpenseCategory.food => const Color(0xFFEF4444),
    ExpenseCategory.groceries => const Color(0xFF22C55E),
    ExpenseCategory.rent => const Color(0xFF6366F1),
    ExpenseCategory.utilities => const Color(0xFFF59E0B),
    ExpenseCategory.transport => const Color(0xFF06B6D4),
    ExpenseCategory.entertainment => const Color(0xFFA855F7),
    ExpenseCategory.travel => const Color(0xFF3B82F6),
    ExpenseCategory.shopping => const Color(0xFFEC4899),
    ExpenseCategory.health => const Color(0xFF14B8A6),
    ExpenseCategory.other => const Color(0xFF64748B),
  };
}

/// A small rounded icon chip for a category (used in tiles and pickers).
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 44});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}
