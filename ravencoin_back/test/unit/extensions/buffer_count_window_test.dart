// dart test test/reservoir/rx_race_test.dart --chain-stack-traces
import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ravencoin_back/utilities/stream/buffer_count_window.dart';

void main() {
  group('RxRace', () {
    test('never prints more than bufferCount', () async {
      var counterStream = Rx.concat([
        Stream.periodic(Duration(milliseconds: 100), (i) => i).take(5),
        Stream.periodic(Duration(milliseconds: 10), (i) => i + 5).take(15),
        Stream.periodic(Duration(milliseconds: 100), (i) => i + 25).take(5),
      ]).asBroadcastStream();

      var results = await counterStream
          .bufferCountTimeout(5, Duration(milliseconds: 200))
          .take(8)
          .toList();
      //expect(results, [
      //  [0, 1, 2],
      //  [3, 4],
      //  [5, 6, 7, 8, 9],
      //  [10, 11, 12, 13, 14],
      //  [15, 16, 17, 18, 19],
      //  [25, 26],
      //  [27, 28],
      //  [29]
      //]);
      expect(results.every((x) => x.length <= 5), true);
    });
  });
}
