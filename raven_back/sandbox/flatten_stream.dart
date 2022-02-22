// dart test test/sandbox/flatten_stream.dart
import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

final history$ = BehaviorSubject<Iterable<int>?>.seeded(null);
final flattenedHistory$ = BehaviorSubject<int?>.seeded(null)
  ..addStream(history$.where((event) => event != null).expand((i) => i!));
final uniqueHistory$ = flattenedHistory$.distinctUnique();

void main() {
  test('flatten', () async {
    var data = [
      [1, 2, 3],
      [4, 5, 6],
      [1, 4, 7]
    ];
    history$.listen((value) {
      print('history: $value');
    });
    flattenedHistory$.listen((value) {
      print('flattened: $value');
    });
    uniqueHistory$.listen((value) {
      print('unique: $value');
    });
    history$.add(data[0]);
    history$.add(data[1]);
    history$.add(data[2]);
  });
}
