// dart test test/unit/dart_test.dart
import 'package:test/test.dart';

void main() {
  test('forEach is not isolated', () {
    var histories = {
      'a': [1],
      'b': [],
      'c': [1, 2, 3],
      'd': []
    };
    var gap = 0;
    histories.forEach((k, v) {
      gap = gap + (v.isEmpty ? 1 : 0);
      print('{$k: $v} -- $gap');
    });
    print(gap);
    expect(gap, 2);
  });
}
