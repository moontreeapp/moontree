/// maintains order like a list but does not allow duplicates like a set
List<T> combineWithoutDuplicates<T>(List<T> list1, List<T> list2) {
  final result = <T>[];
  result.addAll(list1);
  for (var item in list2) {
    if (!result.contains(item)) {
      result.add(item);
    }
  }
  return result;
}

/// maintains order like a list but does not allow duplicates like a set using
/// an attribute as the equatable metric. isn't that a good idea?
///List<T> combineWithoutDuplicatesOnId<T>(
