extension CustomListExtensions<T> on List<T> {
  void addAllIntoSortedList(
      Iterable<T> elements, int Function(T a, T b) comparer) {
    for (var elementToAdd in elements) {
      var currentPosition = 0;

      // Find the correct insertion position
      while (currentPosition < length &&
          comparer(this[currentPosition], elementToAdd) < 0) {
        currentPosition++;
      }

      // Insert the element at the identified position
      insert(currentPosition, elementToAdd);
    }
  }
}
