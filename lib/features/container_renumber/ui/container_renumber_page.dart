import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../business_logic/container_renumber_notifier.dart';
import '../business_logic/renumber_validation.dart';
import '../business_logic/renumber_entry.dart';

class ContainerRenumberPage extends ConsumerStatefulWidget {
  const ContainerRenumberPage({super.key});

  @override
  ConsumerState<ContainerRenumberPage> createState() =>
      _ContainerRenumberPageState();
}

class _ContainerRenumberPageState extends ConsumerState<ContainerRenumberPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllers(ref.read(containerRenumberNotifierProvider));
  }

  void _syncControllers(List<RenumberEntry> entries) {
    final newIds = entries.map((e) => e.id).toSet();
    // remove controllers for containers no longer present
    _controllers.keys
        .where((id) => !newIds.contains(id))
        .toList()
        .forEach((id) {
      _controllers.remove(id)!.dispose();
    });
    // add controllers for new containers; don't overwrite active ones
    for (final entry in entries) {
      if (!_controllers.containsKey(entry.id)) {
        _controllers[entry.id] =
            TextEditingController(text: '${entry.pendingNumber}');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(containerRenumberNotifierProvider);
    final conflicts = conflictingIds(entries);
    final changed = changedEntries(entries);
    final canApply = changed.isNotEmpty && isValidRenumbering(entries);

    // After a successful save the notifier rebuilds with new currentNumbers.
    // Sync controllers so they reflect the freshly-reset baseline, but only
    // for containers whose controller text is already stable (not being typed).
    // We do a targeted sync: update controller text only when the pending value
    // in state differs from what the controller currently shows AND the field
    // is not focused.
    for (final entry in entries) {
      final ctrl = _controllers[entry.id];
      if (ctrl != null && !ctrl.value.composing.isValid) {
        final stateText = '${entry.pendingNumber}';
        if (ctrl.text != stateText) {
          ctrl.text = stateText;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Renumber Containers')),
      body: Column(
        children: [
          _warningBanner(),
          Expanded(child: _entriesList(entries, conflicts)),
          _applyBar(context, canApply, changed.length),
        ],
      ),
    );
  }

  Widget _warningBanner() => Container(
        color: Colors.amber.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Already-printed labels and packing lists will show outdated numbers. '
                'Reprint them after applying changes.',
              ),
            ),
          ],
        ),
      );

  Widget _entriesList(List<RenumberEntry> entries, Set<String> conflicts) =>
      ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) => _entryRow(entries[i], conflicts),
      );

  Widget _entryRow(RenumberEntry entry, Set<String> conflicts) {
    final isConflict = conflicts.contains(entry.id);
    final ctrl = _controllers[entry.id];
    if (ctrl == null) return const SizedBox.shrink();

    return ListTile(
      leading: Text(
        '${entry.currentNumber}',
        style: const TextStyle(color: Colors.grey),
      ),
      title: Text(entry.name),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            errorText: isConflict ? 'Duplicate' : null,
          ),
          onChanged: (val) {
            final n = int.tryParse(val);
            if (n != null) {
              ref
                  .read(containerRenumberNotifierProvider.notifier)
                  .updatePending(entry.id, n);
            }
          },
        ),
      ),
    );
  }

  Widget _applyBar(BuildContext context, bool canApply, int changeCount) =>
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canApply && !_saving ? () => _apply(context) : null,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      changeCount > 0
                          ? 'Apply Changes ($changeCount modified)'
                          : 'No Changes',
                    ),
            ),
          ),
        ),
      );

  Future<void> _apply(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(containerRenumberNotifierProvider.notifier)
          .applyRenumbering();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Container numbers updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
