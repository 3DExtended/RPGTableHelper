extension IterableExtensions<T> on Iterable<T> {
  Iterable<T> sortBy<TSelected extends Comparable<TSelected>>(
          TSelected Function(T) selector) =>
      toList()..sort((a, b) => selector(a).compareTo(selector(b)));

  Iterable<T> sortByDescending<TSelected extends Comparable<TSelected>>(
          TSelected Function(T) selector) =>
      sortBy(selector).toList().reversed;
}
