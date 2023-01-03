// dart test test/sandbox/behavior_stream.dart
import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('forEach is not isolated', () async {
    final List<int> data = <int>[1, 2, 3];
    final BehaviorSubject<int> stream = BehaviorSubject<int>();
    stream.listen((int item) => print(item));
    await stream.addStream(Stream<int>.fromIterable(data));
    stream.sink.add(4);
    data.add(5); // not printed - to achieve this kind of pattern you'd have to
    // use something like using the ObservableList below, created as an example.
  });
}
