import 'package:rxdart/rxdart.dart';

extension MaximumExtension<T> on Stream<T> {
  /// Applies a comparator function over a Stream sequence and returns the
  /// maximum value so far. Waits until value is non-null to emit.
  ///
  /// ### Example
  ///
  ///     Stream.fromIterable(['a', 'ab', 'abc', 'ab'])
  ///        .maximum((e1, e2) => e1.length - e2.length)
  ///        .listen(print); // prints 'a', 'ab', 'abc'
  ///
  Stream<T> maximum(Comparator<T> comparator) {
    T? maxSoFar;
    return map((element) {
      if (maxSoFar != null) {
        var comparison = comparator(maxSoFar!, element);
        if (comparison < 0) maxSoFar = element;
      } else {
        maxSoFar = element;
      }
      return maxSoFar!;
    }).distinctUnique();
  }
}
