enum OperationalStatus {
  deployable("Deployable"),
  needsRepair("Needs repair"),
  toBeReplaced("To be replaced");

  const OperationalStatus(this.displayName);

  final String displayName;
}
