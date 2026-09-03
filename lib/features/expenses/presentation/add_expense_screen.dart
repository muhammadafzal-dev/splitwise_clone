import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/entities/app_user.dart';
import '../../groups/application/group_providers.dart';
import '../domain/balance/split_calculator.dart';
import '../domain/balance/split_exception.dart';
import '../domain/entities/expense.dart';
import '../domain/entities/split_type.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _splitCalculator = const SplitCalculator();

  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};

  String? _payerId;
  final Set<String> _participants = {};
  SplitType _splitType = SplitType.equal;
  bool _submitting = false;
  bool _initialised = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final c in _exactControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initFromMembers(List<AppUser> members) {
    if (_initialised) return;
    _initialised = true;
    _payerId = ref.read(currentUserIdProvider) ?? members.first.id;
    _participants.addAll(members.map((m) => m.id));
    for (final m in members) {
      _exactControllers[m.id] = TextEditingController();
      _percentControllers[m.id] = TextEditingController();
    }
  }

  Currency _currency(String code) => Currency.fromCode(code);

  int? _totalMinorUnits(Currency currency) {
    final major = double.tryParse(_amountController.text.trim());
    if (major == null || major <= 0) return null;
    return Money.fromMajor(major, currency).minorUnits;
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final directory = ref.watch(userDirectoryProvider);

    if (group == null) {
      return const Scaffold(body: LoadingView());
    }
    final members = [
      for (final id in group.memberIds)
        if (directory[id] != null) directory[id]!,
    ];
    if (members.isEmpty) {
      return const Scaffold(body: LoadingView());
    }
    _initFromMembers(members);
    final currency = _currency(group.currencyCode);

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Dinner, taxi, groceries…',
                prefixIcon: Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${currency.symbol} ',
                prefixIcon: const Icon(Icons.payments_outlined),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (_) => setState(() {}),
              validator: (_) => _totalMinorUnits(currency) == null
                  ? 'Enter a valid amount'
                  : null,
            ),
            const SizedBox(height: 24),
            const _Label('Paid by'),
            const SizedBox(height: 8),
            _PayerSelector(
              members: members,
              selected: _payerId,
              onChanged: (id) => setState(() => _payerId = id),
            ),
            const SizedBox(height: 24),
            const _Label('Split'),
            const SizedBox(height: 8),
            SegmentedButton<SplitType>(
              segments: const [
                ButtonSegment(
                    value: SplitType.equal, label: Text('Equally')),
                ButtonSegment(value: SplitType.exact, label: Text('Exact')),
                ButtonSegment(
                    value: SplitType.percent, label: Text('Percent')),
              ],
              selected: {_splitType},
              onSelectionChanged: (s) =>
                  setState(() => _splitType = s.first),
            ),
            const SizedBox(height: 16),
            _buildSplitEditor(members, currency),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _submitting ? null : () => _submit(group.currencyCode),
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save expense'),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitEditor(List<AppUser> members, Currency currency) {
    final total = _totalMinorUnits(currency);
    return switch (_splitType) {
      SplitType.equal => _EqualSplitInfo(
          members: members,
          participants: _participants,
          total: total,
          currency: currency,
          onToggle: (id, on) => setState(() {
            if (on) {
              _participants.add(id);
            } else {
              _participants.remove(id);
            }
          }),
        ),
      SplitType.exact => _ExactSplitEditor(
          members: members,
          controllers: _exactControllers,
          currency: currency,
          total: total,
          onChanged: () => setState(() {}),
        ),
      SplitType.percent => _PercentSplitEditor(
          members: members,
          controllers: _percentControllers,
          onChanged: () => setState(() {}),
        ),
    };
  }

  Future<void> _submit(String currencyCode) async {
    if (!_formKey.currentState!.validate()) return;
    final currency = _currency(currencyCode);
    final total = _totalMinorUnits(currency);
    if (total == null || _payerId == null) return;

    final Expense expense;
    try {
      expense = _buildExpense(currencyCode, total);
      // Validate the split up-front so we never persist an inconsistent one.
      _splitCalculator.computeShares(expense);
    } on SplitException catch (e) {
      _showError(e.message);
      return;
    } on Object catch (e) {
      _showError(e.toString());
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(expenseRepositoryProvider).addExpense(expense);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Expense _buildExpense(String currencyCode, int total) {
    final currency = _currency(currencyCode);
    switch (_splitType) {
      case SplitType.equal:
        final participants = _participants.toList();
        if (participants.isEmpty) {
          throw const SplitException('Pick at least one participant.');
        }
        return _baseExpense(
          currencyCode: currencyCode,
          total: total,
          participantIds: participants,
        );
      case SplitType.exact:
        final shares = <String, int>{};
        for (final entry in _exactControllers.entries) {
          final text = entry.value.text.trim();
          if (text.isEmpty) continue;
          final major = double.tryParse(text);
          if (major == null) {
            throw const SplitException('Invalid amount for a participant.');
          }
          shares[entry.key] = Money.fromMajor(major, currency).minorUnits;
        }
        if (shares.isEmpty) {
          throw const SplitException('Enter each participant\'s amount.');
        }
        return _baseExpense(
          currencyCode: currencyCode,
          total: total,
          participantIds: shares.keys.toList(),
          exactShares: shares,
        );
      case SplitType.percent:
        final shares = <String, int>{};
        for (final entry in _percentControllers.entries) {
          final text = entry.value.text.trim();
          if (text.isEmpty) continue;
          final pct = double.tryParse(text);
          if (pct == null) {
            throw const SplitException('Invalid percentage for a participant.');
          }
          shares[entry.key] = (pct * 100).round(); // percent -> basis points
        }
        if (shares.isEmpty) {
          throw const SplitException('Enter each participant\'s percentage.');
        }
        return _baseExpense(
          currencyCode: currencyCode,
          total: total,
          participantIds: shares.keys.toList(),
          percentShares: shares,
        );
    }
  }

  Expense _baseExpense({
    required String currencyCode,
    required int total,
    required List<String> participantIds,
    Map<String, int>? exactShares,
    Map<String, int>? percentShares,
  }) {
    return Expense(
      id: 'x_${const Uuid().v4()}',
      groupId: widget.groupId,
      description: _descriptionController.text.trim(),
      payerId: _payerId!,
      amountMinorUnits: total,
      currencyCode: currencyCode,
      splitType: _splitType,
      participantIds: participantIds,
      exactShares: exactShares,
      percentShares: percentShares,
      createdAt: DateTime.now(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      );
}

class _PayerSelector extends StatelessWidget {
  const _PayerSelector({
    required this.members,
    required this.selected,
    required this.onChanged,
  });

  final List<AppUser> members;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in members)
          ChoiceChip(
            avatar: UserAvatar(user: m, radius: 12),
            label: Text(m.name.split(' ').first),
            selected: selected == m.id,
            onSelected: (_) => onChanged(m.id),
          ),
      ],
    );
  }
}

