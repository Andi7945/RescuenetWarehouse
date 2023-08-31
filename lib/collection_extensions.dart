extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  List<MapEntry<K, List<E>>> groupBySorted<K>(
          K Function(E) keyFunction, int Function(K, K) sortFunction) =>
      groupBy(keyFunction).entries.toList()
        ..sort((a, b) => sortFunction(a.key, b.key));

  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension MapValues<E, F> on Map<E, F> {
  Map<E, Z> mapValues<Z>(Z Function(F) valueFunction) =>
      map((key, value) => MapEntry(key, valueFunction(value)));
}

extension FlatMapValues<E, F, X> on Map<E, Map<F, X>> {
  List<Z> flatMapValues<Z>(List<Z> Function(F) valueFunction) => entries
      .expand((e) => e.value.entries.map((e) => e.key))
      .expand(valueFunction)
      .toList();
}
