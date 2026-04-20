# TODO: Fix rapid-typing race condition in item edit page amounts

## Problem

`RescueInputAmount` fires `onChange` on every keystroke (no debounce). Each keystroke
triggers a full `updateAssignment` round-trip: read current count from Firestore, calculate
delta, write new count. Concurrent in-flight writes read stale data and produce wrong results.

**Concrete failure case — user clears "50" and types "5", then "0":**
1. keystroke "5" → `setAmount(5)` → reads count=50, delta=-45, writes count=5
2. keystroke "50" → `setAmount(50)` → reads count=50 (stale, write 1 not committed yet) → delta=0 → exits early — **count stays at 5**

**Work log corruption:** typing "123" writes three entries (+1, +12, +123 = +136 logged instead of +123).

## Affected code

- `lib/ui/rescue_input_amount.dart` — fires `onChange` on every character
- `lib/ui/item_edit_page/item_edit_page_amounts_row.dart` — no guard on `fnChangeAmount`
- `lib/state/current_item_assignments_notifier.dart` — `setAmount()` called without debounce

## Fix

Debounce the `onChange` in `RescueInputAmount` (e.g. 500 ms after last keystroke before calling
the callback). Dart's `Timer` is sufficient — cancel and restart on each change, only fire when
the timer completes.

```dart
Timer? _debounce;

_onChange(String s) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    final newAmount = int.tryParse(s);
    if (newAmount != null) widget.onChange(newAmount);
  });
}
```

Also dispose `_debounce` in `dispose()`.

## Note

The +/- icon buttons in `AssignmentByContainerSingleItem` are already protected by the
`isOperationActive` guard and are NOT affected by this bug. Only the free-text input field is.
