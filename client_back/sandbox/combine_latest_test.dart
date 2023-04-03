import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('combineLatest', () async {
    final BehaviorSubject<String> stream1 = BehaviorSubject<String>();
    final BehaviorSubject<String> stream2 = BehaviorSubject<String>();

    unawaited(Future<void>.microtask(() {
      stream1.add('1-A');
      stream2.add('2-A');
      stream2.add('2-B');
      stream1.add('1-B');
    }));

    final List<Tuple2<Object?, Object?>> result =
        await CombineLatestStream.combine2(stream1, stream2,
                (Object? e1, Object? e2) => Tuple2<Object?, Object?>(e1, e2))
            .take(3)
            .toList();

    expect(result, <Tuple2<String, String>>[
      const Tuple2<String, String>('1-A', '2-A'),
      const Tuple2<String, String>('1-B', '2-A'),
      const Tuple2<String, String>('1-B', '2-B')
    ]);
  });
}
