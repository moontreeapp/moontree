import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

Uint8List randomBytes(int n) {
  final Random generator = Random.secure();
  final Uint8List random = Uint8List(n);
  for (int i = 0; i < random.length; i++) {
    random[i] = generator.nextInt(255);
  }
  return random;
}

String randomString() => getRandString(27);

String getRandString(int len) {
  final Random random = Random.secure();
  final List<int> values =
      List<int>.generate(len, (int i) => random.nextInt(255));
  return base64UrlEncode(values);
}

/// Generates a positive (psuedo-)random integer uniformly distributed on the
/// range from [min], inclusive, to [max], exclusive.
int randomInRange(int min, int max, [Random? generator]) =>
    min + (generator ?? Random()).nextInt(max - min);

/// return a (psuedo-)random item from the iterable
dynamic chooseAtRandom(Iterable<dynamic> items, [Random? generator]) =>
    items.toList()[(generator ?? Random()).nextInt(items.length)];
