import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_providers.dart';
import '../../expenses/domain/entities/expense_category.dart';
import '../../expenses/presentation/widgets/expense_category_ui.dart';
import '../application/budget_providers.dart';
import '../domain/entities/budget.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(budgetProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New budget'),
      ),
      body: AsyncValueView(
        value: progress,
        data: (list) {
          if (list.isEmpty) {
            return EmptyView(
              icon: Icons.savings_outlined,
              title: 'No budgets yet',
              message: 'Set a monthly limit for a category to track spending.',
              action: FilledButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('New budget'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              for (final p in list)
                _BudgetCard(
                  progress: p,
                  onEdit: () => _edit(context, ref, existing: p.budget),
                  onDelete: () => ref
                      .read(budgetRepositoryProvider)
                      .removeBudget(p.budget.id),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Budget? existing,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final result = await showModalBottomSheet<Budget>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BudgetEditor(userId: userId, existing: existing),
    );
    if (result != null) {
      await ref.read(budgetRepositoryProvider).setBudget(result);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.progress,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetProgress progress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = progress.budget.category;
    final color = progress.isOver ? theme.colorScheme.error : category.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIcon(category: category, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.label, style: theme.textTheme.titleMedium),
                      Row(
                        children: [
                          AmountText(
                            progress.spent,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            ' of ${progress.budget.limit.currency.symbol}'
                            '${progress.budget.limit.asMajor.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.ratio.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress.isOver
                  ? 'Over by ${_fmt(progress.remaining.abs)}'
                  : '${_fmt(progress.remaining)} left this month',
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Money m) => '${m.currency.symbol}${m.asMajor.toStringAsFixed(2)}';
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({required this.userId, this.existing});

  final String userId;
  final Budget? existing;

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  late ExpenseCategory _category =
      widget.existing?.category ?? ExpenseCategory.food;
  late final TextEditingController _amountController = TextEditingController(
    text: widget.existing != null
        ? widget.existing!.limit.asMajor.toStringAsFixed(0)
        : '',
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit budget' : 'New budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in ExpenseCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: isEdit
                        ? null
                        : (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.savings_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save' : 'Create budget'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final major = double.tryParse(_amountController.text.trim());
    if (major == null || major <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    final budget = Budget(
      id: widget.existing?.id ?? 'b_${const Uuid().v4()}',
      userId: widget.userId,
      category: _category,
      monthlyLimitMinorUnits: Money.fromMajor(major, Currency.usd).minorUnits,
      currencyCode: 'USD',
    );
    Navigator.of(context).pop(budget);
  }
}
