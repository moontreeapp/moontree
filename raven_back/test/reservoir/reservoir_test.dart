import 'dart:async';

import 'package:test/test.dart';
import 'package:pedantic/pedantic.dart';

import 'package:raven/subjects/reservoir.dart';
import 'package:raven/subjects/change.dart';
import 'package:raven/subjects/rx_map.dart';

class RxMapSource<Record, Model> extends Source<Record, Model> {
  final RxMap map = RxMap();

  @override
  Stream<Change> watch(Reservoir reservoir) {
    return map.stream.map((Change event) => event.when(
        added: (added) => reservoir.addRecord(added.id, added.data),
        updated: (updated) => reservoir.updateRecord(updated.id, updated.data),
        removed: (removed) => reservoir.removeRecord(removed.id)));
  }
}

void enqueueChange(void Function() change) {
  unawaited(Future.microtask(change));
}

Future asyncChange(Reservoir res, void Function() change) async {
  enqueueChange(change);
  await res.changes.first;
}

void main() {
  group('Reservoir', () {
    late RxMapSource source;

    setUp(() {
      source = RxMapSource();
    });

    test('maps Record to Model', () async {
      var res = Reservoir(source, (s) => 'model:$s');
      await asyncChange(res, () => source.map[0] = 'xyz');
      expect(res.data, {0: 'model:xyz'});
    });

    test('remove an element', () async {
      var res = Reservoir(source, (s) => 'model:$s');
      await asyncChange(res, () => source.map[0] = 'abc');
      await asyncChange(res, () => source.map.remove(0));
      expect(res.data, {});
    });

    test('changes made in sequence', () async {
      var res = Reservoir(source, (s) => 'model:$s');
      enqueueChange(() => source.map[0] = 'a');
      enqueueChange(() => source.map[1] = 'b');
      enqueueChange(() => source.map[1] = 'c');
      var changes = await res.changes.take(3).toList();
      expect(changes,
          [Added(0, 'model:a'), Added(1, 'model:b'), Updated(1, 'model:c')]);
    });
  });
}
