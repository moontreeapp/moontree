import 'package:test/test.dart';

import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoir/change.dart';

import 'helper.dart';

void main() {
  group('Reservoir', () {
    var toModel = (rec) => 'model:$rec';
    var toRecord = (model) => (model as String).replaceFirst('model:', '');
    late RxMapSource source;
    late Reservoir res;

    setUp(() {
      source = RxMapSource();
      res = Reservoir(source, toModel, toRecord);
    });

    test('maps Record to Model', () async {
      await asyncChange(res, () => source.map[0] = 'xyz');
      expect(res.data, {0: 'model:xyz'});
    });

    test('remove an element', () async {
      await asyncChange(res, () => source.map[0] = 'abc');
      await asyncChange(res, () => source.map.remove(0));
      expect(res.data, {});
    });

    test('changes made in sequence', () async {
      enqueueChange(() => source.map[0] = 'a');
      enqueueChange(() => source.map[1] = 'b');
      enqueueChange(() => source.map[1] = 'c');
      var changes = await res.changes.take(3).toList();
      expect(changes,
          [Added(0, 'model:a'), Added(1, 'model:b'), Updated(1, 'model:c')]);
    });

    test('saves changes', () async {
      await asyncChange(res, () => source.map[0] = 'xyz');
      res.data[0] = 'model:abc';
      res.save(0);
      expect(source.map[0], 'abc');
    });
  });
}
