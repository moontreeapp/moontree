import 'package:test/test.dart';

import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoir/change.dart';

import 'helper.dart';

void main() {
  group('Reservoir', () {
    late RxMapSource source;
    late Reservoir res;

    setUp(() {
      source = RxMapSource();
      res = Reservoir(source);
      res.addPrimaryIndex((item) => item);
    });

    test('remove an element', () async {
      await asyncChange(res, () => source.save('abc', 'abc'));
      await asyncChange(res, () => source.remove('abc'));
      expect(res.data.toList(), []);
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
      await asyncChange(res, () => source.save('xyz', 'xyz'));
      expect(source.map['xyz'], 'xyz');
      expect(res.get('xyz'), 'xyz');
    });
  });
}
