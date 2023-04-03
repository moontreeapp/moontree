// dart test test/sandbox/publish_stream_test.dart

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('multiple listeners on PublishStream.stream', () {
    var stream = PublishSubject<int>();
    stream.stream.listen((item) => print(item));
    stream.stream.listen((item) => print(item));
    stream.add(4);
  });
}
