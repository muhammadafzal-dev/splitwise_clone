import 'package:flutter/material.dart';

import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import 'expense_category_ui.dart';
import 'expense_tile.dart';

/// The expense list for a group with search + category filtering. Holds its own
/// filter state so the parent screen stays simple.
class ExpensesSection extends StatefulWidget {
  const ExpensesSection({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  State<ExpensesSection> createState() => _ExpensesSectionState();
}

class _ExpensesSectionState extends State<ExpensesSection> {
  final _searchController = TextEditingController();
  String _query = '';
  ExpenseCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'No expenses yet',
          message: 'Add the first expense for this group.',
        ),
      );
    }

    // Only offer category chips that actually appear in this group.
    final presentCategories = <ExpenseCategory>{
      for (final e in widget.expenses) e.category,
    }.toList()..sort((a, b) => a.label.compareTo(b.label));

    final filtered = widget.expenses.where((e) {
      final matchesQuery =
          _query.isEmpty ||
          e.description.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _category == null || e.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search expenses',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        if (presentCategories.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                const SizedBox(width: 8),
                for (final c in presentCategories) ...[
                  FilterChip(
                    avatar: Icon(c.icon, size: 16, color: c.color),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (sel) =>
                        setState(() => _category = sel ? c : null),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No expenses match your filter',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          )
        else
          for (final expense in filtered) ExpenseTile(expense: expense),
      ],
    );
  }
}
