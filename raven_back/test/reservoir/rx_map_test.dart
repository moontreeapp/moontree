import 'package:test/test.dart';
import 'package:pedantic/pedantic.dart';

import 'package:raven/subjects/change.dart';
import 'rx_map.dart';

void main() {
  group('RxMap', () {
    test('notifies on add', () async {
      var map = RxMap<int, String>();
      unawaited(Future.microtask(() => map[1] = 'a'));
      expect(map.stream.first, completion(Added(1, 'a')));
    });

    test('notifies on update', () async {
      var map = RxMap<int, String>();
      map[1] = 'a';
      unawaited(Future.microtask(() => map[1] = 'b'));
      expect(map.stream.first, completion(Updated(1, 'b')));
    });

    test('notifies on remove', () async {
      var map = RxMap<int, String>();
      map[1] = 'a';
      unawaited(Future.microtask(() => map.remove(1)));
      expect(map.stream.first, completion(Removed(1)));
    });
  });
}