class _EqualSplitInfo extends StatelessWidget {
  const _EqualSplitInfo({
    required this.members,
    required this.participants,
    required this.total,
    required this.currency,
    required this.onToggle,
  });

  final List<AppUser> members;
  final Set<String> participants;
  final int? total;
  final Currency currency;
  final void Function(String id, bool on) onToggle;

  @override
  Widget build(BuildContext context) {
    final count = participants.length;
    final each = (total != null && count > 0)
        ? Money(total! ~/ count, currency)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          each == null
              ? 'Select who shares this expense'
              : 'Split ${_fmt(Money(total!, currency))} between $count '
                  '· about ${_fmt(each)} each',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 8),
        for (final m in members)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: participants.contains(m.id),
            onChanged: (v) => onToggle(m.id, v ?? false),
            secondary: UserAvatar(user: m, radius: 16),
            title: Text(m.name),
          ),
      ],
    );
  }

  String _fmt(Money m) => '${currency.symbol}${m.asMajor.toStringAsFixed(currency.decimalDigits)}';
}

class _ExactSplitEditor extends StatelessWidget {
  const _ExactSplitEditor({
    required this.members,
    required this.controllers,
    required this.currency,
    required this.total,
    required this.onChanged,
  });

  final List<AppUser> members;
  final Map<String, TextEditingController> controllers;
  final Currency currency;
  final int? total;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    var entered = 0;
    for (final c in controllers.values) {
      final major = double.tryParse(c.text.trim());
      if (major != null) entered += Money.fromMajor(major, currency).minorUnits;
    }
    final remaining = (total ?? 0) - entered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in members)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                UserAvatar(user: m, radius: 16),
                const SizedBox(width: 12),
                Expanded(child: Text(m.name)),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: controllers[m.id],
                    textAlign: TextAlign.end,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: currency.symbol,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ),
        _RemainingHint(
          ok: total != null && remaining == 0,
          text: total == null
              ? 'Enter the total amount first'
              : remaining == 0
                  ? 'Shares add up 🎉'
                  : '${currency.symbol}${(remaining / currency.minorUnitsPerMajor).toStringAsFixed(currency.decimalDigits)} left to assign',
        ),
      ],
    );
  }
}

class _PercentSplitEditor extends StatelessWidget {
  const _PercentSplitEditor({
    required this.members,
    required this.controllers,
    required this.onChanged,
  });

  final List<AppUser> members;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    var entered = 0.0;
    for (final c in controllers.values) {
      final pct = double.tryParse(c.text.trim());
      if (pct != null) entered += pct;
    }
    final remaining = 100 - entered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final m in members)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                UserAvatar(user: m, radius: 16),
                const SizedBox(width: 12),
                Expanded(child: Text(m.name)),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controllers[m.id],
                    textAlign: TextAlign.end,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: '%',
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
          ),
        _RemainingHint(
          ok: remaining.abs() < 0.001,
          text: remaining.abs() < 0.001
              ? 'Percentages add up to 100% 🎉'
              : '${remaining.toStringAsFixed(2)}% remaining',
        ),
      ],
    );
  }
}

class _RemainingHint extends StatelessWidget {
  const _RemainingHint({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = ok ? Colors.green : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.info_outline,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
