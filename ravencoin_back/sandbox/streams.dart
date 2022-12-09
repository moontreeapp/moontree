// dart test test/sandbox/streams.dart
import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('ReplayStreams', () async {
    final subject = ReplaySubject<int>(/*maxSize: 2*/);

    subject.add(1);
    subject.add(2);
    subject.add(3);

    subject.stream.listen(print);
    subject.stream.listen((_) => print(subject.values));
    await Future<void>.delayed(const Duration(seconds: 1));
    subject.add(4);
  });

  test('repeat', () async {
    RepeatStream(
            (int repeatCount) => Stream.value('repeat index: $repeatCount'), 3)
        .listen((i) => print(i));
  });
}
