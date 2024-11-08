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

  /// Examples:
  /// 1) A list [2,2,2,1] would return [2,1,0,0]
  ///
  /// 2) A list [
  ///   _CharacterStat(CharacterStatValueType.multiselect),
  ///   _CharacterStat(CharacterStatValueType.multiselect),
  ///   _CharacterStat(CharacterStatValueType.multiselect),
  ///   _CharacterStat(CharacterStatValueType.int),
  /// ]; would also return [2,1,0,0]
  List<int> consecutiveCounts(bool Function(T a, T b) isEqual) {
    List<int> result = List.filled(length, 0);
    for (int i = length - 2; i >= 0; i--) {
      if (isEqual(this[i], this[i + 1])) {
        result[i] = result[i + 1] + 1;
      }
    }
    return result;
  }

  /// Returns a list of tuples where each tuple contains an element of type `E` (the "type"
  /// determined by the [typeSelector] function) and an integer count representing the number
  /// of consecutive elements in the list that share the same type.
  ///
  /// This function iterates through the list and groups consecutive elements based on the value
  /// returned by [typeSelector]. When it encounters an element whose type differs from the previous,
  /// it adds a tuple `(type, count)` to the result list, then resets the counter for the new type.
  ///
  /// ### Parameters:
  /// - [typeSelector]: A function that takes an element of type `T` and returns a value of
  ///   type `E`, which represents the "type" by which consecutive elements are grouped. This
  ///   function is used to classify or identify the type of each element in the list.
  ///
  /// ### Returns:
  /// A `List<(E, int)>` where each tuple contains:
  /// - `E`: The type of the consecutive elements (as determined by [typeSelector])
  /// - `int`: The count of consecutive elements with that type.
  ///
  /// ### Example:
  /// ```dart
  /// // Example with a list of strings
  /// List<String> fruits = ['apple', 'apple', 'banana', 'banana', 'banana', 'apple', 'orange', 'orange'];
  ///
  /// // Get the types (first letter) and counts of consecutive occurrences
  /// List<(String, int)> result = fruits.consecutiveTypeCounts((fruit) => fruit[0]);
  /// print(result); // Output: [('a', 2), ('b', 3), ('a', 1), ('o', 2)]
  ///
  /// // Another example using integers (group by even/odd)
  /// List<int> numbers = [1, 1, 2, 2, 2, 3, 3];
  /// List<(bool, int)> result = numbers.consecutiveTypeCounts((num) => num.isEven);
  /// print(result); // Output: [(false, 2), (true, 3), (false, 2)]
  /// ```
  ///
  /// ### Edge Cases:
  /// - If the list is empty, the function returns an empty list.
  /// - If all elements have the same type according to [typeSelector], the result will contain
  ///   a single tuple with the full length of the list.
  /// - If the list has only one element, the result will contain a single tuple with that element's
  ///   type and the count of `1`.
  ///
  /// ### Complexity:
  /// - Time complexity: O(n), where `n` is the number of elements in the list, since each element
  ///   is processed once.
  /// - Space complexity: O(k), where `k` is the number of distinct consecutive groups in the list.
  ///   The result list will have at most `k` elements, one per consecutive group.

  List<(E, int)> consecutiveTypeCounts<E>(E Function(T) typeSelector) {
    if (isEmpty) return [];

    List<(E, int)> result = [];
    int count = 1;
    E currentType = typeSelector(this[0]);

    for (int i = 1; i < length; i++) {
      if (typeSelector(this[i]) == currentType) {
        count++;
      } else {
        result.add((currentType, count));
        currentType = typeSelector(this[i]);
        count = 1;
      }
    }

    result.add((currentType, count)); // Add the last sequence count
    return result;
  }
}
