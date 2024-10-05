extension IterableExtension<T> on Iterable<T> {
  List<T> distinct<U>({required U Function(T t) by}) {
    final unique = <U, T>{};

    for (final item in this) {
      unique.putIfAbsent(by(item), () => item);
    }

    return unique.values.toList();
  }
}
