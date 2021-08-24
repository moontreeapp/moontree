import 'package:test/test.dart';

import 'package:reservoir/reservoir.dart';
import 'package:reservoir/change.dart';

import 'helpers/simple_record.dart';
import 'helpers/rx_map_source.dart';

void main() {
  group('Reservoir', () {
    late MapSource<String, SimpleRecord> source;
    late Reservoir res;

    setUp(() {
      source = MapSource();
      res = Reservoir<String, SimpleRecord>(
          source, (SimpleRecord item) => item.key);
    });

    test('add an element', () async {
      var c1 = await res.save(SimpleRecord('a', 'abc'));
      expect(c1, Added('a', SimpleRecord('a', 'abc')));
      // Adding again is a no-op
      var c2 = await res.save(SimpleRecord('a', 'abc'));
      expect(c2, null);
    });

    test('remove an element', () async {
      await res.save(SimpleRecord('a', 'abc'));
      expect(res.data.toList(), [SimpleRecord('a', 'abc')]);

      var c2 = await source.remove('a');
      expect(c2, Removed('a', 'abc'));
      var c3 = await source.remove('a');
      expect(c3, null);
    });

    // test('changes made in sequence', () async {
    //   enqueueChange(() => source.map[0] = 'a');
    //   enqueueChange(() => source.map[1] = 'b');
    //   enqueueChange(() => source.map[1] = 'c');
    //   var changes = await res.changes.take(3).toList();
    //   expect(changes,
    //       [Added(0, 'model:a'), Added(1, 'model:b'), Updated(1, 'model:c')]);
    // });

    // test('saves changes', () async {
    //   await asyncChange(res, () => source.save('xyz', 'xyz'));
    //   expect(source.map['xyz'], 'xyz');
    //   expect(res.get('xyz'), 'xyz');
    // });
  });
}
