class RenumberEntry {
  final String id;
  final String name;
  final int currentNumber;
  final int pendingNumber;

  const RenumberEntry({
    required this.id,
    required this.name,
    required this.currentNumber,
    required this.pendingNumber,
  });

  RenumberEntry withPending(int n) => RenumberEntry(
        id: id,
        name: name,
        currentNumber: currentNumber,
        pendingNumber: n,
      );

  bool get hasChanged => pendingNumber != currentNumber;
}
