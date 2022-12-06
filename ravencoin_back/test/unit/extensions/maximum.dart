// dart test test/reservoir/rx_race_test.dart --chain-stack-traces

import 'package:test/test.dart';

import 'package:ravencoin_back/utilities/stream/maximum.dart';

void main() {
  group('MaximumExtension', () {
    test('gets maximum', () async {
      var stream = Stream.fromIterable(['a', 'ab', 'a'])
          .maximum((e1, e2) => e1.length - e2.length);

      var results = await stream.take(3).toList();
      expect(results, ['a', 'ab']);
    });
  });
}
