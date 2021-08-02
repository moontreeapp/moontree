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
      res = Reservoir(source, (item) => item, toModel, toRecord);
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
      expect(source.map[0], 'xyz');

      /// ?
      //res.data[0] = 'model:abc';
      //res.save('model:abc');
      //expect(source.map[0], 'abc');
      //expect(source.map[1], 'abc');

      res.save('model:abc');
      expect(res.get(0), 'model:xyz');

      for (var item in res) {
        print(item);
        //model:abc
        //model:xyz
      }
      for (var key in res.data.keys) {
        print(key);
        print(res.data[key]);
        //0
        //model:xyz
      }
      // primary key thing broken here...
      expect(res.get(1), 'model:abc');
    });
  });
}
