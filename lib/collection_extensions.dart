extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

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
