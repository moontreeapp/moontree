import 'package:test/test.dart';

class Simple {
  int value = 1;
}

var list = [1, 2, 3];

extension on Simple {
  Iterable<int> valueAdd() {
    return list.map((i) => value + i);
  }
}

void main() {
  test('Extension method', () {
    var simple = Simple();
    expect(simple.valueAdd(), [2, 3, 4]);
  });
}
