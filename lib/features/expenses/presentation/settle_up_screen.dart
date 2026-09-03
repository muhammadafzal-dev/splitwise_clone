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
import '../application/expense_providers.dart';
import '../domain/balance/balance.dart';
import '../domain/entities/settlement.dart';

class SettleUpScreen extends ConsumerStatefulWidget {
  const SettleUpScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends ConsumerState<SettleUpScreen> {
  final _amountController = TextEditingController();
  String? _fromId;
  String? _toId;
  bool _submitting = false;
  bool _initialised = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider(widget.groupId)).value;
    final directory = ref.watch(userDirectoryProvider);
    final plan = ref.watch(groupSettlementPlanProvider(widget.groupId));

    if (group == null) return const Scaffold(body: LoadingView());
    final members = [
      for (final id in group.memberIds)
        if (directory[id] != null) directory[id]!,
    ];
    if (members.isEmpty) return const Scaffold(body: LoadingView());

    if (!_initialised) {
      _initialised = true;
      _fromId = ref.read(currentUserIdProvider) ?? members.first.id;
      _toId = members.firstWhere((m) => m.id != _fromId).id;
    }
    final currency = Currency.fromCode(group.currencyCode);

    return Scaffold(
      appBar: AppBar(title: const Text('Settle up')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SuggestionList(
            plan: plan,
            directory: directory,
            currency: currency,
            onPick: (edge) => setState(() {
              _fromId = edge.fromUserId;
              _toId = edge.toUserId;
              _amountController.text =
                  edge.amount.asMajor.toStringAsFixed(currency.decimalDigits);
            }),
          ),
          const SizedBox(height: 24),
          Text('Record a payment',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _PersonDropdown(
            label: 'From',
            members: members,
            value: _fromId,
            onChanged: (id) => setState(() => _fromId = id),
          ),
          const SizedBox(height: 12),
          Center(
            child: Icon(Icons.arrow_downward,
                color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 12),
          _PersonDropdown(
            label: 'To',
            members: members,
            value: _toId,
            onChanged: (id) => setState(() => _toId = id),
          ),
          const SizedBox(height: 16),
          TextField(
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
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _submitting ? null : () => _submit(currency),
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Record payment'),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(Currency currency) async {
    final major = double.tryParse(_amountController.text.trim());
    if (major == null || major <= 0) {
      _showError('Enter a valid amount');
      return;
    }
    if (_fromId == null || _toId == null || _fromId == _toId) {
      _showError('Payer and receiver must be different');
      return;
    }
    final settlement = Settlement(
      id: 's_${const Uuid().v4()}',
      groupId: widget.groupId,
      fromUserId: _fromId!,
      toUserId: _toId!,
      amountMinorUnits: Money.fromMajor(major, currency).minorUnits,
      currencyCode: currency.code,
      createdAt: DateTime.now(),
    );

    setState(() => _submitting = true);
    try {
      await ref.read(expenseRepositoryProvider).addSettlement(settlement);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.plan,
    required this.directory,
    required this.currency,
    required this.onPick,
  });

  final AsyncValue<List<DebtEdge>> plan;
  final Map<String, AppUser> directory;
  final Currency currency;
  final ValueChanged<DebtEdge> onPick;

  @override
  Widget build(BuildContext context) {
    return plan.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (edges) {
        if (edges.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggested payments',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final edge in edges)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => onPick(edge),
                  leading: directory[edge.fromUserId] != null
                      ? UserAvatar(
                          user: directory[edge.fromUserId]!, radius: 16)
                      : null,
                  title: Text(
                    '${directory[edge.fromUserId]?.name ?? '—'} → '
                    '${directory[edge.toUserId]?.name ?? '—'}',
                  ),
                  trailing: Text(
                    '${currency.symbol}'
                    '${edge.amount.asMajor.toStringAsFixed(currency.decimalDigits)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PersonDropdown extends StatelessWidget {
  const _PersonDropdown({
    required this.label,
    required this.members,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<AppUser> members;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final m in members)
          DropdownMenuItem(
            value: m.id,
            child: Row(
              children: [
                UserAvatar(user: m, radius: 12),
                const SizedBox(width: 8),
                Text(m.name),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
