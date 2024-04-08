import 'dart:math';

// Extending the List class to include the 'random' getter
extension RandomElement<T> on List<T> {
  T get random {
    final _random = Random();
    return this[_random.nextInt(this.length)];
  }
}
