extension OrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

extension Intersperse<T> on Iterable<T> {
  Iterable<T> intersperse(T item) {
    final x = interspersePlusBeginning(item).toList();
    if (x.length > 1) {
      return x.sublist(1);
    }
    return x;
  }
  Iterable<T> interspersePlusEnd(T item) => [
        for (final x in this) ...[x, item]
      ];
  Iterable<T> interspersePlusBeginning(T item) => [
        for (final x in this) ...[item, x]
      ];
  Iterable<T> interspersePlusBeginningAndEnd(T item) =>
      interspersePlusBeginning(item).toList() + [item];
}
