import 'package:test/test.dart';

import 'package:reservoir/reservoir.dart';

import 'helpers/simple_record.dart';

void main() {
  group('Reservoir', () {
    late MapSource<SimpleRecord> source;
    late Reservoir<KeyKey, SimpleRecord> res;

    setUp(() {
      source = MapSource();
      res = Reservoir(KeyKey())..setSource(source);
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

      var c1 = await source.remove('a');
      expect(c1, Removed('a', SimpleRecord('a', 'abc')));
      var c2 = await source.remove('a');
      expect(c2, null);
    });

    test('setSource', () {
      var source = MapSource({'a': SimpleRecord('a', 'abc')});
      res.setSource(source);
      res.setSource(source);
      expect(res.data.length, 1);
    });

    test('clear all data', () async {
      await res.save(SimpleRecord('a', 'abc'));
      await res.save(SimpleRecord('b', 'bcd'));
      await res.clear();
      expect(res.data.isEmpty, true);
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
