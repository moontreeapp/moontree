// dart test test/reservoir/rx_race_test.dart --chain-stack-traces

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

import 'package:raven/utils/buffer_count_window.dart';

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
      expect(results, [
        [0, 1, 2],
        [3, 4],
        [5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14],
        [15, 16, 17, 18, 19],
        [25, 26],
        [27, 28],
        [29]
      ]);
    });
  });
}


/*
c:\moontree\repos\raven>dart test test/reservoir/rx_race_test.dart --chain-stack-traces
Building package executable...
Built test:test.
00:02 +0 -1: RxRace does not duplicate [E]
  Bad state: Stream has already been listened to.
  dart:async                                             _StreamImpl.listen
  package:rxdart/src/utils/forwarding_stream.dart 32:27  forwardStream.<fn>
  dart:async                                             _StreamImpl.listen
  package:rxdart/src/streams/race.dart 68:39             RaceStream._buildController.<fn>.<fn>
  dart:_internal                                         ListIterable.toList
  package:rxdart/src/streams/race.dart 70:16             RaceStream._buildController.<fn>
  dart:async                                             _StreamImpl.listen
  package:rxdart/src/streams/race.dart 31:31             RaceStream.listen
  test\reservoir\rx_race_test.dart 25:10                 main.<fn>.<fn>
  test\reservoir\rx_race_test.dart 15:32                 main.<fn>.<fn>

00:02 +0 -1: Some tests failed.

*/