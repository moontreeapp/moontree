// dart test test/unit/utils/random.dart
import 'package:test/test.dart';
import 'package:ravencoin_back/utilities/random.dart';

void main() {
  test('random works as expected', () {
    var bytes = randomBytes(2);
    expect(bytes.length, 2);

    expect(randomInRange(0, 1), 0);

    var choice = chooseAtRandom([1, 2]);
    expect([1, 2].contains(choice), true);
  });
}
