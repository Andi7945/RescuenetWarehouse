# TODO: Fix multi-user concurrent write race condition on assignment counts

## Problem

`AssignmentService.updateAssignment` does a non-atomic read-then-write:

1. `getAssignmentByIds()` — Firestore read
2. `delta = newAmount - current.count`
3. `upsertAssignment(count: newAmount)` — Firestore write

If two users tap +1 on the same item at the same time, both read the same stale count and
both write the same new value — net result is +1 instead of +2.

**Example:**
- Item count = 5
- User A taps + → reads 5, writes 6
- User B taps + → reads 5 (stale), writes 6
- Final count: 6 (should be 7)

The fine-grained reactivity work (Dec 2025) reduced the staleness window but did not
eliminate the race condition.

## Affected code

- `lib/services/assignment/assignment_service.dart` — `updateAssignment()`, non-atomic
- `lib/repositories/impl/firebase/firebase_assignment_repository.dart` — `upsertAssignment()` uses `doc.set()` (last-write-wins)

## Fix options

**Option A — Firestore atomic increment (recommended for +/- buttons)**

Replace the read-modify-write with `FieldValue.increment(delta)` for the +1/-1 use case.
The delta is always ±1 from the button, so no read is needed:

```dart
await assignmentCollection.doc(assignment.id).update({
  'count': FieldValue.increment(delta),
});
```

Requires knowing the assignment ID upfront (already available in `AssignmentByContainerSingleItem`).

**Option B — Firestore transaction (for arbitrary new amounts)**

Use `FirebaseFirestore.instance.runTransaction()` to wrap the read and write atomically.
Needed for the item edit page where an arbitrary absolute count is set.

```dart
await FirebaseFirestore.instance.runTransaction((tx) async {
  final doc = await tx.get(assignmentCollection.doc(id));
  final current = doc.data()!;
  final delta = newAmount - current.count;
  tx.update(doc.reference, {'count': newAmount});
  // create work log with correct delta
});
```

## Scope

- The +/- buttons (`AssignmentByContainerSingleItem`) → Option A
- The item edit page amounts field → Option B (or fix the typing debounce first, which reduces
  concurrent writes significantly in practice)

## Priority

Medium. Requires multiple users working on the exact same item simultaneously to trigger.
In a small team (2-3 packers) the window is narrow. The typing debounce fix (see
`todo-typing-amounts.md`) should be done first as it affects single users too.
