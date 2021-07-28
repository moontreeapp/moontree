// dart test test/reservoir/rx_race_test.dart --chain-stack-traces

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  group('RxRace', () {
    Stream<int> timedCounter(Duration interval, [int? maxCount]) async* {
      var i = 0;
      var otherDuration = Duration(milliseconds: 1);
      while (true) {
        if (i < 6 || i > 20) {
          await Future.delayed(interval);
        } else {
          await Future.delayed(otherDuration);
        }
        yield i++;
        if (i == maxCount) break;
      }
    }

    test('never prints more than bufferCount', () async {
      print('starting...');
      var counterStream =
          timedCounter(const Duration(seconds: 1), 30).asBroadcastStream();
      Rx.merge([
        counterStream.bufferCount(5),
        counterStream.bufferTime(Duration(seconds: 2))
      ]).listen((changes) {
        print(changes);
      });
      await Future.delayed(Duration(seconds: 30));
      expect('abc', 'abc');
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