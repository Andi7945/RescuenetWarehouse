import 'renumber_entry.dart';

/// Returns the set of container IDs whose pending number collides with another entry.
Set<String> conflictingIds(List<RenumberEntry> entries) {
  final seen = <int, List<String>>{};
  for (final e in entries) {
    seen.putIfAbsent(e.pendingNumber, () => []).add(e.id);
  }
  return {
    for (final ids in seen.values)
      if (ids.length > 1) ...ids,
  };
}

/// Returns true when all pending numbers are positive and there are no duplicates.
bool isValidRenumbering(List<RenumberEntry> entries) =>
    entries.every((e) => e.pendingNumber > 0) &&
    conflictingIds(entries).isEmpty;

/// Returns only entries where the number actually changed.
List<RenumberEntry> changedEntries(List<RenumberEntry> entries) =>
    entries.where((e) => e.hasChanged).toList();

/// Builds a sorted (by pendingNumber) copy of entries.
List<RenumberEntry> sortedByPending(List<RenumberEntry> entries) =>
    [...entries]..sort((a, b) => a.pendingNumber.compareTo(b.pendingNumber));
