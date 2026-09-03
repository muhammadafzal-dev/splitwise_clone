import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/currency.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/currency_picker.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/application/auth_providers.dart';
import '../../friends/application/friend_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  static const _emojis = ['🏠', '✈️', '🍽️', '🎉', '🚗', '⛰️', '🏝️', '💼'];

  final _nameController = TextEditingController();
  String _emoji = _emojis.first;
  final Set<String> _selectedFriendIds = {};
  Currency? _currency;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final Currency currency = _currency ?? ref.watch(preferredCurrencyProvider);
    _currency ??= currency;

    return Scaffold(
      appBar: AppBar(title: const Text('New group')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              _EmojiButton(emoji: _emoji, onTap: _pickEmoji),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    hintText: 'Apartment, Trip…',
                  ),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: Text('${currency.displayName} · ${currency.code}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showCurrencyPicker(
                  context,
                  selected: currency,
                );
                if (picked != null) setState(() => _currency = picked);
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            currentUser == null
                ? 'You will be added automatically'
                : '${currentUser.name} (you) will be added automatically',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(height: 12),
          AsyncValueView(
            value: friends,
            data: (list) {
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No friends to add yet.'),
                );
              }
              return Column(
                children: [
                  for (final friend in list)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _selectedFriendIds.contains(friend.id),
                      onChanged: (v) => setState(() {
                        if (v ?? false) {
                          _selectedFriendIds.add(friend.id);
                        } else {
                          _selectedFriendIds.remove(friend.id);
                        }
                      }),
                      secondary: UserAvatar(user: friend, radius: 16),
                      title: Text(friend.name),
                      subtitle: Text(friend.email),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _canSubmit && !_submitting ? _submit : null,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Create group'),
          ),
        ),
      ),
    );
  }

  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  Future<void> _pickEmoji() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final e in _emojis)
                InkWell(
                  onTap: () => Navigator.of(context).pop(e),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(e, style: const TextStyle(fontSize: 32)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _emoji = picked);
  }

  Future<void> _submit() async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _submitting = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .createGroup(
            name: _nameController.text.trim(),
            emoji: _emoji,
            memberIds: {currentUserId, ..._selectedFriendIds}.toList(),
            currencyCode: (_currency ?? Currency.usd).code,
          );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Group created')));
    } on Object catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not create group: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}
