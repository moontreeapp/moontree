import 'dart:math';
import 'dart:typed_data';

Uint8List randomBytes(int n) {
  final generator = Random.secure();
  final random = Uint8List(n);
  for (var i = 0; i < random.length; i++) {
    random[i] = generator.nextInt(255);
  }
  return random;
}

/// Generates a positive (psuedo-)random integer uniformly distributed on the
/// range from [min], inclusive, to [max], exclusive.
int randomInRange(int min, int max, [Random? generator]) =>
    min + (generator ?? Random()).nextInt(max - min);

/// return a (psuedo-)random item from the iterable
int ChooseAtRandom(Iterable items, [Random? generator]) =>
    items.toList()[(generator ?? Random()).nextInt(items.length)];
