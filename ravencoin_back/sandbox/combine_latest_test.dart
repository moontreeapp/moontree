import 'dart:async';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('combineLatest', () async {
    var stream1 = BehaviorSubject<String>();
    var stream2 = BehaviorSubject<String>();

    unawaited(Future.microtask(() {
      stream1.add('1-A');
      stream2.add('2-A');
      stream2.add('2-B');
      stream1.add('1-B');
    }));

    var result = await CombineLatestStream.combine2(
        stream1, stream2, (e1, e2) => Tuple2(e1, e2)).take(3).toList();

    expect(result,
        [Tuple2('1-A', '2-A'), Tuple2('1-B', '2-A'), Tuple2('1-B', '2-B')]);
  });
}
